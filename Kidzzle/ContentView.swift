////
////  ContentView.swift
////  Kidzzle
////
////  Created by aynnipa on 4/4/2568 BE.
////
//
//import SwiftUI
//
//struct ContentView: View {
//    var body: some View {
//        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundStyle(.tint)
//            Text("Hello, world!")
//        }
//        .padding()
//    }
//}
//
//#Preview {
//    ContentView()
//}

import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var isLoggedIn = false
    @State private var showChildDevelopment = false
    @State private var showForgotPassword = false
    @State private var isSubmitting = false
    
    var body: some View {
        Group {
            if isLoggedIn {
                MainTabView()
                    .environmentObject(authViewModel)
            } else {
                AuthView(
                    isLoggedIn: $isLoggedIn,
                    showChildDevelopment: $showChildDevelopment,
                    showForgotPassword: $showForgotPassword,
                    isSubmitting: $isSubmitting
                )
                .environmentObject(authViewModel)
            }
        }
        .onAppear {
            isLoggedIn = authViewModel.isAuthenticated
        }
        .onChange(of: authViewModel.isAuthenticated) {
            isLoggedIn = authViewModel.isAuthenticated
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        VStack(spacing: 0) {
            switch selectedTab {
            case 0:
                HistoryView()
            case 1:
                PromotionView()
            case 2:
                ChildDevelopmentView()
            case 3:
                BenefitView()
            case 4:
                InformationView()
            default:
                EmptyView()
            }
            
            Spacer()
            
            CustomTabBarView(selectedIndex: $selectedTab)
        }
    }
}

#Preview {
    ContentView()
}

