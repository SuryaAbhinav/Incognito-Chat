//
//  CodeBlockView.swift
//  HelloGPT
//
//  Created by Surya Abhinav on 2024/10/27.
//

import SwiftUI

// Helper structure to represent a part of the Markdown content
struct MarkdownPart: Identifiable {
    let id = UUID()
    let content: String
    let isCodeBlock: Bool
}

// Split the Markdown text into parts, detecting code blocks
func splitMarkdown(_ text: String) -> [MarkdownPart] {
    var parts: [MarkdownPart] = []
    var isInCodeBlock = false
    var currentContent = ""
    
    text.enumerateLines { line, _ in
        if line.starts(with: "```") {
            // Toggle code block status
            if isInCodeBlock {
                // End of code block
                parts.append(MarkdownPart(content: currentContent, isCodeBlock: true))
                currentContent = ""
            } else if !currentContent.isEmpty {
                // Add any previous regular text
                parts.append(MarkdownPart(content: currentContent, isCodeBlock: false))
                currentContent = ""
            }
            isInCodeBlock.toggle()
        } else {
            // Add the line to the current content
            currentContent += line + "\n"
        }
    }
    
    // Add any remaining content
    if !currentContent.isEmpty {
        parts.append(MarkdownPart(content: currentContent, isCodeBlock: isInCodeBlock))
    }
    
    return parts
}
