//
//  URLSession.swift
//  HelloGPT
//
//  Created by Surya Abhinav on 2024/10/26.
//

import Foundation

class LLMRequestComponent: ObservableObject {
    public var webSocketTask: URLSessionWebSocketTask?
    @Published var responseText: String = ""

    func connectToWebSocket() {
        guard let url = URL(string: "ws://192.168.0.12:8000/ws/chatproxyrequest") else { return }

        // Create a WebSocket task
        webSocketTask = URLSession.shared.webSocketTask(with: url)
        webSocketTask?.resume()

        // Start receiving messages
        receiveMessages()
    }

    func sendMessage(_ userMessage: String) {
        self.responseText = ""
        let message = URLSessionWebSocketTask.Message.string(userMessage)

        webSocketTask?.send(message) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            }
        }
    }
    
    private func receiveMessages() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self?.processChunk(text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        self?.processChunk(text)
                    }
                @unknown default:
                    fatalError("Unknown WebSocket message type received")
                }
                
                // Continue receiving messages
                self?.receiveMessages()

            case .failure(let error):
                print("Error receiving message: \(error.localizedDescription)")
            }
        }
    }
    
    private func processChunk(_ chunk: String) {
        // Attempt to parse the chunk as JSON
        guard let data = chunk.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let message = jsonObject["message"] as? [String: Any],
              let content = message["content"] as? String else {
                    print("Failed to parse chunk: \(chunk)")
                    return
                }

        
        // Append the content to responseText and update UI
        DispatchQueue.main.async {
            self.responseText += content
        }
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
}
