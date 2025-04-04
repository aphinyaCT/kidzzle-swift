//
//  InformationViewModel.swift
//  Kidzzle
//
//  Created by aynnipa on 17/3/2568 BE.
//

import Foundation
import SwiftUI
import PDFKit

class InformationViewModel: NSObject, ObservableObject {
    
    @Published var selectedPDFURL: URL?
    @Published var showPDFViewer = false
    @Published var selectedPDFTitle: String?
    @Published var isLoading = false
    @Published var loadingStates: [String: Bool] = [:]
    
    let information: [Information] = [
        Information(id: "1",
                    title: "วัคซีนเด็กปฐมวัย",
                    infoURL: URL(string:"https://ddc.moph.go.th/uploads/publish/1510320231225092421.pdf")
                   ),
        Information(id: "2",
                    title: "คู่มือมารดาหลังคลอด",
                    infoURL: URL(string: "https://thailand.unfpa.org/sites/default/files/pub-pdf/PP_Handbook.pdf")
                   ),
        Information(id: "3",
                    title: "โภชนาการสำหรับเด็กอายุ 2 - 5 ปี",
                    infoURL: URL(string: "https://nutrition2.anamai.moph.go.th/th/book/download/?did=217683&id=120995&reload=")
                   ),
        Information(id: "4",
                    title: "อุปกรณ์ ของเล่น ส่งเสริมพัฒนาการ",
                    infoURL: URL(string: "https://th.rajanukul.go.th/_admin/file-download/5-4535-1449802545.pdf")
                   )
    ]
    
    func isLoading(for infoID: String) -> Bool {
        return loadingStates[infoID] == true
    }
    
    func openPDF(for info: Information) {
        let infoID = info.id
        guard let urlString = info.infoURL?.absoluteString,
              let url = URL(string: urlString) else {
            return
        }
        
        loadingStates[infoID] = true
        self.objectWillChange.send()

        if url.scheme == "http" || url.scheme == "https" {
            let task = URLSession.shared.downloadTask(with: url) { [weak self] tempLocalURL, response, error in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    
                    if let error = error {
                        print("Error downloading PDF: \(error.localizedDescription)")
                        self.loadingStates[infoID] = false
                        self.objectWillChange.send()
                        return
                    }
                    
                    guard let tempLocalURL = tempLocalURL else {
                        self.loadingStates[infoID] = false
                        self.objectWillChange.send()
                        return
                    }
                    
                    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let destinationURL = documentsPath.appendingPathComponent("downloaded.pdf")
                    
                    try? FileManager.default.removeItem(at: destinationURL)
                    
                    do {
                        try FileManager.default.copyItem(at: tempLocalURL, to: destinationURL)
                        self.selectedPDFURL = destinationURL
                        self.selectedPDFTitle = info.title
                        self.loadingStates[infoID] = false
                        self.objectWillChange.send()
                        self.showPDFViewer = true
                    } catch {
                        print("Error saving PDF: \(error.localizedDescription)")
                        self.loadingStates[infoID] = false
                        self.objectWillChange.send()
                    }
                }
            }
            
            task.resume()
        } else {
            DispatchQueue.main.async {
                self.selectedPDFURL = url
                self.selectedPDFTitle = info.title
                self.loadingStates[infoID] = false
                self.objectWillChange.send()
                self.showPDFViewer = true
            }
        }
    }
    
    let backgroundColors: [String: Color] = [
        "1": Color.softPink,
        "2": Color.sunYellow,
        "3": Color.greenMint,
        "4": Color.assetsPurple
    ]
    
    let iconColors: [String: Color] = [
        "1": Color.deepBlue,
        "2": Color.greenMint,
        "3": Color.sunYellow,
        "4": Color.coralRed
    ]
    
    let sfIcon: [String: String] = [
        "1": "syringe.fill",
        "2": "heart.text.clipboard",
        "3": "carrot",
        "4": "basketball"
    ]
    
    func backgroundColor(for id: String) -> Color {
        return backgroundColors[id] ?? .gray.opacity(0.2)
    }
    
    func iconColor(for id: String) -> Color {
        return iconColors[id] ?? .gray
    }
    
    func iconName(for id: String) -> String {
        return sfIcon[id] ?? "text.page.fill"
    }
}


struct PDFViewer: UIViewRepresentable {
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
