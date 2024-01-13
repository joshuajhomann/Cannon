//
//  LifetimeSystem.swift
//  
//
//  Created by Joshua Homann on 12/30/23.
//

import Foundation
import RealityKit

public struct LifetimeSystem: System {
    private static let query = EntityQuery(where: .has(LifetimeComponent.self))
    public init(scene: RealityKit.Scene) { }
    public mutating func update(context: SceneUpdateContext) {
        let now = Date.now
        context
            .entities(matching: Self.query, updatingSystemWhen: .rendering)
            .lazy
            .filter { entity in
                (entity.components[LifetimeComponent.self]?.endOfLife).map { now.timeIntervalSince($0) > 0 } ?? false
            }
            .forEach { $0.removeFromParent() }
    }
}
