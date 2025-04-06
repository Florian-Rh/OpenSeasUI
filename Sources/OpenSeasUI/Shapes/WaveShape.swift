//
//  WaveShape.swift
//  OpenSeasUI
//
//  Created by Florian Rhein on 27.03.25.
//

import SwiftUI

public struct WaveShape: Shape {
    private let amplitude: CGFloat
    private let waveLength: CGFloat
    private let waterLevel: CGFloat
    private(set) var phase: CGFloat = 0.0
    private let rotation: CGFloat

    public init(
        amplitude: CGFloat,
        waveLength: CGFloat,
        waterLevel: CGFloat,
        phase: CGFloat = 0.0 * .pi,
        rotation: CGFloat = 0.0
    ) {
        self.amplitude = amplitude
        self.waveLength = waveLength
        self.waterLevel = waterLevel
        self.phase = phase
        self.rotation = rotation
    }

    public var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let midHeight = rect.height / 2
        let width = rect.width

        // Calculate how much longer the waves need to be in order to fill the entire rectangle, if the surface line is rotated
        let baseLength = width / 2
        let hypothenuse = baseLength / cos(rotation)
        let rotationElongation = (hypothenuse - baseLength) + amplitude * 2
        let startX: CGFloat = 0.0 - rotationElongation
        let endX: CGFloat = width + rotationElongation

        path.move(to: CGPoint(x: startX, y: midHeight))
        for xPoint in stride(from: startX, to: endX, by: 1) {
            let relativeX = xPoint / width
            let sine = sin(relativeX * (1 / waveLength) * .pi + phase)
            let yPoint = midHeight + amplitude * sine
            path.addLine(to: CGPoint(x: xPoint, y: yPoint))
        }

        path = path.rotation(.radians(rotation)).path(in: rect)
        let verticalTranslation = rect.height * (1 - waterLevel) - midHeight
        path = path.transform(.init(translationX: 0, y: verticalTranslation)).path(in: rect)
        path.addLine(to: CGPoint(x: width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        let box = Path(roundedRect: rect, cornerRadius: 0.0)

        return path.intersection(box)
    }
}


#Preview {
    WaveShape(
        amplitude: 10,
        waveLength: 0.1,
        waterLevel: 0.5,
        phase: 0.0,
        rotation: 0.0
    )
    .ignoresSafeArea()
}
