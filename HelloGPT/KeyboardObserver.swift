//
//  KeyboardObserver.swift
//  HelloGPT
//
//  Created by Surya Abhinav on 2024/11/12.
//
#if os(iOS)
import SwiftUI
import Combine

final class KeyboardObserver: ObservableObject {
    @Published var isKeyboardVisible: Bool = false
    @Published var keyboardHeight: CGFloat = 0

    private var cancellables = Set<AnyCancellable>()

    init() {
        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)

        willShow
            .merge(with: willHide)
            .sink { [weak self] notification in
                guard let self = self else { return }
                if notification.name == UIResponder.keyboardWillShowNotification {
                    if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                        // Get the keyboard height and subtract the safe area inset if available
//                        let bottomInset = Self.getSafeAreaBottomInset()
//                        let topInset = Self.getSafeAreaTopInset()
//                        print("Keyboard Frame Height: \(keyboardFrame.height)")
//                        print("Safe Area Bottom Inset: \(bottomInset)")
//                        print("Safe Area Top Inset: \(topInset)")
//                        self.keyboardHeight = keyboardFrame.height - bottomInset - topInset
                        self.keyboardHeight = keyboardFrame.height - 120
//                        print("Calculated Keyboard Height: \(self.keyboardHeight)")
                    }
                    self.isKeyboardVisible = true
                } else {
                    self.keyboardHeight = 0
                    self.isKeyboardVisible = false
                }
            }
            .store(in: &cancellables)
    }

    // Helper method to get the safe area bottom inset
    private static func getSafeAreaBottomInset() -> CGFloat {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.keyWindow else {
            return 0
        }
        return keyWindow.safeAreaInsets.bottom
    }
    
    // Helper method to get the safe area top inset
    private static func getSafeAreaTopInset() -> CGFloat {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.keyWindow else {
            return 0
        }
        return keyWindow.safeAreaInsets.top
    }
}
#endif  
