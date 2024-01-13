//
//  GameControllerService.swift
//  Cannon
//
//  Created by Joshua Homann on 12/28/23.
//

import AsyncAlgorithms
import GameController
import SwiftUI

extension Notification: @unchecked Sendable { }

@MainActor
struct GameControllerServiceEnvironmentKey: EnvironmentKey {
    static let defaultValue: GameControllerService = .init()
}

extension EnvironmentValues {
    var gameControllerService: GameControllerService {
        self[GameControllerServiceEnvironmentKey.self]
    }
}

@Observable
final class GameControllerService {
    private(set) var currentController: GCController?
    private(set) var leftStick: SIMD2<Float> = .zero
    private(set) var rightStick: SIMD2<Float> = .zero
    private(set) var buttonDown = true
    let subscriptions = Subscriptions()
    init() {
        subscriptions += merge(
            NotificationCenter.default
                .notifications(named: .GCControllerDidBecomeCurrent)
                .compactMap { $0.object as? GCController },
            NotificationCenter.default
                .notifications(named: .GCControllerDidDisconnect)
                .map { _ in nil }
        )
        .removeDuplicates(by: { $0 === $1 })
        .with(unretained: self)
        .onMainSubscribe { service, controller in
            service.currentController?.extendedGamepad?.buttonA.valueChangedHandler = nil
            service.currentController?.extendedGamepad?.leftThumbstick.valueChangedHandler = nil
            service.currentController?.extendedGamepad?.rightThumbstick.valueChangedHandler = nil
            guard let pad = controller?.extendedGamepad  else { return }
            pad.buttonA.valueChangedHandler = { [weak service] _, _ , pressed in
                guard service?.buttonDown != pressed else { return }
                service?.buttonDown = pressed
            }
            pad.leftThumbstick.valueChangedHandler = { [weak service] _, x, y in service?.leftStick = .init(x,y) }
            pad.rightThumbstick.valueChangedHandler = { [weak service] _, x, y in service?.rightStick = .init(x,y) }
            service.currentController = controller
        }
    }
}
