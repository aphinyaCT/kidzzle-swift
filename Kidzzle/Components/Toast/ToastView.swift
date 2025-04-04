//
//  ToastView.swift
//  Kidzzle
//
//  Created by aynnipa on 1/4/2568 BE.
//


import SwiftUI

struct ToastView: View {
    var type: ToastType
    var message: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: type.icon)
                .foregroundColor(type.color)
            
            Text(message)
                .font(customFont(type: .medium, textStyle: .callout))
                .foregroundColor(type.color)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(type.color, lineWidth: 1)
        )
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding(.horizontal, 16)
    }
}

// MARK: - Toast Modifier
struct ToastModifier: ViewModifier {
    @Binding var isShowing: Bool
    var type: ToastType
    var message: String
    var duration: Double = 2.0
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isShowing {
                VStack {
                    ToastView(type: type, message: message)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                                withAnimation {
                                    isShowing = false
                                }
                            }
                        }
                    
                    Spacer()
                }
                .padding(.top, 20)
                .animation(.easeInOut, value: isShowing)
                .zIndex(100)
            }
        }
    }
}

// MARK: - View Extension
extension View {
    func toast(isShowing: Binding<Bool>, toastCase: ToastCase, duration: Double = 2.0) -> some View {
        self.modifier(ToastModifier(isShowing: isShowing, type: toastCase.type, message: toastCase.message, duration: duration))
    }
    
    func toast(isShowing: Binding<Bool>, type: ToastType, message: String, duration: Double = 2.0) -> some View {
        self.modifier(ToastModifier(isShowing: isShowing, type: type, message: message, duration: duration))
    }
}

// MARK: - Preview
struct ToastPreview: View {
    @State private var showToast = true
    
    var body: some View {
        VStack {
            Text("Toast Preview")
                .padding()
        }
        .toast(isShowing: $showToast, toastCase: .loginError)
    }
}

#Preview {
    ToastPreview()
}
