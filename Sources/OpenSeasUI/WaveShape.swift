//
//  WaveShape.swift
//  OpenSeasUI
//
//  Created by Florian Rhein on 27.03.25.
//

import SwiftUI

public struct WaveShape: Shape {
    let amplitude: CGFloat
    let waveLength: CGFloat
    let waterLevel: CGFloat
    private(set) var phase: CGFloat = 0.0

    public var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let midHeight = (rect.height + amplitude * 2) * (1 - waterLevel) - amplitude
        let width = rect.width

        path.move(to: CGPoint(x: 0, y: midHeight))

        for xPoint in stride(from: 0, to: width+1, by: 1) {
            let relativeX = xPoint / width
            let sine = sin(relativeX * (1 / waveLength) * .pi + phase)
            let yPoint = midHeight + amplitude * sine
            path.addLine(to: CGPoint(x: xPoint, y: yPoint))
        }

        path.addLine(to: CGPoint(x: width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()

        return path
    }
}


#Preview {
    WaveShape(amplitude: 10, waveLength: 0.1, waterLevel: 0.5)
        .border(.red)
//        .fill(LinearGradient(gradient: .coralSunsetGradient, startPoint: .top, endPoint: .bottom))
        .ignoresSafeArea()
}
