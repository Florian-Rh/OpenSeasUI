//
//  WaveShape.swift
//  OpenSeasUI
//
//  Created by Florian Rhein on 27.03.25.
//

import SwiftUI

internal struct WaveShape: Shape {
    private let amplitude: CGFloat
    private let waveLength: CGFloat
    private let waterLevel: CGFloat
    private(set) var phase: CGFloat = 0.0
    private let rotation: CGFloat

    internal init(
        amplitude: CGFloat,
        waveLength: CGFloat,
        waterLevel: CGFloat = 0.5,
        phase: CGFloat = 0.0,
        rotation: CGFloat = 0.0
    ) {
        self.amplitude = amplitude

        // Wave length is a divisor in the sine function and must be bigger then zero
        self.waveLength = max(waveLength, CGFloat.leastNormalMagnitude)
        self.waterLevel = waterLevel
        self.phase = phase

        // Rotation is only defined between -.pi/4 and .pi/4 (or -45° and 45°).
        self.rotation = min(max(rotation, -(.pi / 4)), .pi / 4)
    }

    internal var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    internal func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width

        // Calculate how much longer the waves need to be in order to fill the entire rectangle, if the surface line is rotated
        let hypothenuse = width / cos(rotation)
        let rotationElongation = (hypothenuse - width) + amplitude
        let startX: CGFloat = 0.0 - rotationElongation
        let endX: CGFloat = width + rotationElongation

        // Draw the sine curve
        path.move(to: CGPoint(x: startX, y: 0.0))
        for xPoint in stride(from: startX, to: endX, by: 1) {
            let relativeX = xPoint / width
            let sine = sin(relativeX * (1 / waveLength) * .pi + phase)
            let yPoint = amplitude * sine
            path.addLine(to: CGPoint(x: xPoint, y: yPoint))
        }

        // Rotate the top water line
        path = path
            .rotation(.radians(rotation), anchor: .top)
            .path(in: rect)

        // Translate to the desired water level
        let verticalTranslation = rect.height * (1 - waterLevel)
        path = path
            .transform(.init(translationX: 0, y: verticalTranslation))
            .path(in: rect)

        // Fill the area under the water line
        path.addLine(to: CGPoint(x: width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()

        // Truncate anything outside the bounding rectangle
        let box = Path(roundedRect: rect, cornerRadius: 0.0)
        path = path.intersection(box)

        return path
    }
}


#Preview {
    WaveShape(
        amplitude: 10,
        waveLength: 0.1,
        waterLevel: 0.5,
        phase: 2 * .pi,
        rotation: 0.0
    )
    .frame(width: 250, height: 250)
    .border(.red)
    .ignoresSafeArea()
}
