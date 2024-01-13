//
//  LifetimeComponent.swift
//
//
//  Created by Joshua Homann on 12/30/23.
//

import Foundation
import RealityKit

public struct LifetimeComponent: TransientComponent {
    public var endOfLife: Date
    public init(timeToLive: TimeInterval) {
        endOfLife = .now.addingTimeInterval(timeToLive)
    }
}
