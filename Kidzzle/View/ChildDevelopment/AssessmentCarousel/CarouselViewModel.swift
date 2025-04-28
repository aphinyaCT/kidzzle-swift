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
            imageURL: "https://res.cloudinary.com/dw7lzqrbz/image/upload/v1745577489/KIDZZLE-CAROUSEL-2_ny8xkf.png"
        ),
        Manual(
            id: 1,
            imageURL: "https://res.cloudinary.com/dw7lzqrbz/image/upload/v1745578132/KIDZZLE-CAROUSEL-1_wddhvn.png"
        ),
    ]

    var manuals: [Manual] {
        Self.manuals
    }
}
