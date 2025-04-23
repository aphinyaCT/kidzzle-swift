////
////  KidzzleApp.swift
////  Kidzzle
////
////  Created by aynnipa on 4/4/2568 BE.
////
//
//import SwiftUI
//
//@main
//struct KidzzleApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}

import SwiftUI
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("App opened with URL: \(url.absoluteString)")

        if url.scheme?.hasPrefix("com.googleusercontent.apps") == true {
            print("Handling Google URL callback")
            return GIDSignIn.sharedInstance.handle(url)
        }
        
        print("Unknown URL scheme: \(url.scheme ?? "nil")")
        return false
    }
}

@main
struct KidzzleApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @AppStorage("hasAcceptedPrivacyPolicy") private var hasAcceptedPrivacyPolicy = false
    @State private var isShowingSplash = true
    
    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            if isShowingSplash {
                SplashScreenView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation {
                                isShowingSplash = false
                            }
                        }
                    }
            } else if !hasAcceptedPrivacyPolicy {
                PrivacyPolicyView(agreed: $hasAcceptedPrivacyPolicy)
            } else {
                ContentView()
                    .environmentObject(authViewModel)
                    .onOpenURL { url in
                        let googleHandled = GIDSignIn.sharedInstance.handle(url)
                        
                        if !googleHandled {
                            print("URL not handled: \(url)")
                        }
                    }
            }
        }
    }
}

struct SplashScreenView: View {
    @State private var size = 1.0
    @State private var opacity = 0.8
    @State private var animationCount = 0
    @State private var isAnimating = false
    
    private let beatDuration: Double = 0.5
    private let restDuration: Double = 0.3
    private let delayBetweenBeats: Double = 0.1
    private let totalBeats = 4
    
    var body: some View {
        ZStack {
            Color.ivorywhite
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Image("KIDZZLE-LOGO-TRANSPARENT")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 250, height: 250)
                    .scaleEffect(size)
                    .opacity(opacity)
                    .onAppear {
                        startSmoothHeartbeatAnimation()
                    }
                
                Spacer()
            }
        }
    }
    
    func startSmoothHeartbeatAnimation() {
        guard !isAnimating else { return }
        isAnimating = true
        
        animateHeartbeat(beatIndex: 0)
    }
    
    func animateHeartbeat(beatIndex: Int) {
        guard beatIndex < totalBeats else {
            withAnimation(.easeInOut(duration: 0.8)) {
                size = 1.0
                opacity = 1.0
            }

            isAnimating = false
            return
        }
        
        withAnimation(.easeIn(duration: beatDuration * 0.4).delay(delayBetweenBeats)) {
            size = 1.15
            opacity = 0.9
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + beatDuration * 0.4 + delayBetweenBeats) {
            withAnimation(.easeOut(duration: beatDuration * 0.6)) {
                size = 0.98
                opacity = 0.8
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + beatDuration * 0.6) {
                withAnimation(.easeInOut(duration: restDuration)) {
                    size = 1.0
                    opacity = 0.85
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + restDuration + (beatIndex < totalBeats - 1 ? 0.2 : 0)) {
                    animateHeartbeat(beatIndex: beatIndex + 1)
                }
            }
        }
    }
}
