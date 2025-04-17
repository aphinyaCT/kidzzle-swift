//
//  FontHelpers.swift
//  Kidzzle
//
//  Created by aynnipa on 27/2/2568 BE.
//

import SwiftUI

enum FontType {
    case regular, bold, semibold, light, medium
}

func customFont(type: FontType, textStyle: UIFont.TextStyle) -> Font {
    
    let fontMetrics = UIFontMetrics(forTextStyle: textStyle)
    let baseFontSize = UIFont.preferredFont(forTextStyle: textStyle).pointSize
    
    switch type {
    case .regular:
        return Font.custom("NotoSansThai-Regular", size: fontMetrics.scaledValue(for: baseFontSize))
    case .bold:
        return Font.custom("NotoSansThai-Bold", size: fontMetrics.scaledValue(for: baseFontSize))
    case .semibold:
        return Font.custom("NotoSansThai-SemiBold", size: fontMetrics.scaledValue(for: baseFontSize))
    case .light:
        return Font.custom("NotoSansThai-Light", size: fontMetrics.scaledValue(for: baseFontSize))
    case .medium:
        return Font.custom("NotoSansThai-Medium", size: fontMetrics.scaledValue(for: baseFontSize))
    }
}


