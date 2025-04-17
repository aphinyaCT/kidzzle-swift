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
            title: "คู่มือเฝ้าระวังและส่งเสริมพัฒนาการเด็กทั่วไป",
            subtitle: "Developmental Surveillance and Promotion Manual (DSPM)",
            imageURL: "https://res.cloudinary.com/dw7lzqrbz/image/upload/v1743169535/DSPM_wy6lmh.png",
            detail: "คู่มือคัดกรองและประเมินพัฒนาการในเด็กแรก - อายุ 6 ปี รวมถึงให้คำแนะนำและส่งเสริมให้เด็กมีพัฒนาการสมวัย",
            backgroundColor: .deepBlue
        ),
        Manual(
            id: 1,
            title: "คู่มือประเมินและส่งเสริมพัฒนาการเด็กกลุ่มเสี่ยง",
            subtitle: "Developmental Assessment For Intervention Manual (DAIM)",
            imageURL: "https://res.cloudinary.com/dw7lzqrbz/image/upload/v1743169535/DAIM_dex1zs.png",
            detail: "คู่มือคัดกรองและประเมินพัฒนาการเด็กกลุ่มเสี่ยงจากภาวะขาดออกซิเจนหรือน้ำหนักแรกคลอดน้อยกว่า 2500 กรัม",
            backgroundColor: .assetsPurple
        )
    ]

    var manuals: [Manual] {
        Self.manuals
    }
}
