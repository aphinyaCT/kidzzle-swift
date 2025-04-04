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
    @State private var size = 0.8
    @State private var opacity = 0.5
    
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
                
                Spacer()
            }
            .scaleEffect(size)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 1.2)) {
                    self.size = 1.0
                    self.opacity = 1.0
                }
            }
        }
    }
}

