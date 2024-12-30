//
//  KeyboardObserver.swift
//  HelloGPT
//
//  Created by Surya Abhinav on 2024/11/12.
//
#if os(iOS)
import SwiftUI
import Combine

//final class KeyboardObserver: ObservableObject {
//    @Published var isKeyboardVisible: Bool = false
//    @Published var keyboardHeight: CGFloat = 0
//
//    private var cancellables = Set<AnyCancellable>()
//
//    init() {
//        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
//        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
//
//        willShow
//            .merge(with: willHide)
//            .sink { [weak self] notification in
//                guard let self = self else { return }
//                if notification.name == UIResponder.keyboardWillShowNotification {
//                    if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
//                        self.keyboardHeight = keyboardFrame.height - 120
//                    }
//                    self.isKeyboardVisible = true
//                } else {
//                    self.keyboardHeight = 0
//                    self.isKeyboardVisible = false
//                }
//            }
//            .store(in: &cancellables)
//    }
//}

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
//                        self.keyboardHeight = keyboardFrame.height - bottomInset
                        self.keyboardHeight = keyboardFrame.height - 120
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
}
#endif  
