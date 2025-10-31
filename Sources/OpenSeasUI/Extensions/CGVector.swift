//
//  File.swift
//  OpenSeasUI
//
//  Created by Florian Rhein on 21.07.25.
//

import SwiftUI

extension CGVector {
    public var inverted: CGVector {
        CGVector(dx: -self.dx, dy: -self.dy)
    }

    public var angle: Angle {
        let radians = atan2(self.dy, self.dx)

        return Angle(radians: radians)
    }

    public var magnitude: CGFloat {
        hypot(self.dx, self.dy)
    }

    public init(from angle: Angle) {
        let dx = cos(angle.radians)
        let dy = sin(angle.radians)

        self.init(dx: CGFloat(dx), dy: CGFloat(dy))
    }

    public func scaled(by factor: CGFloat) -> CGVector {
        CGVector(dx: self.dx * factor, dy: self.dy * factor)
    }

    public mutating func scale(by factor: CGFloat) {
        self.dx *= factor
        self.dy *= factor
    }

    public mutating func bounce(off frame: CGRect, at point: CGPoint) {
        let margin = 0.1
        if abs(point.y - frame.minY) < margin || abs(point.y - frame.maxY) < margin {
            self.dy = -self.dy
        }

        if abs(point.x - frame.minX) < margin || abs(point.x - frame.maxX) < margin {
            self.dx = -self.dx
        }
    }
}
