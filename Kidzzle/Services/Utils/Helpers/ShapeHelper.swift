//
//  View.swift
//  Kidzzle
//
//  Created by aynnipa on 6/3/2568 BE.
//

import SwiftUI

// MARK: Custom Shape
struct CustomShape : Shape {
    func path(in rect: CGRect) -> Path {
        return Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
        }
    }
}

// MARK: Corners
struct Corners : Shape {
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 32, height: 32))
        
        return Path(path.cgPath)
    }
}
