//
//  ColorSchemeManager.swift
//  HelloGPT
//
//  Created by Surya Abhinav on 2024/11/04.
//


import SwiftUI

struct ColorSchemeManager {
    static func backgroundColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .black.opacity(0.2) : .white.opacity(0.2)
    }

    static func userMsgColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .black.opacity(0.4) : .gray.opacity(0.2)
    }

    static func codeBlockColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .black.opacity(0.2) : .gray.opacity(0.2)
    }
    
//    static func textEditorBackground(for colorScheme: ColorScheme) -> Color {
//        colorScheme == .dark ? .clear : .clear
//    }
    
    static func clearBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .clear : .clear
    }
    
    static func solidBlackBackgroundColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .black : .white
    }
    
    static func solidGrayBackgroundColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .gray : .gray
    }
    
    // Additional color methods as needed
}
