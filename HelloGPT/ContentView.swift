//
//  ContentView.swift
//  HelloGPT
//
//  Created by Surya Abhinav on 2024/10/26.
//

import SwiftUI
import SwiftData
import MarkdownUI
import HighlightSwift
import Combine
#if os(iOS)
import UIKit
//import Combine
#endif

//struct Wbwv: View {
//    let part: MarkdownPart
//    @State private var opacityStates: [Bool]
//    
//    init(part: MarkdownPart) {
//        self.part = part
//        _opacityStates = State(initialValue: Array(repeating: false, count: part.content.count))
//    }
//    
//    var body: some View {
//        let words = part.content.split(separator: " ").map(String.init)
//
//        ForEach(Array(words.enumerated()), id: \.offset) { index, word in
//            Text(String(word))
//                .opacity(opacityStates[index] ? 1 : 0)
//                .onAppear {
//                    withAnimation(.easeIn(duration: 0.3).delay(Double(index) * 0.1)) {
//                        opacityStates[index] = true
//                    }
//                }
//        }
//            
//        
//    }
//}
//
struct Message: Identifiable {
    let id = UUID()
    var text: String
    let isUser: Bool
    let isCode: Bool
}


private var cancellables = Set<AnyCancellable>()
private let llmComponent = LLMRequestComponent()


// MARK: - Content View
struct ContentView: View {
    @State private var userInput: String = ""
    @State private var textHeight: CGFloat = 60
    @State private var messages: [Message] = []
    #if os(iOS)
    @StateObject private var keyboardObserver = KeyboardObserver()
    #endif
//    @State private var keyboardHeight: CGFloat = 0
    @State var value: CGFloat = 0
    @StateObject private var llmRequestComponent = LLMRequestComponent()
    
    @Environment(\.colorScheme) var colorScheme
    

    var body: some View {            VStack {
                ChatTitle(title: "Incognito Chat")
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(messages) { message in
                            MessageView(message: message)
                        }
                    }
                    .padding()
                }
                .safeAreaInset(edge: .bottom) {
                    MessageInputView(userInput: $userInput, textHeight: $textHeight, onSend: sendMessage)
                        .background(ColorSchemeManager.solidBlackBackgroundColor(for: colorScheme))
                }
            }
            .navigationTitle("Incognito Chat")
            .background(ColorSchemeManager.backgroundColor(for: colorScheme))
            .frame(minWidth: 400, minHeight: 600)
            .onAppear {
                llmRequestComponent.connectToWebSocket()
            }
            .onDisappear {
                llmRequestComponent.disconnect()
            }
            #if os(iOS)
            .padding(.bottom, keyboardObserver.isKeyboardVisible ? keyboardObserver.keyboardHeight : 0)
                    .animation(.easeOut(duration: 0.25), value: keyboardObserver.keyboardHeight)
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                    .environmentObject(keyboardObserver)
            #endif
        
    }

    private func sendMessage() {
        guard !userInput.isEmpty else { return }

        // Add user's message to the chat
        let userMessage = Message(text: userInput, isUser: true, isCode: false)
        messages.append(userMessage)

        // Prepare a bot placeholder message
        let botMessage = Message(text: "", isUser: false, isCode: false)
        messages.append(botMessage)
        
        // Initialize WebSocket connection if not already connected
        if llmComponent.webSocketTask == nil {
            llmComponent.connectToWebSocket()
        }

        // Send user input to LLM backend via WebSocket
        llmComponent.sendMessage(userInput)

        // Listen for streaming responses and update the bot's message
        llmComponent.$responseText
            .receive(on: DispatchQueue.main)
            .sink { responseText in
                if let lastIndex = messages.lastIndex(where: { !$0.isUser }) {
                    messages[lastIndex].text = responseText
                }
            }
            .store(in: &cancellables)
                
        // Clear user input
        userInput = ""
    }
    
}

// MARK: Message View
struct MessageView: View {
    var message: Message
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack (alignment: .top) {
            if message.isUser {
                Spacer()
                Text(message.text)
                    .padding()
                    .background(ColorSchemeManager.userMsgColor(for: colorScheme))
                    .cornerRadius(16)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            } else {
                Image(systemName: "brain.fill")
                    .padding(.leading)
                    .padding(.top)
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(splitMarkdown(message.text)) { part in
                        if part.isCodeBlock {
                            CodeBlockView(content: part.content)
//                                .frame(maxWidth: .infinity)
                        } else {
                            MarkdownView(content: part.content)
                        }
                    }
                }
                .padding()
                .cornerRadius(8)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

// MARK: Message Input View
struct MessageInputView: View {
    @Binding var userInput: String
    @State private var textHeightiOS:CGFloat = 38
    @Binding var textHeight: CGFloat
    @Environment(\.colorScheme) var colorScheme
    var onSend: () -> Void

    var body: some View {
        ZStack(alignment: .trailing) {
            RoundedRectangle(cornerRadius: 8)
//                .fill(ColorSchemeManager.clearBackground(for: colorScheme))
            #if os(iOS)
                .fill(ColorSchemeManager.solidBlackBackgroundColor(for: colorScheme))
            #else
                .fill(ColorSchemeManager.solidBlackBackgroundColor(for: colorScheme))
            #endif
                .frame(maxWidth: .infinity)
                .frame(height: textHeight + 20)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )

            HStack(alignment: .bottom, spacing: 8) {
                ZStack(alignment: .leading) {
                    TextEditor(text: $userInput)
                        .frame(minHeight: textHeight, maxHeight: textHeight)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 2)
                        .scrollContentBackground(.hidden)
                        .background(GeometryReader { geometry in
                            ColorSchemeManager.clearBackground(for: colorScheme)
                               .onChange(of: userInput) {
                                   withAnimation(.easeInOut(duration: 0.2)) {
                                       updateTextHeight(for: geometry.size.width)
                                   }
                               }
                        })
                        .cornerRadius(8)

                    if userInput.isEmpty {
                        Text("Wassup...?")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                    }
                }
                .cornerRadius(8)

                Button(action: onSend) {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 24))
                }
//                .frame(width: 44, height: 44)
                .background(ColorSchemeManager.clearBackground(for: colorScheme))
                .clipShape(Circle())
                .shadow(radius: 2)
//                .padding(.trailing, 5)
                .padding(.vertical, 8)
            }
            .padding(.horizontal, 5)
            .padding(.vertical, 10)
        }
    #if os(iOS)
        .padding(.horizontal, 25)
    #else
        .padding()
    #endif
    }

    private func updateTextHeight(for width: CGFloat) {
        let lineLimit: Int = 10
        let estimatedLineHeight: CGFloat = 20  // Adjust as necessary

        // Calculate number of lines based on content, assuming 50 characters per line
        let lines = userInput.split(separator: "\n").count + (userInput.count / 50)
        let newHeight = CGFloat(min(lines, lineLimit)) * estimatedLineHeight

        // Update the text height with a minimum single line height
        textHeight = max(newHeight, 60)
    }
}

// MARK: - Code Block View
struct CodeBlockView: View {
    var content: String
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        ScrollView(.horizontal) {
            CodeText(content)
        }
        .padding(10)
//        .frame(minWidth: 500, maxWidth: .infinity, alignment: .leading)
        .frame(minWidth: horizontalSizeClass == .compact ? 200 : 500, maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 2)
                .fill(ColorSchemeManager.codeBlockColor(for: colorScheme))

       )
    }
}

// MARK: - Markdown View
struct MarkdownView: View {
    var content: String

    var body: some View {
        Markdown(content)
    }
}

struct ChatbotView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
