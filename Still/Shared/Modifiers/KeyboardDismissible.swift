//
//  ScreenLayoutStyle.swift
//  Still
//
//  Created by 정홍섭 on 9/29/26.
//

import SwiftUI
import UIKit

struct KeyboardDismissible: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(KeyboardDismissGestureInstaller())
    }
}

extension View {
    func keyboardDismissible() -> some View {
        modifier(KeyboardDismissible())
    }

    func keyboardTextInputArea() -> some View {
        background(KeyboardTextInputAreaMarker())
    }
}

private struct KeyboardTextInputAreaMarker: UIViewRepresentable {
    func makeUIView(context: Context) -> KeyboardTextInputAreaMarkerView {
        KeyboardTextInputAreaMarkerView()
    }

    func updateUIView(
        _ uiView: KeyboardTextInputAreaMarkerView,
        context: Context
    ) {}
}

private final class KeyboardTextInputAreaMarkerView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        backgroundColor = .clear
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private struct KeyboardDismissGestureInstaller: UIViewRepresentable {
    func makeUIView(context: Context) -> KeyboardDismissGestureView {
        KeyboardDismissGestureView()
    }

    func updateUIView(
        _ uiView: KeyboardDismissGestureView,
        context: Context
    ) {}

    static func dismantleUIView(
        _ uiView: KeyboardDismissGestureView,
        coordinator: Void
    ) {
        uiView.removeGestureRecognizerFromWindow()
    }
}

private final class KeyboardDismissGestureView: UIView,
    UIGestureRecognizerDelegate {
    private weak var registeredWindow: UIWindow?

    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        gesture.cancelsTouchesInView = false
        gesture.delaysTouchesBegan = false
        gesture.delaysTouchesEnded = false
        gesture.delegate = self
        return gesture
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()

        guard registeredWindow !== window else { return }

        removeGestureRecognizerFromWindow()
        registeredWindow = window
        registeredWindow?.addGestureRecognizer(tapGestureRecognizer)
    }

    func removeGestureRecognizerFromWindow() {
        registeredWindow?.removeGestureRecognizer(tapGestureRecognizer)
        registeredWindow = nil
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch
    ) -> Bool {
        guard !touch.isInsideTextInput else { return false }
        guard let registeredWindow else { return true }

        let location = touch.location(in: registeredWindow)
        return !registeredWindow.containsKeyboardTextInputArea(
            at: location,
            in: registeredWindow
        )
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }

    @objc private func dismissKeyboard() {
        registeredWindow?.endEditing(true)
    }
}

private extension UIView {
    func containsKeyboardTextInputArea(
        at location: CGPoint,
        in window: UIWindow
    ) -> Bool {
        if self is KeyboardTextInputAreaMarkerView,
           !isHidden,
           alpha > 0.01,
           bounds.contains(convert(location, from: window)) {
            return true
        }

        return subviews.contains {
            $0.containsKeyboardTextInputArea(at: location, in: window)
        }
    }
}

private extension UITouch {
    var isInsideTextInput: Bool {
        var currentView = view

        while let candidate = currentView {
            if candidate is UITextField || candidate is UITextView {
                return true
            }

            currentView = candidate.superview
        }

        return false
    }
}
