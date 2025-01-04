//
//  URLSession.swift
//  HelloGPT
//
//  Created by Surya Abhinav on 2024/10/26.
//

import Foundation
import Combine

class LLMRequestComponent: ObservableObject {
    public var webSocketTask: URLSessionWebSocketTask?
    @Published var responseText: String = ""
    private var accessToken: String?
    private var cancellables = Set<AnyCancellable>()
    
    private let baseURL = "192.168.0.12:8000"
    
    func connectToWebSocket() {
        // First fetch the token, then establish WebSocket connection
        fetchToken()
    }
    
    private func fetchToken() {
        guard let url = URL(string: "http://\(baseURL)/generatetoken") else { return }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: TokenResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        print("Error fetching token: \(error.localizedDescription)")
                    case .finished:
                        break
                    }
                },
                receiveValue: { [weak self] tokenResponse in
                    self?.accessToken = tokenResponse.accessToken
                    self?.establishWebSocketConnection()
                }
            )
            .store(in: &cancellables)
    }
    
    private func establishWebSocketConnection() {
        guard let token = accessToken else {
            print("No access token available")
            return
        }
        
        guard let url = URL(string: "ws://\(baseURL)/ws/chatproxyrequest?token=\(token)") else { return }
        
        // Create a WebSocket task
        webSocketTask = URLSession.shared.webSocketTask(with: url)
        webSocketTask?.resume()
        
        // Start receiving messages
        receiveMessages()
    }
    
    func sendMessage(_ userMessage: String) {
        // Check if we have a valid token and connection
        guard webSocketTask != nil else {
            // If no connection, try to reconnect first
            connectToWebSocket()
            // Store message to send after connection is established
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.sendMessage(userMessage)
            }
            return
        }
        
        self.responseText = ""
        let message = URLSessionWebSocketTask.Message.string(userMessage)
        
        webSocketTask?.send(message) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
                // If we get an authentication error, try to refresh token
                if (error as NSError).code == 1000 { // WebSocket error code for normal closure
                    self.handleConnectionError()
                }
            }
        }
    }
    
    private func handleConnectionError() {
        // Close existing connection
        disconnect()
        // Fetch new token and reconnect
        connectToWebSocket()
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
                // Handle authentication errors
                if (error as NSError).code == 1000 {
                    self?.handleConnectionError()
                }
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
        webSocketTask = nil
    }
}

// Token response model
struct TokenResponse: Codable {
    let accessToken: String
    let tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
    }
}
