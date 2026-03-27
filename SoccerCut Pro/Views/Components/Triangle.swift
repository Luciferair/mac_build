//
//  Triangle.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/05/31.
//

import SwiftUI

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
        }
    }

}

struct Triangle_Previews: PreviewProvider {
    static var previews: some View {
        Triangle()
    }
}
