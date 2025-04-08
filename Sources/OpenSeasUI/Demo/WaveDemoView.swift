//
//  DemoView.swift
//  OpenSeasUI
//
//  Created by Florian Rhein on 27.03.25.
//

import SwiftUI
import CoreMotion

internal struct WaveDemoView: View {
    @State private var waveAmplitude: CGFloat = 10.0
    @State private var animationDuration: CGFloat = 1.0
    @State private var waveLength: CGFloat = 0.25
    @State private var waterLevel: CGFloat = 0.50
    @State private var rotation: CGFloat = 0.0
    @State private var clipToDeviceRotation: Bool = false
    @State private var distance: Int = 1
    @State private var animationBehavior: WaveView.AnimationBahaviour = .continuous(duration: 1.0)
    @State private var showControls = false

    // The id is used to enfore re-rendering the wave views after the animation is changed
    @State private var id = UUID()

    private let motionManager = CMMotionManager()

    internal var body: some View {
        ZStack(alignment: .bottom) {
            // Background
            LinearGradient(
                gradient: .coralSunsetGradient,
                startPoint: .bottom,
                endPoint: .top
            )

            // Background wave with offset startPhase and slower animation
            WaveView(
                amplitude: waveAmplitude,
                waveLength: waveLength,
                waterLevel: waterLevel,
                animationBehaviour: backgroundWaveAnimationBehavior,
                rotation: rotation,
                startPhase: 0.5
            )
            .id(id)
            .foregroundStyle(
                LinearGradient(gradient: .midnightAbyssGradient, startPoint: .top, endPoint: .bottom)
            )

            // Foreground wave
            WaveView(
                amplitude: waveAmplitude,
                waveLength: waveLength,
                waterLevel: waterLevel,
                animationBehaviour: animationBehavior,
                rotation: rotation
            )
            .id(id)
            .foregroundStyle(
                LinearGradient(gradient: .deepOceanGradient, startPoint: .top, endPoint: .bottom)
            )
            .opacity(0.8)

            // Control panel
            VStack {
                HStack {
                    Button {
                        withAnimation {
                            showControls.toggle()
                        }
                    } label: {
                        HStack {
                            Text("Controls")
                            Image(systemName: "chevron.right")
                                .rotationEffect(.degrees(showControls ? 90 : 0))
                        }
                    }
                    Spacer()
                }
                if showControls {
                    Text("Amplitude: \(waveAmplitude, specifier: "%.1F")")
                    Slider(
                        value: $waveAmplitude,
                        in: 0.0...100.0,
                        label: { EmptyView() },
                        minimumValueLabel: { Text("0,0") },
                        maximumValueLabel: { Text("100,0")}
                    )
                    Text("Wave length: \(waveLength, specifier: "%.2F")")
                    Slider(
                        value: $waveLength,
                        in: 0.0...1.0,
                        label: { EmptyView() },
                        minimumValueLabel: { Text("0,0") },
                        maximumValueLabel: { Text("1,0")}
                    )
                    Text("Water Level: \(waterLevel, specifier: "%.2F")")
                    Slider(
                        value: $waterLevel,
                        in: 0.0...1.0,
                        label: { EmptyView() },
                        minimumValueLabel: { Text("0,0") },
                        maximumValueLabel: { Text("1,0")}
                    )
                    Text("Rotation: \(rotation, specifier: "%.2F")")
                    Slider(
                        value: $rotation,
                        in: -1.0...1.0,
                        label: { EmptyView() },
                        minimumValueLabel: { Text("-1,0") },
                        maximumValueLabel: { Text("1,0")}
                    )
                    Toggle("Clip to device rotation", isOn: $clipToDeviceRotation)
                        .onChange(of: clipToDeviceRotation) { _, _ in
                            if clipToDeviceRotation {
                                self.startDeviceMotionUpdates()
                            } else {
                                self.stopDeviceMotionUpdates()
                            }
                        }

                    Text("Animation behavior")
                    Picker("", selection: $animationBehavior) {
                        Text("Continuous")
                            .tag(WaveView.AnimationBahaviour.continuous(duration: animationDuration))
                        Text("Back and forth")
                            .tag(
                                WaveView.AnimationBahaviour.backAndForth(
                                    duration: animationDuration,
                                    distance: distance
                                )
                            )
                        Text("None")
                            .tag(WaveView.AnimationBahaviour.none)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: animationBehavior) { _, _ in
                        id = UUID()
                    }

                    if case .backAndForth(_, _) = animationBehavior {
                        Stepper("Distance: \(distance)", value: $distance, in: 1...10)
                            .onChange(of: distance) { _, _ in
                                animationBehavior = .backAndForth(duration: animationDuration, distance: distance)
                                id = UUID()
                            }
                    }

                    if animationBehavior != .none {
                        Text("Animation duration: \(animationDuration, specifier: "%.2F")")
                        Slider(
                            value: $animationDuration,
                            in: 0.0...10.0,
                            label: { EmptyView() },
                            minimumValueLabel: { Text("0,0") },
                            maximumValueLabel: { Text("10,0")}
                        )
                        .onChange(of: animationDuration) { _, _ in
                            switch animationBehavior {
                                case .continuous(_):
                                    animationBehavior = .continuous(duration: animationDuration)
                                case let .backAndForth(_, distance):
                                    animationBehavior = .backAndForth(duration: animationDuration, distance: distance)
                                case .none:
                                    animationBehavior = .none
                            }
                            id = UUID()
                        }
                    }
                }
            }
            .padding()
            .padding(.bottom, 15.0)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 15.0))
            .ignoresSafeArea()
            .padding(.horizontal)
        }
        .ignoresSafeArea()
    }

    private var backgroundWaveAnimationBehavior: WaveView.AnimationBahaviour {
        switch self.animationBehavior {
            case let .continuous(duration):
                return .continuous(duration: duration + 0.5)
            case let .backAndForth(duration, distance):
                return .backAndForth(duration: duration + 0.5, distance: distance)
            case .none:
                return .none
        }
    }

    private func startDeviceMotionUpdates() {
        self.motionManager.deviceMotionUpdateInterval = 0.01
        self.motionManager.startDeviceMotionUpdates(to: .main) { motion, _ in
            if let gravity = motion?.gravity {
                self.rotation = atan2(gravity.x, gravity.y) + .pi
            }
        }
    }

    private func stopDeviceMotionUpdates() {
        self.motionManager.stopDeviceMotionUpdates()
    }
}

#Preview {
    WaveDemoView()
}
