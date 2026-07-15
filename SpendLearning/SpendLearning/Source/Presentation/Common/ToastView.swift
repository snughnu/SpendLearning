//
//  ToastView.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/14/26.
//

import SwiftUI

struct ToastModifier: ViewModifier {

    @Binding var isShowing: Bool
    let message: String

    @State private var isVisible = false
    @State private var task: Task<Void, Never>? = nil

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if isVisible {
                    Text(message)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color(UIColor.DesignSystem.primary))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.bottom, 16)
                        .ignoresSafeArea(edges: .bottom)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: isVisible)
            .onChange(of: isShowing) { _, newValue in
                guard newValue else { return }
                isShowing = false
                task?.cancel()
                Task { @MainActor in
                    withTransaction(Transaction(animation: nil)) {
                        isVisible = false
                    }
                    try? await Task.sleep(for: .milliseconds(50))
                    withAnimation {
                        isVisible = true
                    }
                    task = Task {
                        try? await Task.sleep(for: .seconds(2))
                        if !Task.isCancelled {
                            withAnimation {
                                isVisible = false
                            }
                        }
                    }
                }
            }
    }
}

extension View {
    func toast(isShowing: Binding<Bool>, message: String) -> some View {
        modifier(ToastModifier(isShowing: isShowing, message: message))
    }
}
