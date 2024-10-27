//
//  ContentView.swift
//  HelloGPT
//
//  Created by Surya Abhinav on 2024/10/26.
//

import SwiftUI
import SwiftData

struct ChatInputModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(10)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
            .padding(.horizontal)
    }
}

struct SendButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(10)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(15)
            .padding(.trailing)
            .font(.system(size: 16, weight: .bold))
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

    var body: some View {
        VStack {
            
            ChatTitle(title: "Talk to Me...")
            
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(messages) { message in
                        HStack {
                            if message.isUser {
                                Spacer()
                                Text(message.text)
                                    .padding()
                                    .background(Color.blue.opacity(0.7))
                                    .cornerRadius(8)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: 300, alignment: .trailing)
                            } else {
#if (os(macOS))
                                Text(message.text)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                    .foregroundColor(.white)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: 300, alignment: .leading)
                                Spacer()
#else
                                Text(message.text)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: 300, alignment: .init(horizontal: .leading, vertical: .center))
#endif

                            }
                        }
                    }
                }
                .padding()
            }
            
            HStack {
                TextField("Enter message...", text: $userInput)
                    .modifier(ChatInputModifier())
                
                Button("Send", systemImage: "arrow.up", action: sendMessage)
#if os(macOS)
                    .keyboardShortcut(.defaultAction)
                    .onSubmit {
                        sendMessage()
                    }
#else
                    .labelStyle(.iconOnly)
#endif
//                    Text("Send")
                
                .modifier(SendButtonModifier())
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
