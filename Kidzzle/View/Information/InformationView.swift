//
//  InformationView.swift
//  Kidzzle
//
//  Created by aynnipa on 17/3/2568 BE.
//

import SwiftUI

struct InformationView: View {
    
    @StateObject var viewModel = InformationViewModel()
    
    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        ZStack {
            Color.ivorywhite
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                Text("ความรู้ทั่วไปของมารดาและบุตร")
                    .font(customFont(type: .bold, textStyle: .title2))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 20)
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(viewModel.information) { info in
                        InformationCardView(info: info, viewModel: viewModel)
                            .onTapGesture {
                                if let url = info.infoURL {
                                    print("เปิดไฟล์ PDF: \(url)")
                                }
                            }
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 20)
            .padding(.horizontal, 20)
        }
    }
}

struct InformationCardView: View {
    let info: Information
    @ObservedObject var viewModel: InformationViewModel
    
    var body: some View {
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

            Button(action: {
                viewModel.openPDF(for: info)
            }, label: {
                if viewModel.isLoading(for: info.id) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .jetblack))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "eye")
                        .font(.system(size: 16))
                        .foregroundColor(.jetblack)
                }
            })
            .padding()
            .frame(width: 40, height: 40)
            .background(Color.white)
            .clipShape(Rectangle())
            .cornerRadius(10)
            .frame(maxWidth: .infinity, alignment: .trailing)
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
        .padding()
        .frame(height: 280)
        .frame(maxWidth: .infinity)
        .background(viewModel.backgroundColor(for: info.id))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    InformationView()
}
