//
//  URLSession.swift
//  HelloGPT
//
//  Created by Surya Abhinav on 2024/10/26.
//


import SwiftUI

// Custom delegate class to handle streaming response
class LLMRequestComponent: NSObject, URLSessionDataDelegate {
    private var responseText = ""
    private var completion: ((String) -> Void)?

    func sendRequestToLLM(userMessage: Message, completion: @escaping (String) -> Void) {
        guard let url = URL(string: "http://127.0.0.1:11434/api/chat") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "llama3",
            "messages": [
                ["role": "user", "content": userMessage.text]
            ]
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        self.completion = completion
        
        // Create a URL session with self as the delegate
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        session.dataTask(with: request).resume()
    }

    // Called when data is received
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let responseString = String(data: data, encoding: .utf8) else { return }
        
        // Split incoming data by new lines and parse each JSON object
        let lines = responseString.split(separator: "\n")
        
        for line in lines {
            if let lineData = line.data(using: .utf8),
               let jsonObject = try? JSONSerialization.jsonObject(with: lineData, options: []) as? [String: Any],
               let message = jsonObject["message"] as? [String: Any],
               let content = message["content"] as? String {
                
                // Append content to responseText
                responseText += content
                
                // Update UI on main thread
                DispatchQueue.main.async {
                    self.completion?(self.responseText)
                }
            }
        }
    }
    
    // Handle completion or error
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            DispatchQueue.main.async {
                self.completion?("Error: \(error.localizedDescription)")
            }
        }
    }
}
