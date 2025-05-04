//
//  CarouselViewModel.swift
//  Kidzzle
//
//  Created by aynnipa on 15/4/2568 BE.
//

import SwiftUI
import Combine

class CarouselViewModel: ObservableObject {
    @Published var currentIndex: Int = 0

    static let manuals: [Manual] = [
        Manual(
            id: 0,
            title: "สิทธิการรักษาเพิ่มเติมกับโค้งแรก “30 บาทรักษาทุกที่",
            icon: "syringe",
            imageURL: "https://multimedia.anamai.moph.go.th/oawoocha/2024/09/info758_Health_2.jpg",
            linkURL: "https://multimedia.anamai.moph.go.th/infographics/info758_health_2/"
        ),
        Manual(
            id: 1,
            title: "โภชนาการที่ดี จะกี่ปีก็แข็งแรง",
            icon: "diet",
            imageURL: "https://multimedia.anamai.moph.go.th/oawoocha/2024/01/info632_child_9-scaled.jpg",
            linkURL: "https://multimedia.anamai.moph.go.th/infographics/info620_run_4-2-2/"
        ),
        Manual(
            id: 2,
            title: "สิทธิสุขภาพสำหรับหญิงตั้งครรภ์",
            icon: "prenatal-care",
            imageURL: "https://multimedia.anamai.moph.go.th/oawoocha/2024/09/info759_pregnant_24.jpg",
            linkURL: "https://multimedia.anamai.moph.go.th/infographics/info759_pregnant_24/"
        )
    ]

    var manuals: [Manual] {
        Self.manuals
    }
}
