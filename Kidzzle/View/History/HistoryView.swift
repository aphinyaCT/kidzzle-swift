//
//  HistoryView.swift
//  Kidzzle
//
//  Created by aynnipa on 5/4/2568 BE.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    var body: some View {
        ZStack {
            Text("Test")
        }
        .toast(isShowing: $authViewModel.showLoginSuccessToast, toastCase: .loginSuccess, duration: 1.5)
    }
}

#Preview {
    HistoryView()
}
