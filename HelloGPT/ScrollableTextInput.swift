//
//  ScrollableTextInput.swift
//  HelloGPT
//
//  Created by Surya Abhinav on 2024/11/14.
//

//#if os(iOS)
//import SwiftUI
//
//struct ScrollableTextInput: UIViewRepresentable {
//    
//    @Binding var text: String
//    @Binding var textHeight: CGFloat
//    
//    
//    func makeUIView(context: Context) -> UITextView {
//        let textView = UITextView()
//        textView.delegate = context.coordinator
//        textView.font = UIFont.preferredFont(forTextStyle: .body)
//        textView.isScrollEnabled = false
//        textView.backgroundColor = UIColor.clear
//        
//        return textView
//    }
//    
//    func updateUIView(_ uiView: UITextView, context: Context) {
//        uiView.text = text
//        uiView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
//    }
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    
//    class Coordinator: NSObject, UITextViewDelegate {
//        var parent: ScrollableTextInput
//        
//        init(_ parent: ScrollableTextInput) {
//            self.parent = parent
//        }
//        
//        func textViewDidChange(_ textView: UITextView) {
//            self.parent.text = textView.text
//            DispatchQueue.main.async {
//                self.parent.textHeight = textView.sizeThatFits(textView.frame.size).height
//            }
//        }
//    }
//    
//    
//}
//#endif
