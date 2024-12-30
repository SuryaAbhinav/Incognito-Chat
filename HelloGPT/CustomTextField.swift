//
//  CustomTextField.swift
//  HelloGPT
//
//  Created by Surya Abhinav on 2024/11/14.
//

import SwiftUI

struct CustomTextField: View {
    @State private var message: String = ""
    
    var body: some View {
        HStack(alignment: .bottom) {
            HStack(spacing: 8) {
                ZStack(alignment: .leading) {
                    if message.isEmpty {
                        Text("Message...")
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 8)
                    }
                    TextEditor(text: $message)
                        .frame(minHeight: 10, maxHeight: 140)
                        .padding(.horizontal, 4)
                        .background(Color.white)
                        .cornerRadius(10)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.white)
            .cornerRadius(10)
            
            // Send button
            if !message.isEmpty {
                Button {
                    // send something
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.largeTitle)
                }
            } else {
                Button {
                    // make something
                } label: {
                    Image(systemName: "photo.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(Color(.systemGray))
                }
            }
        }
        .padding(.leading, 14)
        .padding(.trailing, 10)
        .padding(.vertical, 7)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.3), value: message)
    }
}

struct CustomTextField_Previews: PreviewProvider {
    static var previews: some View {
        CustomTextField()
    }
}
