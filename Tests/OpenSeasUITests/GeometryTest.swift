//
//  Test.swift
//  OpenSeasUI
//
//  Created by Florian Rhein on 24.07.25.
//

import Foundation
import Testing
@testable import OpenSeasUI

struct GeometryTest {

    @Test func calculatePositionTest() async throws {
        let startPoint = CGPoint(x: 100, y: 500)
        let endPoint = CGPoint(x: 200, y: 1000)
        let startTime = Date(timeIntervalSince1970: 0.0)
        let timeOfPositioning = Date(timeIntervalSince1970: 1)
        let duration: TimeInterval = 5.0

        let position = Geometry.calculatePosition(
            between: startPoint,
            and: endPoint,
            forTime: timeOfPositioning,
            startTime: startTime,
            duration: duration
        )

        #expect(position.x == 120)
        #expect(position.y == 600)
    }

}
