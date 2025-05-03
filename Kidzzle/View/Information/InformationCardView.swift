//
//  InformationCardView.swift
//  Kidzzle
//
//  Created by aynnipa on 3/5/2568 BE.
//

import SwiftUI

struct InformationCardView: View {
    let info: Information
    @ObservedObject var viewModel: InformationViewModel
    
    var body: some View {
        Button(action: {
            viewModel.openPDF(for: info)
        }) {
            VStack(spacing: 0) {
                Text(info.title)
                    .font(customFont(type: .bold, textStyle: .body))
                    .lineLimit(2, reservesSpace: true)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                
                Spacer()
                
                Image(systemName: viewModel.iconName(for: info.id))
                    .font(.system(size: 96))
                    .foregroundColor(viewModel.iconColor(for: info.id))
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    if viewModel.isLoading(for: info.id) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                            .frame(width: 40, height: 40)
                            .background(Color.white)
                            .clipShape(Rectangle())
                            .cornerRadius(10)
                    } else {
                        Image(systemName: "eye")
                            .font(.system(size: 16))
                            .foregroundColor(.jetblack)
                            .padding()
                            .frame(width: 40, height: 40)
                            .background(Color.white)
                            .clipShape(Rectangle())
                            .cornerRadius(10)
                    }
                }
                .disabled(viewModel.isLoading(for: info.id))
            }
            .padding()
            .frame(height: 260)
            .frame(maxWidth: .infinity)
            .background(viewModel.backgroundColor(for: info.id))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(viewModel.isLoading(for: info.id))
        .fullScreenCover(isPresented: $viewModel.showPDFViewer) {
            if let url = viewModel.selectedPDFURL {
                NavigationView {
                    PDFViewerView(
                        url: url,
                        title: viewModel.selectedPDFTitle ?? "PDF Viewer",
                        onDismiss: { viewModel.showPDFViewer = false }
                    )
                }
            }
        }
    }
}
