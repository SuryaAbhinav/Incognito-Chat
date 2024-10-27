//
//  CodeBlockView.swift
//  HelloGPT
//
//  Created by Surya Abhinav on 2024/10/27.
//

import SwiftUI

struct CodeBlockView: View {
    var codeText: String

    var body: some View {
        ScrollView(.horizontal) {
            Text(codeText)
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(8)
                .foregroundColor(.green) // Color commonly used for code text
                .font(.system(.body, design: .monospaced)) // Use monospaced font
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: 300, alignment: .leading)
    }
}
