//
//  File.swift
//  OpenSeasUI
//
//  Created by Florian Rhein on 21.07.25.
//

import SwiftUI

public extension CGVector {
    var inverted: CGVector {
        CGVector(dx: -self.dx, dy: -self.dy)
    }

    init(from angle: Angle) {
        let dx = cos(angle.radians)
        let dy = sin(angle.radians)

        self.init(dx: CGFloat(dx), dy: CGFloat(dy))
    }

    var angle: Angle {
        let radians = atan2(self.dy, self.dx)

        return Angle(radians: radians)
    }

    var magnitude: CGFloat {
        hypot(self.dx, self.dy)
    }

    func scaled(by factor: CGFloat) -> CGVector {
        CGVector(dx: self.dx * factor, dy: self.dy * factor)
    }
}
