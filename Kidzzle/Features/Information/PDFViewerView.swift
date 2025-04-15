//
//  PDFViewerView.swift
//  Kidzzle
//
//  Created by aynnipa on 22/3/2568 BE.
//

import SwiftUI
import PDFKit

struct PDFViewerView: View {
    let url: URL
    let title: String
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.ivorywhite.edgesIgnoringSafeArea(.all)
            
            PDFKitView(url: url)
                .edgesIgnoringSafeArea(.bottom)
        }
        .navigationBarItems(leading:
            Button(action: onDismiss) {
                Image(systemName: "arrow.backward")
                    .foregroundColor(.jetblack)
            }
        )
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(title)
                    .font(customFont(type: .bold, textStyle: .body))
                    .foregroundColor(.jetblack)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.ivorywhite, for: .navigationBar)
    }
}

struct PDFKitView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: url)
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = PDFDocument(url: url)
    }
}
