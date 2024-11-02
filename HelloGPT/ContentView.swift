//
//  ContentView.swift
//  HelloGPT
//
//  Created by Surya Abhinav on 2024/10/26.
//

import SwiftUI
import SwiftData
import MarkdownUI

struct CodeBlockStyler: ViewModifier {
    func body(content: Content) -> some View {
        content
            .markdownTextStyle {
                FontWeight(.bold) // Make code blocks bold
                ForegroundColor(.white) // Code text color
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.black) // Background color for code blocks
            )
            .padding(.horizontal)
    }
}


struct Message: Identifiable {
    let id = UUID()
    var text: String
    let isUser: Bool
    let isCode: Bool
}

struct ContentView: View {
    @State private var messages: [Message] = []
    @State private var userInput: String = ""
    @State private var textHeight: CGFloat = 60
    @State private var opa: Double = 0
        
    private func updateTextHeight(for width: CGFloat) {
            let lineLimit: Int = 10
            let estimatedLineHeight: CGFloat = 20  // Adjust as necessary

            // Calculate number of lines based on content, assuming 50 characters per line
#if os(macOS)
            let lines = userInput.split(separator: "\n").count + (userInput.count / 50)
#else
            let lines = userInput.split(separator: "\n").count + (userInput.count / 10)
#endif
            let newHeight = CGFloat(min(lines, lineLimit)) * estimatedLineHeight

            // Update the text height with a minimum single line height
#if os(macOS)
            textHeight = max(newHeight, 60)
#else
            textHeight = max(newHeight, 60)
#endif
        }




    var body: some View {
        VStack {
            ChatTitle(title: "Mr. J")
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(messages) { message in
                        HStack {
                            if message.isUser {
                                Spacer()
                                Text(message.text)
                                    .padding()
#if os(macOS)
                                    .background(Color.gray.opacity(0.7))
                                    .shadow(radius: 10, x: 10, y: 10)
                                
#else
                                    .background(Color.blue.opacity(0.7))
#endif
                                    .cornerRadius(8)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: 360, alignment: .trailing)

                            } else {
#if (os(macOS))
                                VStack(alignment: .leading, spacing: 10) {
                                    ForEach(splitMarkdown(message.text)) { part in
                                        if part.isCodeBlock {
                                            ScrollView(.horizontal){
                                                HStack() {
                                                    Text(part.content)
                                                        .padding(10)
                                                        .foregroundColor(.white)
                                                        .font(.system(.body, design: .monospaced)) // Monospaced font for code
                                                    
                                                }
                                                
                                            }
                                            .padding(10)
                                            .frame(minWidth: 500, maxWidth: .infinity, alignment: .leading)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(Color.black)
                                            )
                                        } else {
                                            Markdown(part.content)
                                        }
                                    }
                                    
                                }
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .shadow(radius: 10, x: 10, y: 10)
                                .frame(maxWidth: 600, alignment: .leading)

#else
                                VStack(alignment: .leading, spacing: 10) {
                                    ForEach(splitMarkdown(message.text)) { part in
                                        if part.isCodeBlock {
                                            ScrollView(.horizontal){
                                                HStack() {
                                                    Text(part.content)
                                                        .padding(10)
                                                        .foregroundColor(.white)
                                                        .font(.system(.body, design: .monospaced)) // Monospaced font for code
                                                }
                                            }
                                            .padding(10)
                                            .frame(minWidth: 280, maxWidth: .infinity, alignment: .leading)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(Color.black)
                                            )
                                        } else {
                                            Markdown(part.content)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .frame(maxWidth: 360, alignment: .leading)
#endif

                            }
                        }
                    }
                }
                .padding()
            }
            

            
            ZStack(alignment: .trailing) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.clear)
                    .frame(maxWidth: .infinity)
                    .frame(height: textHeight + 20)  // Minimum height with padding
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                
                HStack(alignment: .bottom, spacing: 8) {
                    ZStack(alignment: .leading) {
                        TextEditor(text: $userInput)
                            .font(.body)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 8)
                            .frame(minHeight: textHeight, maxHeight: textHeight)  // Dynamic height
                            .background(GeometryReader { geometry in
                                Color.clear
                                    .onChange(of: userInput) {
                                        withAnimation(.easeInOut(duration: 0.2)) {  // Smooth resizing animation
                                            updateTextHeight(for: geometry.size.width)
                                        }
                                    }
                            })
                            .cornerRadius(8)
                        
                        if userInput.isEmpty {
                            Text("Enter text here")
                                .foregroundColor(.gray)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                        }
                    }
                    .cornerRadius(8)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 24))
                            .keyboardShortcut(.defaultAction)
                    }
                    .frame(width: 44, height: 44)
                    .background(Color.blue)
                    .clipShape(Circle())
                    .shadow(radius: 2)
                    .padding(.trailing, 5)
                    .padding(.vertical, 8)
                }
                .padding(.horizontal, 5)
                .padding(.vertical, 10)
            }
            .padding()
        }
        .frame(minWidth: 400, minHeight: 600)
    }

    private func sendMessage() {
        guard !userInput.isEmpty else { return }

        // Add user's message
        let userMessage = Message(text: userInput, isUser: true, isCode: false)
        messages.append(userMessage)
        
        // Send request to LLM and handle streaming response
        let llmComponent = LLMRequestComponent()

        // Add a placeholder bot message to be updated incrementally
        let botMessage = Message(text: "", isUser: false, isCode: false)
        messages.append(botMessage)

        // Send the request and handle streaming response
        llmComponent.sendRequestToLLM(userMessage: userMessage) { responseText in
            DispatchQueue.main.async {
                // Update the last message's text incrementally
                if let lastIndex = messages.lastIndex(where: { !$0.isUser }) {
                    messages[lastIndex].text = responseText
                }
            }
        }
        
        userInput = ""
    }
}

struct ChatbotView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
