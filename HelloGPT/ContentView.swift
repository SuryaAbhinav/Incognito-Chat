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
#endif

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
    @State private var cancellables = Set<AnyCancellable>()
    
    @Environment(\.colorScheme) var colorScheme
    

    var body: some View {
        ZStack {
            Image("Incognitio")
                .opacity(0.1)
            
            VStack (spacing: 0) {
                Spacer()
                HStack {
                    ChatTitle(title: "Incognito Chat")
                    Button("Refresh") {
                        messages = []
                        llmRequestComponent.disconnect()
                        llmRequestComponent.connectToWebSocket()
                        
                    }
                    .padding(.trailing, 20)
                }
                Divider()
                VStack (spacing: 0) {
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            ForEach(messages) { message in
                                MessageView(message: message)
                            }
                        }
                        .padding()
                    }
//                    .safeAreaInset(edge: .bottom) {
//#if os(iOS)
//                        MessageInputView(userInput: $userInput, textHeight: $textHeight, onSend: sendMessage)
//                            .padding(.bottom, keyboardOffset)
//#else
//                        MessageInputView(userInput: $userInput, textHeight: $textHeight, onSend: sendMessage)
//#endif
//                    }
#if os(iOS)
                        MessageInputView(userInput: $userInput, textHeight: $textHeight, onSend: sendMessage)
                            .padding(.bottom, keyboardOffset)
#else
                        MessageInputView(userInput: $userInput, textHeight: $textHeight, onSend: sendMessage)
#endif
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
//                .padding(.bottom, keyboardObserver.isKeyboardVisible ? keyboardObserver.keyboardHeight : 0)
                .animation(.easeOut(duration: 0.25), value: keyboardObserver.keyboardHeight)
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .environmentObject(keyboardObserver)
#endif
                
            }
        }
    }
    
    #if os(iOS)
    private var safeAreaInsets: UIEdgeInsets {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return scene?.windows.first?.safeAreaInsets ?? .zero
    }
    
    private var keyboardOffset: CGFloat {
        guard keyboardObserver.isKeyboardVisible else { return 0 }
        
        let screenHeight = UIScreen.main.bounds.height
        let adjustmentFactor = screenHeight > 850 ? (safeAreaInsets.bottom + safeAreaInsets.top) : safeAreaInsets.bottom
//        let adjustmentFactor = safeAreaInsets.bottom + safeAreaInsets.top
//        print(textHeight)
        return max(keyboardObserver.keyboardHeight - (adjustmentFactor + textHeight), 0)
    }
    #endif

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
                    .textSelection(.enabled)
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
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
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
                        .font(.system(size: 48))
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
                .textSelection(.enabled)  // Makes code selectable
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
            .textSelection(.enabled)
            .markdownTextStyle(){
                FontSize(.em(0.85))
            }
    }
}

struct ChatbotView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
