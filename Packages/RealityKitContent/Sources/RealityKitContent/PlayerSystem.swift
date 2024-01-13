//
//  PlayerSystem.swift
//
//
//  Created by Joshua Homann on 12/30/23.
//

import Foundation
import RealityKit
import SwiftUI

public struct PlayerSystem: System {
    private static let query = EntityQuery(where: .has(PlayerComponent.self))
    public init(scene: RealityKit.Scene) { }
    public mutating func update(context: SceneUpdateContext) {
        guard let cannon = context.entities(matching: Self.query, updatingSystemWhen: .rendering).first(where: { _ in true }),
            let barrel = cannon.findEntity(named: "Barrel"),
            var component = cannon.components[PlayerComponent.self]
        else { return }
        let elapsed = Float(context.deltaTime)
        component.pitch += elapsed * Constant.turnSpeedRadiansPerSecond * -component.Δpitch
        component.pitch.clamp(Constant.pitchRange)
        component.yaw += elapsed * Constant.turnSpeedRadiansPerSecond * -component.Δyaw
        component.yaw.clamp(Constant.yawRange)
        cannon.components[PlayerComponent.self] = component
        let yawRotation = AffineTransform3D(rotation: .init(angle: .radians(Double(component.yaw)), axis: .z))
        let pitchRotation = AffineTransform3D(rotation: .init(angle: .radians(Double(component.pitch)), axis: .x))
        cannon.transform = Transform(Constant.worldTransform.concatenating(yawRotation))
        barrel.transform = Transform(Constant.barrelWorldTransform.concatenating(pitchRotation))
    }
}

extension PlayerSystem {
    enum Constant {
        static let turnSpeedRadiansPerSecond: Float = 0.25 * .τ
        static let pitchRange: ClosedRange<Float> = ( 0.0 ... 0.25 * .τ)
        static let yawRange: ClosedRange<Float> = (-0.25 * .τ ... 0.25 * .τ)
        static let worldTransform = AffineTransform3D
            .init(translation: .init(x: 0, y: 0, z: -2))
            .concatenating(.init(scale: .init(vector: .init(repeating: 0.3))))
            .concatenating(.init(rotation: .init(angle: .init(radians: -0.25 * .τ), axis: .x)))
        static let barrelWorldTransform = AffineTransform3D
            .init(translation: .init(x: 0, y: 0, z: 0.4))
    }
}
public extension FloatingPoint {
    mutating func clamp(_ range: ClosedRange<Self>) {
        self = max(min(self, range.upperBound), range.lowerBound)
    }
    @inlinable static var τ: Self { 2 * Self.pi }
}
