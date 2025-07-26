import CoreGraphics
import SwiftUI

public class Geometry {
    /// Calculates the intersection of a ray from a start point in a given direction with the rectangle.
    /// - Parameters:
    ///   - start: The origin point of the ray (should be inside the rectangle).
    ///   - direction: The direction vector of the ray.
    /// - Returns: The intersection point with the rectangle's edge, or the start point if no intersection is found.
    static func intersectionPoint(in rect: CGRect, from start: CGPoint, direction: CGVector) -> CGPoint {
        let rectMaxX = rect.maxX
        let rectMaxY = rect.maxY
        let rectMinX = rect.minX
        let rectMinY = rect.minY
        let originX = start.x
        let originY = start.y
        let dirX = direction.dx
        let dirY = direction.dy
        var tCandidates: [CGFloat] = []
        // For X direction: only check the side the ray is moving toward
        if dirX > 0 {
            // Moving right: check intersection with right side (x = maxX)
            let tRight = (rectMaxX - originX) / dirX
            let yAtRight = originY + tRight * dirY
            if tRight > 0 && yAtRight >= rectMinY && yAtRight <= rectMaxY {
                tCandidates.append(tRight)
            }
        } else if dirX < 0 {
            // Moving left: check intersection with left side (x = 0)
            let tLeft = (0 - originX) / dirX
            let yAtLeft = originY + tLeft * dirY
            if tLeft > 0 && yAtLeft >= rectMinY && yAtLeft <= rectMaxY {
                tCandidates.append(tLeft)
            }
        }
        // For Y direction: only check the side the ray is moving toward
        if dirY > 0 {
            // Moving down: check intersection with bottom side (y = maxY)
            let tBottom = (rectMaxY - originY) / dirY
            let xAtBottom = originX + tBottom * dirX
            if tBottom > 0 && xAtBottom >= rectMinX && xAtBottom <= rectMaxX {
                tCandidates.append(tBottom)
            }
        } else if dirY < 0 {
            // Moving up: check intersection with top side (y = 0)
            let tTop = (0 - originY) / dirY
            let xAtTop = originX + tTop * dirX
            if tTop > 0 && xAtTop >= rectMinX && xAtTop <= rectMaxX {
                tCandidates.append(tTop)
            }
        }
        // Use the smallest positive t (the first intersection)
        guard let t = tCandidates.min() else {
            // Should not happen if the direction is valid and the particle is inside
            return start
        }
        let intersectionX = originX + t * dirX
        let intersectionY = originY + t * dirY

        return CGPoint(x: intersectionX, y: intersectionY)
    }

    static func calculateDistance(a: CGPoint, b: CGPoint) -> Double {
        let dx = a.x - b.x
        let dy = a.y - b.y

        return sqrt(pow(dx, 2) + pow(dy, 2))
    }

    static func calculatePosition(
        between startPoint: CGPoint,
        and endPoint: CGPoint,
        forTime time: Date,
        startTime: Date,
        duration: TimeInterval
    ) -> CGPoint {
        let elapsedTime = time.timeIntervalSince(startTime)
        let progress = elapsedTime / duration
        if progress >= 1 {
            return endPoint
        }

        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let xAtTime = startPoint.x + dx * progress
        let yAtTime = startPoint.y + dy * progress

        return CGPoint(x: xAtTime, y: yAtTime)
    }
}

