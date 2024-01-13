//
//  PlayerComponent.swift
//  
//
//  Created by Joshua Homann on 12/30/23.
//

import RealityKit
import SwiftUI

public struct PlayerComponent: TransientComponent {
    public var pitch = (0.5 * .τ) as Float
    public var yaw = 0.0 as Float
    public var Δpitch: Float { _Δpitch() }
    public var Δyaw: Float { _Δyaw() }
    private let _Δpitch: () -> Float
    private let _Δyaw: () -> Float
    public init(getPitch: @escaping () -> Float, getYaw: @escaping () -> Float) {
        _Δpitch = getPitch
        _Δyaw = getYaw
    }
}
