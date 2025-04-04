//
//  PromotionviewModel.swift
//  Kidzzle
//
//  Created by aynnipa on 18/3/2568 BE.
//

import Foundation

class PromotionViewModel: NSObject, ObservableObject {
    let promotion: [Promotion] = [
        Promotion(id: "1",
                  title: "กิจกรรมสีแสนสนุก",
                  textWarning: "เหมาะสำหรับเด็กที่มีอายุ 2 ปีขึ้นไป",
                  sfIcon: "paintpalette.fill"),
        Promotion(id: "2",
                  title: "กิจกรรมอวัยวะอะไรเอ่ย?",
                  textWarning: "เหมาะสำหรับเด็กที่มีอายุ 2 ปีขึ้นไป",
                  sfIcon: "figure")
    ]
}
