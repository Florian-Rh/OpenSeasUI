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
        waterLevel: CGFloat = 0.5,
        phase: CGFloat = 0.0,
        rotation: CGFloat = 0.0
    ) {
        self.amplitude = amplitude

        // Wave length is a divisor in the sine function and must be bigger then zero
        self.waveLength = max(waveLength, CGFloat.leastNormalMagnitude)
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
        let width = rect.width

        // Calculate how much longer the waves need to be in order to
        // fill the entire rectangle, if the surface line is rotated
        let hypothenuse = hypot(rect.width, rect.height)
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

        // Close the area under the wave
        path.addLine(to: CGPoint(x: endX, y: hypothenuse))
        path.addLine(to: CGPoint(x: startX, y: hypothenuse))
        path.closeSubpath()

        // Rotate the top water line
        path = path
            .rotation(.radians(rotation), anchor: .center)
            .path(in: rect)

        // Translate to the desired water level
        // - Adding or substracting the height of the amplitude,
        //   so waterLevel of 1.0 covers everything, and 0.0 covers nothing
        // - Accounting for rotation by multiplying with cos (vertical axis)
        //   or sin (horizontal axis)
        let amplitudeModifier = (waterLevel * 2 - 1) * amplitude
        let vBaseOffset = (rect.height * (1-waterLevel))
        let vTranslation = (vBaseOffset - amplitudeModifier) * cos(rotation)

        let hBaseOffset = (rect.width * waterLevel) - (rect.width + rect.height) / 2
        let hTranslation = (hBaseOffset + amplitudeModifier) * sin(rotation)

        path = path
            .transform(.init(translationX: hTranslation, y: vTranslation))
            .path(in: rect)

        // Truncate anything outside the bounding rectangle
        let box = Path(rect)
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
