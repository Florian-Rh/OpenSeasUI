//
//  SedimentView.swift
//  OpenSeasUI
//
//  Created by Florian Rhein on 02.05.25.
//

import SwiftUI

private struct AnimationPhase: Equatable {
    enum Phase {
        case start, end, respawn
    }
    let destination: CGPoint
    let origin: CGPoint
    let duration: Double
    let phase: Phase
}

public struct FrameHitBehavior {
    enum Behavior {
        case wrapAround
        case bounceOff
        case disappear
    }

    internal let behavior: Behavior
    internal private(set) var onFrameHit: ((CGPoint, Edge) -> Void)?

    public static var wrapAround: FrameHitBehavior {
        .init(behavior: .wrapAround, onFrameHit: nil)
    }

    public static var bounceOff: FrameHitBehavior {
        .init(behavior: .bounceOff, onFrameHit: nil)
    }

    public static var disappear: FrameHitBehavior {
        .init(behavior: .disappear, onFrameHit: nil)
    }

    private init(behavior: Behavior, onFrameHit: ((CGPoint, Edge) -> Void)?) {
        self.behavior = behavior
        self.onFrameHit = onFrameHit
    }

    public func onFrameHit(
        execute closure: @escaping (CGPoint, Edge) -> Void
    ) -> FrameHitBehavior {
        .init(behavior: self.behavior, onFrameHit: closure)
    }
}

public struct ParticleView<CustomParticle: View>: View {
    // MARK: - Arguments
    private let startPosition: CGPoint
    private let boundingArea: CGRect
    @Binding private var vector: CGVector
    private let frameHitBehavior: FrameHitBehavior
    private let onPositionUpdated: ((CGPoint) -> Void)?
    private let positionUpdateInterval: TimeInterval
    @ViewBuilder private let customParticleView: CustomParticle

    // MARK: - States
    @State private var currentPhase: AnimationPhase?
    @State private var animationStartTime: Date?
    @State private var isVisible = true
    @State private var id = UUID()
    @State private var animationPhases: [AnimationPhase]

    public init(
        startPosition: CGPoint,
        inFrame area: CGRect,
        vector: Binding<CGVector>,
        frameHitBehavior: FrameHitBehavior = .wrapAround,
        onPositionUpdated: ((CGPoint) -> Void)? = nil,
        positionUpdateInterval: TimeInterval = 1,
        @ViewBuilder customParticleView: () -> CustomParticle
    ) {
        self.startPosition = startPosition
        self.boundingArea = area
        self._vector = vector
        self.frameHitBehavior = frameHitBehavior
        self.onPositionUpdated = onPositionUpdated
        self.positionUpdateInterval = positionUpdateInterval
        self.customParticleView = customParticleView()

        self.animationPhases = .init(
            inFrame: area,
            from: startPosition,
            vector: vector.wrappedValue,
            frameHitBehavior: frameHitBehavior
        )
    }

    public var body: some View {
        if isVisible {
            TimelineView(.animation(minimumInterval: positionUpdateInterval)) { context in
                self.customParticleView
                    .phaseAnimator(
                        self.animationPhases,
                        content: { view, phase in
                            view
                                .position(phase.destination)
                                .onChange(of: phase) { oldValue, newValue in
                                    if case .end = oldValue.phase {
                                        switch frameHitBehavior.behavior {
                                        case .wrapAround:
                                            break
                                        case .bounceOff:
                                            vector.bounce(
                                                off: self.boundingArea,
                                                at: oldValue.destination
                                            )
                                            restartAnimationFromCurrentPosition()
                                        case .disappear:
                                            isVisible = false
                                        }
                                        if let onFrameHit = frameHitBehavior.onFrameHit {
                                            let distanceToEdges = [
                                                (abs(phase.origin.x - boundingArea.minX), Edge.leading),
                                                (abs(phase.origin.x - boundingArea.maxX), Edge.trailing),
                                                (abs(phase.origin.y - boundingArea.minY), Edge.top),
                                                (abs(phase.origin.y - boundingArea.maxY), Edge.bottom),
                                            ]

                                            let edge: Edge = distanceToEdges
                                                .min(by: { $0.0 < $1.0 })
                                                .map(\.1)!

                                            onFrameHit(phase.origin, edge)
                                        }
                                    }

                                    self.animationStartTime = Date()
                                    self.currentPhase = phase
                                }
                        },
                        animation: { phase in
                            .linear(duration: phase.duration)
                        }
                    )
                    .onChange(of: vector, restartAnimationFromCurrentPosition)
                    .onChange(of: context.date) {
                        if let position = calculateCurrentPosition() {
                            self.onPositionUpdated?(position)
                        }
                    }
                    .id(id)
            }
        } else {
            EmptyView()
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
            frameHitBehavior: frameHitBehavior
        )
        self.id = UUID()
    }
}

extension Array where Element == AnimationPhase {
    fileprivate init(
        inFrame area: CGRect,
        from startPosition: CGPoint,
        vector: CGVector,
        frameHitBehavior: FrameHitBehavior
    ) {
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

        let distanceToStart = Geometry.calculateDistance(
            a: respawnPosition,
            b: startPosition
        )
        let distanceToEnd = Geometry.calculateDistance(
            a: startPosition,
            b: endPosition
        )
        let durationToStart =
            vector.magnitude > 0 ? distanceToStart / vector.magnitude : 0
        let durationToEnd =
            vector.magnitude > 0 ? distanceToEnd / vector.magnitude : 0

        let phases: [AnimationPhase] = [
            .init(
                destination: startPosition,
                origin: respawnPosition,
                duration: durationToStart,
                phase: .start
            ),
            .init(
                destination: endPosition,
                origin: startPosition,
                duration: durationToEnd,
                phase: .end
            ),
            .init(
                destination: respawnPosition,
                origin: endPosition,
                duration: 0,
                phase: .respawn
            ),
        ]

        self.init(phases)
    }
}


struct PreviewView: View {
    @State var vector = CGVector(dx: 1.0, dy: 1.3).scaled(by: 100)
    @State var startPosition = CGPoint(x: 50, y: 50)
    @State var id = UUID()

    var body: some View {
        ZStack {
            GeometryReader { reader in
                Color.black
                ParticleView(
                    startPosition: startPosition,
                    inFrame: reader.frame(in: .local),
                    vector: $vector,
                    frameHitBehavior: .bounceOff.onFrameHit { point, edge in
                        if edge == .leading {
                            print("leading edge hit, teleporting ")
                            startPosition = .init(x: reader.frame(in: .local).maxX, y: point.y)
                            vector.dx *= -1
                            id = UUID()
                        }

                        if edge == .trailing {
                            print("trailing edge hit, teleporting ")
                            startPosition = .init(x: reader.frame(in: .local).minX, y: point.y)
                            vector.dx *= -1
                            id = UUID()
                        }
                    },
                    positionUpdateInterval: 0.2
                ) {
                    Circle()
                        .foregroundStyle(.white)
                        .frame(width: 15, height: 15)
                }
                .id(id)
            }
            .frame(width: 300, height: 300)
        }
    }
}

#Preview {
    PreviewView()
}

