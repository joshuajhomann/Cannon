//
//  Game.swift
//  Reality
//
//  Created by Joshua Homann on 12/13/23.
//

import Algorithms
import Foundation
import RealityKit
import RealityKitContent
import SwiftUI

@MainActor
final class Game {
    private let subscriptions = Subscriptions()
    let make: @MainActor @Sendable (inout RealityViewContent) async -> Void
    init(gameControllerService: GameControllerService) {
        make = { [subscriptions] content in
            do {
                let root = Entity()
                content.add(root)
                let scene = try await Entity(named: "Scene", in: realityKitContentBundle)
                guard let cannon = scene.findEntity(named: "Cannon") else { throw CustomError("No cannon found") }
                cannon.components[PlayerComponent.self] = .init(
                    getPitch: { gameControllerService.leftStick.y },
                    getYaw:  { gameControllerService.leftStick.x }
                )
                root.addChild(cannon)

                let floor = ModelEntity(mesh: .generatePlane(width: 50, depth: 50), materials: [OcclusionMaterial()])
                floor.components[PhysicsBodyComponent.self] = .init(massProperties: .default, mode: .static)
                floor.generateCollisionShapes(recursive: false)
                content.add(floor)

                product(0..<10, 0..<10)
                    .lazy
                    .map { ix, iy in
                        let ux = CGFloat(ix) / 10.0
                        let uy = CGFloat(iy) / 10.0
                        let x = Float(ix) - 5.0
                        let y = Float(iy)
                        let brick = ModelEntity(
                            mesh: .generateBox(width: 0.3, height: 0.25, depth: 0.1),
                            materials: [SimpleMaterial(
                                color: .init(red: ux + 0.5, green: 1.5 - uy, blue: (ux + uy) * 0.5 + 0.5, alpha: 1),
                                isMetallic: false)
                            ]
                        )
                        brick.position = .init(x: x * 0.3, y: y * 0.25 + 0.25 * 0.5, z: -5.0)
                        brick.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(
                            massProperties: .init(mass: 1.0),
                            material: .generate(friction: 0.5, restitution: 0.5),
                            mode: .dynamic
                        )
                        brick.generateCollisionShapes(recursive: false)
                        return brick
                    }
                    .forEach(content.add)
                
                subscriptions += gameControllerService
                    .stream(of: \.buttonDown)
                    .removeDuplicates()
                    .filter { !$0 }
                    .dropFirst()
                    .onMainSubscribe { [root] value in
                        let cannonBall = ModelEntity(
                            mesh: .generateSphere(radius: 0.04),
                            materials: [SimpleMaterial(color: .darkGray, roughness: 0.75, isMetallic: true)]
                        )
                        cannonBall.position = [0, 0.12, -2]
                        guard let player = cannon.components[PlayerComponent.self] else { return }
                        let up = SIMD4(0.0, 1.0, 0.0, 1.0)
                        let velocity = AffineTransform3D(rotation: .init(
                            eulerAngles: .init(angles: .init(
                                Double(player.pitch - 0.25 * .τ),
                                Double(player.yaw),
                                0
                            ),
                            order: .xyz))
                        ).matrix4x4 * up * 6.0
                        cannonBall.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(
                            massProperties: .init(mass: 5),
                            material: .generate(friction: 1.0, restitution: 0.1),
                            mode: .dynamic
                        )
                        cannonBall.components[PhysicsMotionComponent.self] = .init(linearVelocity: .init(x: Float(velocity.x), y: Float(velocity.y), z: Float(velocity.z)))
                        cannonBall.generateCollisionShapes(recursive: false)
                        cannonBall.components[LifetimeComponent.self] = .init(timeToLive: 3)
                        root.addChild(cannonBall)
                    }
            } catch {
                log.error("\(error.localizedDescription)")
            }
        }
    }
}

extension GameView {
    static let name = String(describing: Self.self)
}
