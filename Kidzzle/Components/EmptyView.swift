//
//  EmptyView.swift
//  Kidzzle
//
//  Created by aynnipa on 14/4/2568 BE.
//

import SwiftUI

struct EmptyView: View {
    let message: String
    
    var body: some View {
        VStack {
            Spacer()
            
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.gray)
                .padding()
            
            Text(message)
                .font(customFont(type: .regular, textStyle: .body))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
}
