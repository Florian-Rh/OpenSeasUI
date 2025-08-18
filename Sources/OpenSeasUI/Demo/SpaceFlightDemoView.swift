//
//  SwiftUIView.swift
//  OpenSeasUI
//
//  Created by Florian Rhein on 25.07.25.
//

import SwiftUI

struct SpaceFlightDemoView: View {
    struct Star: Identifiable {
        let startPosition: CGPoint
        let id: Int
    }

    private enum WarpState {
        case inactive
        case poweringUp
        case active
        case poweringDown

        var warpButtonLabel: String {
            switch self {
            case .inactive:
                "Activate warp drive"
            case .poweringUp:
                "Powering up..."
            case .active:
                "Deactive warp drive"
            case .poweringDown:
                "Powering down..."
            }
        }

        var warpButtonDisabled: Bool {
            switch self {
            case .inactive, .active:
                return false
            case .poweringUp, .poweringDown:
                return true
            }
        }

        var warpStarFieldVisibility: Double {
            switch self {
            case .inactive:
                0.0
            case .poweringUp, .active, .poweringDown:
                1.0
            }
        }

        var warpScaleEffect: Double {
            switch self {
            case .active, .poweringDown:
                0.98
            case .poweringUp, .inactive:
                1.0
            }
        }

        var warpRotationEffect: Angle {
            switch self {
            case .active, .poweringDown:
                .degrees(3.5)
            case .poweringUp, .inactive:
                .zero
            }
        }
    }

    private enum JoystickState {
        case tutorial
        case idle
        case inUse

        var tutorialGuideOpacity: Double {
            self == .tutorial ? 1.0 : 0.0
        }

        var visualGuideOpacity: Double {
            switch self {
            case .tutorial:
                1.0
            case .idle:
                0.2
            case .inUse:
                0.4
            }
        }
    }

    @State private var stars: [Star] = []
    @State private var speed: Double = 25.0
    @State private var direction: Angle = .degrees(0)
    @State private var warpState: WarpState = .inactive
    @State private var joystickState: JoystickState = .tutorial

    private let numberOfParticles = 50
    private let maxSpeed = 200.0

    private var joystickOffset: Double {
        speed / 4
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.black
                ForEach(stars) { star in
                    ParticleView(
                        startPosition: star.startPosition,
                        inFrame: proxy.frame(in: .local),
                        vector: .init(from: direction).inverted.scaled(by: speed)
                    ) {
                        Circle()
                            .frame(width: 2, height: 2)
                            .foregroundStyle(.white)
                    }
                    ParticleView(
                        startPosition: star.startPosition,
                        inFrame: proxy.frame(in: .local),
                        vector: .init(from: direction).inverted.scaled(by: speed)
                    ) {
                        Circle()
                            .frame(width: 2, height: 2)
                            .foregroundStyle(.white)
                    }
                    .scaleEffect(warpState.warpScaleEffect)
                    .rotationEffect(warpState.warpRotationEffect)
                    .opacity(warpState.warpStarFieldVisibility)
                }

                GeometryReader { controlGeo in
                    ZStack {
                        HStack(spacing: 15) {
                            Image(systemName: "airplane")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundStyle(.white)
                                .padding(.leading, 25)
                            VStack(spacing: 15) {
                                    Image(systemName: "arrow.up")
                                        .symbolEffect(.pulse, isActive: true)
                                        .opacity(
                                            joystickState.tutorialGuideOpacity
                                        )
                                    Circle()
                                        .frame(width: 20, height: 20)
                                        .offset(x: joystickOffset)
                                        .opacity(
                                            joystickState.visualGuideOpacity
                                        )
                                    Image(systemName: "arrow.down")
                                        .symbolEffect(.pulse, isActive: true)
                                        .opacity(
                                            joystickState.tutorialGuideOpacity
                                        )
                            }
                            Image(systemName: "arrow.right")
                                .symbolEffect(.pulse, isActive: true)
                                .opacity(joystickState.tutorialGuideOpacity)
                        }
                        .foregroundStyle(.white)
                        .offset(x: 20)
                        .rotationEffect(direction, anchor: .center)

                        Text("Hold and drag the control stick to adjust speed and direction")
                            .multilineTextAlignment(.center)
                            .offset(y: 150)
                            .foregroundStyle(.white)
                            .opacity(joystickState.tutorialGuideOpacity)

                        // Transparent overlay for drag gesture
                        Color.clear
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        self.joystickState = .inUse
                                        let frame = controlGeo.frame(in: .local)
                                        let center = CGPoint(x: frame.midX, y: frame.midY)
                                        let drag = value.location
                                        let dx = drag.x - center.x
                                        let dy = drag.y - center.y
                                        let angle = atan2(dy, dx)
                                        let selectedSpeed = Geometry.calculateDistance(a: center, b: drag) * 2
                                        print(selectedSpeed)
                                        self.speed = min(selectedSpeed, maxSpeed)
                                        direction = .radians(angle)
                                    }
                                    .onEnded { _ in
                                        self.joystickState = .idle
                                    }
                            )
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(height: 120)
                Circle()
                    .stroke(.white)
                    .frame(width: 100, height: 100)
                    .opacity(joystickState.visualGuideOpacity)

                Circle()
                    .stroke(.white)
                    .frame(width: maxSpeed, height: maxSpeed)
                    .opacity(joystickState.visualGuideOpacity)

                VStack {
                    Spacer()
                    Button(warpState.warpButtonLabel) {
                        if warpState == .active {
                            warpState = .poweringDown
                            withAnimation(.easeInOut(duration: 3)) {
                                warpState = .inactive
                            }
                        } else if warpState == .inactive {
                            warpState = .poweringUp
                            withAnimation(.easeInOut(duration: 3)) {
                                warpState = .active
                            }
                        }
                    }
                    .disabled(warpState.warpButtonDisabled)
                    .buttonStyle(.borderedProminent)
                }
            }
            .onAppear {
                self.calculateParticleLocations(
                    inFrame: proxy.frame(in: .local)
                )
            }
        }
        .ignoresSafeArea()
    }

    private func calculateParticleLocations(inFrame frame: CGRect) {
        var randomNumberGenerator = SeededRandomNumberGenerator(seed: 1)
        self.stars = []
        for index in 0..<numberOfParticles {
            let x: CGFloat = CGFloat.random(
                in: 0...2,
                using: &randomNumberGenerator
            )
            let y: CGFloat = CGFloat.random(
                in: 0...2,
                using: &randomNumberGenerator
            )

            self.stars.append(
                Star(
                    startPosition: .init(x: frame.midX * x, y: frame.midY * y),
                    id: index
                )
            )
        }
    }
}

#Preview {
    SpaceFlightDemoView()
}
