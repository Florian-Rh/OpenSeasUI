//
//  SedimentView.swift
//  OpenSeasUI
//
//  Created by Florian Rhein on 02.05.25.
//

import SwiftUI

fileprivate struct AnimationPhase: Equatable {
    let destination: CGPoint
    let origin: CGPoint
    let duration: Double
}

public struct ParticleView<CustomParticle: View>: View {
    private let positionUpdateInterval: TimeInterval
    private let boundingArea: CGRect
    private let vector: CGVector
    private let speed: Double
    private let onPositionChanged: ((CGPoint) -> Void)?
    @ViewBuilder private let customParticleView: CustomParticle
    @State private var currentPhase: AnimationPhase?
    @State private var animationStartTime: Date?
    @State private var id = UUID()

    @State private var animationPhases: [AnimationPhase]

    public init(
        startPosition: CGPoint,
        inFrame area: CGRect,
        vector: CGVector,
        speed: Double,
        onPositionChanged: ((CGPoint) -> Void)? = nil,
        positionUpdateInterval: TimeInterval = 1,
        @ViewBuilder customParticleView: () -> CustomParticle
    ) {
        self.positionUpdateInterval = positionUpdateInterval
        self.boundingArea = area
        self.vector = vector
        self.speed = speed
        self.customParticleView = customParticleView()

        self.onPositionChanged = onPositionChanged

        self.animationPhases = .init(
            inFrame: area,
            from: startPosition,
            vector: vector,
            speed: speed
        )
    }

    public var body: some View {
        TimelineView(.animation(minimumInterval: positionUpdateInterval)) { context in
            self.customParticleView
                .phaseAnimator(
                    self.animationPhases,
                    content: { view, phase in
                        view
                            .position(phase.destination)
                            .onChange(of: phase) {
                                self.animationStartTime = Date()
                                self.currentPhase = phase
                            }
                    },
                    animation: { phase in
                        .linear(duration: phase.duration)
                    }
                )
                .onChange(of: vector, restartAnimationFromCurrentPosition)
                .onChange(of: speed, restartAnimationFromCurrentPosition)
                .onChange(of: context.date) {
                    if let position = calculateCurrentPosition() {
                        self.onPositionChanged?(position)
                    }
                }
                .id(id)
        }
    }

    private func calculateCurrentPosition() -> CGPoint? {
        guard let currentPhase, let animationStartTime else { return nil }
        let approximatePosition = Geometry.calculatePosition(
            between: currentPhase.origin,
            and: currentPhase.destination,
            forTime: Date(),
            startTime: animationStartTime,
            duration: currentPhase.duration
        )

        return approximatePosition
    }

    private func restartAnimationFromCurrentPosition() {
        guard let startPosition = calculateCurrentPosition() else { return }
        self.animationPhases = .init(
            inFrame: boundingArea,
            from: startPosition,
            vector: vector,
            speed: speed
        )
        self.id = UUID()
    }
}

extension Array where Element == AnimationPhase {
    fileprivate init(inFrame area: CGRect, from startPosition: CGPoint, vector: CGVector, speed: Double) {
        let endPosition = Geometry.intersectionPoint(
            in: area,
            from: startPosition,
            direction: vector
        )
        let respawnPosition = Geometry.intersectionPoint(
            in: area,
            from: startPosition,
            direction: vector.inverted
        )

        let distanceToStart = Geometry.calculateDistance(a: respawnPosition, b: startPosition)
        let distanceToEnd = Geometry.calculateDistance(a: startPosition, b: endPosition)

        self.init(
            [
                .init(destination: startPosition, origin: respawnPosition, duration: distanceToStart / speed),
                .init(destination: endPosition, origin: startPosition, duration: distanceToEnd / speed),
                .init(destination: respawnPosition, origin: endPosition, duration: 0),
            ]
        )
    }
}
