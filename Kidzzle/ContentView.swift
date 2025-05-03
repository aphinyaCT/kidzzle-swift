//
//  ContentView.swift
//  Kidzzle
//
//  Created by aynnipa on 4/4/2568 BE.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var motherViewModel: MotherPregnantViewModel
    @StateObject private var kidViewModel: KidHistoryViewModel

    init() {
        let authVM = AuthViewModel()
        let motherVM = MotherPregnantViewModel(authViewModel: authVM)
        let kidVM = KidHistoryViewModel(
            authViewModel: authVM,
            motherViewModel: motherVM
        )
        
        _authViewModel = StateObject(wrappedValue: authVM)
        _motherViewModel = StateObject(wrappedValue: motherVM)
        _kidViewModel = StateObject(wrappedValue: kidVM)
    }
    
    @State private var isLoggedIn = false
    @State private var showChildDevelopment = false
    @State private var showForgotPassword = false
    @State private var isSubmitting = false
    
    var body: some View {
        Group {
            if isLoggedIn {
                MainTabView(
                    isLoggedIn: $isLoggedIn,
                    motherViewModel: motherViewModel,
                    kidViewModel: kidViewModel
                )
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
            authViewModel.checkAuthStatus()
            isLoggedIn = authViewModel.isAuthenticated
        }
        .onChange(of: authViewModel.isAuthenticated) { _, newValue in
            isLoggedIn = newValue
        }
        .toast(isShowing: $authViewModel.showTokenExpiredToast, toastCase: .tokenExpired, duration: 2.0)
    }
}

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    @Binding var isLoggedIn: Bool
    @State private var hasLoaded = false
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var motherViewModel: MotherPregnantViewModel
    @ObservedObject var kidViewModel: KidHistoryViewModel

    var body: some View {
        VStack(spacing: 0) {
            switch selectedTab {
            case 0:
                HistoryView()
                    .environmentObject(authViewModel)
            case 1:
                ChildDevelopmentMainView(
                    authViewModel: authViewModel,
                    motherViewModel: motherViewModel,
                    kidViewModel: kidViewModel
                )
            case 2:
                PromotionView()
            case 3:
                BenefitView()
            case 4:
                InformationView()
            default:
                EmptyView(message: "404 Error")
            }
            
            Spacer()
            
            CustomTabBarView(selectedIndex: $selectedTab)
        }
        .task {
            if !hasLoaded {
                await loadData()
                hasLoaded = true
            }
        }
    }
    
    private func loadData() async {
        await motherViewModel.fetchMotherPregnant()
        
        if !motherViewModel.motherPregnantDataList.isEmpty {
            for pregnant in motherViewModel.motherPregnantDataList {
                await kidViewModel.fetchKidHistoryIfNeeded(pregnantId: pregnant.id)
            }
            
            await MainActor.run {
                selectedTab = 1
            }
        }
    }
}

#Preview {
    ContentView()
}
