//
//  ChatTitle.swift
//  HelloGPT
//
//  Created by Surya Abhinav on 2024/10/26.
//
import SwiftUI

struct ChatTitle: View {
    let title: String
    
    init(title: String) {
        self.title = title
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 5)
        .padding(.horizontal)
    }
}
