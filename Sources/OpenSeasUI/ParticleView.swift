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

    private let boundingArea: CGRect
    private let vector: CGVector
    private let speed: Double
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
        @ViewBuilder customParticleView: () -> CustomParticle
    ) {
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
    }

    public var body: some View {
        self.customParticleView
            .phaseAnimator(
                AnimationPhase.allCases,
                content: { view, phase in
                    let position = getPosition(for: phase)

                    return view
                        .position(position)
                        .onChange(of: phase) {
                            self.animationStartTime = Date()
                            self.currentDestination = position
                        }
                },
                animation: { phase in
                    let position = getPosition(for: phase)
                    let duration = calculateDuration(forPosition: position)

                    return .linear(duration: duration)
                }
            )
            .onChange(of: vector) {
                restartAnimationFromCurrentPosition()
            }
            .onChange(of: speed) {
                restartAnimationFromCurrentPosition()
            }
            .id(id)
    }

    private func getPosition(for phase: AnimationPhase) -> CGPoint {
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

    private func restartAnimationFromCurrentPosition() {
        guard let currentDestination, let animationStartTime else { return }
        let previousPosition = previousPosition(for: currentDestination)
        let duration = calculateDuration(forPosition: currentDestination)
        let approximatePosition = Geometry.calculatePosition(
            between: previousPosition,
            and: currentDestination,
            forTime: Date(),
            startTime: animationStartTime,
            duration: duration
        )
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
