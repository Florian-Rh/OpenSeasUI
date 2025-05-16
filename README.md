#  OpenSeasUI

OpenSeasUI is a Swift Package that contains animated views aimed at mimicing the behavior of water. It can be used in iOS Apps (other Apple Platforms are on the roadmap) to create engaging and beautiful UIs, or to visually convey maritime weather information like wave behavior.

<p>
<img height="500" width="245" alt="Still image of wave view with controls" src="https://github.com/user-attachments/assets/34923961-9a59-4b33-8505-c829b13b7692" />

<img height="500" width="245" alt="Animated gif of the wave view in motion" src="https://github.com/user-attachments/assets/90c01102-267d-41f9-8ca3-2f831d6f8aa3" />    
</p>



## How to include this Swift Package

When including this package in your iOS app, [add the package with Xcode as described in the Apple documentation](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app) using the following URL in the serach field:
````
https://github.com/Florian-Rh/OpenSeasUI.git
````

When including this package in another Swift package, add the following dependency in your `Package.swift` file:

```
dependencies: [
    .package(url: "https://github.com/Florian-Rh/OpenSeasUI.git", branch: "main")
]
```

Once the package is resolved, import it where you want to use it:

```
import OpenSeasUI
```

## Examples

> Refer to the [included WaveDemoView](./Sources/OpenSeasUI/Demo/WaveDemoView.swift) for a complete example of all capabilities

#### Simple Wave View
To add an animated wave view to any SwiftUI view, add `WaveView` with the parameters that best match your needs:

```
import SwiftUI
import OpenSeasUI

struct SimpleWaveDemoView: View {
    var body: some View {
        WaveView(amplitude: 10, waveLength: 0.25)
            .foregroundStyle(.waveBlue)
    }
}
```

#### Changing animation style and height
By default, the water line will appear in the center of the view. The default animation will move the waves back and forth by two waves over a period of 2.5 seconds.

You can change these defaults with optional parameters:

```
WaveView(
    amplitude: 10, 
    waveLength: 0.25, 
    waterLevel: 0.8, 
    animationBehaviour: .continuous(duration: 1.0)
)
```

> **Note**: When changing the animation behavior *after* view initializiation, you have to enforce rerendering the WaveView by use of the `.id(_:)` modifier.

#### Overlapping multiple waves

You can create a more dynamic behavior by overlapping several wave views and shifting each wave slightly using the `startPhase` parameter:

```
ZStack {
    WaveView(
        amplitude: 10,
        waveLength: 0.25,
        animationBehaviour: .continuous(duration: 2.5)
    )
    .foregroundStyle(.waveBlue)

    WaveView(
        amplitude: 10,
        waveLength: 0.25,
        animationBehaviour: .continuous(duration: 2.0),
        startPhase: 0.5
    )
    .foregroundStyle(.deepSeaBlue)
    .opacity(0.8)
}
```

#### Rotating the water level
The water level can also be rotated between -45° and 45°. The rotaion angle is expressed as radians between -(π/4) and +(π/4):

```
WaveView(
    amplitude: 20, 
    waveLength: 0.25, 
    rotation: .pi / 4
)
```

You can also match the rotation to the physical device's roll using the CoreMotion framework:

```
import SwiftUI
import OpenSeasUI
import CoreMotion

struct SimpleWaveDemoView: View {

    @State private var rotation: Double = 0.0

    private let motionManager = CMMotionManager()

    var body: some View {
        WaveView(
            amplitude: 20, 
            waveLength: 0.25, 
            rotation: self.rotation
        )
        .foregroundStyle(.waveBlue)
        .onAppear(perform: self.startDeviceMotionUpdates)
    }

    private func startDeviceMotionUpdates() {
        self.motionManager.deviceMotionUpdateInterval = 0.01
        self.motionManager.startDeviceMotionUpdates(to: .main) { motion, _ in
            if let gravity = motion?.gravity {
                self.rotation = atan2(gravity.x, gravity.y) + .pi
            }
        }
    }
}
```

## Included styling options
Please check out the included variety of ocean related colors and gradients:

### Colors
- oceanBlue
- deepSeaBlue
- abyssBlue
- waveBlue
- iceBlue
- coralRed
- sunsetOrange
- seafoamGreen
- sandBeige
#### Example:
```
WaveView(amplitude: 10, waveLength: 0.25)
    .foregroundStyle(.waveBlue)
```

### Gradients
- deepOceanGradient
- coralSunsetGradient
- tropicalShoreGradient
- midnightAbyssGradient
- crystalLagoonGradient
- nauticalGlowGradient

#### Example:
```
WaveView(amplitude: 10, waveLength: 0.25)
    .foregroundStyle(
        LinearGradient(
            gradient: .midnightAbyssGradient, 
            startPoint: .top, 
            endPoint: .bottom
        )
    )
```


