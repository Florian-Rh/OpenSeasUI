//
//  SedimentView.swift
//  OpenSeasUI
//
//  Created by Florian Rhein on 02.05.25.
//

import SwiftUI

public struct Particle: Identifiable {
    public let startPosition: CGPoint
    public let id: Int

    public init(startPosition: CGPoint, id: Int) {
        self.startPosition = startPosition
        self.id = id
    }
}

public struct ParticleView<CustomParticle: View>: View {
    enum AnimationPhase: CaseIterable {
        case start
        case end
        case respawn
    }

    private let updateInterval: TimeInterval
    private let boundingArea: CGRect
    private let vector: CGVector
    private let speed: Double
    private let onPositionChanged: ((CGPoint) -> Void)?
    @ViewBuilder private let customParticleView: CustomParticle
    @State private var currentDestination: CGPoint?
    @State private var animationStartTime: Date?
    @State private var id = UUID()

    /// The point at which the particle first appears
    @State private var startPosition: CGPoint

    /// The point the particle travels to after appearing.
    /// In the bounding area, this is the point where the particle hits the area when following the given vector
    @State private var endPosition: CGPoint

    /// The point at which the particle should respawn after it reached the end position.
    /// In the bounding area, this is the point opposite from the end position in the given direction
    @State private var respawnPosition: CGPoint

    public init(
        particle: Particle,
        inFrame area: CGRect,
        vector: CGVector,
        speed: Double,
        onPositionChanged: ((CGPoint) -> Void)? = nil,
        updateInterval: TimeInterval = 1,
        @ViewBuilder customParticleView: () -> CustomParticle
    ) {
        self.updateInterval = updateInterval
        self.boundingArea = area
        self.vector = vector
        self.speed = speed
        self.customParticleView = customParticleView()
        self.startPosition = particle.startPosition

        self.endPosition = Geometry.intersectionPoint(
            in: boundingArea,
            from: particle.startPosition,
            direction: vector
        )
        self.respawnPosition = Geometry.intersectionPoint(
            in: boundingArea,
            from: particle.startPosition,
            direction: vector.inverted
        )
        self.onPositionChanged = onPositionChanged
    }

    public var body: some View {
        TimelineView(.animation(minimumInterval: updateInterval)) { context in
            self.customParticleView
                .phaseAnimator(
                    AnimationPhase.allCases,
                    content: { view, phase in
                        let destination = getDestination(for: phase)

                        return view
                            .position(destination)
                            .onChange(of: phase) {
                                self.animationStartTime = Date()
                                self.currentDestination = destination
                            }
                    },
                    animation: { phase in
                        let destination = getDestination(for: phase)
                        let duration = calculateDuration(forPosition: destination)

                        return .linear(duration: duration)
                    }
                )
                .onChange(of: vector) {
                    restartAnimationFromCurrentPosition()
                }
                .onChange(of: speed) {
                    restartAnimationFromCurrentPosition()
                }
                .onChange(of: context.date) {
                    if let position = calculateCurrentPosition() {
                        self.onPositionChanged?(position)
                    }
                }
                .id(id)
        }
    }

    private func getDestination(for phase: AnimationPhase) -> CGPoint {
        switch phase {
            case .start:
                self.startPosition
            case .end:
                self.endPosition
            case .respawn:
                self.respawnPosition
        }
    }

    private func calculateDuration(forPosition position: CGPoint) -> Double {
        if position == respawnPosition {
            return 0 // Moving to the respawn position is instantaneous
        }

        let previousPosition = previousPosition(for: position)
        let distance = Geometry.calculateDistance(a: previousPosition, b: position)

        return distance / speed
    }

    private func calculateCurrentPosition() -> CGPoint? {
        guard let currentDestination, let animationStartTime else { return nil }
        let previousPosition = previousPosition(for: currentDestination)
        let duration = calculateDuration(forPosition: currentDestination)
        let approximatePosition = Geometry.calculatePosition(
            between: previousPosition,
            and: currentDestination,
            forTime: Date(),
            startTime: animationStartTime,
            duration: duration
        )

        return approximatePosition
    }

    private func restartAnimationFromCurrentPosition() {
        guard let approximatePosition = calculateCurrentPosition() else { return }
        self.startPosition = approximatePosition
        self.endPosition = Geometry.intersectionPoint(
            in: boundingArea,
            from: approximatePosition,
            direction: vector
        )
        self.respawnPosition = Geometry.intersectionPoint(
            in: boundingArea,
            from: approximatePosition,
            direction: vector.inverted
        )
        self.id = UUID()
    }

    private func previousPosition(for destination: CGPoint) -> CGPoint {
        switch destination {
            case endPosition: return startPosition
            case respawnPosition: return endPosition
            case startPosition: return respawnPosition
            default: return startPosition
        }
    }
}
