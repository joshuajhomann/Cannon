//
//  CannonApp.swift
//  Cannon
//
//  Created by Joshua Homann on 12/28/23.
//

import SwiftUI
import RealityKitContent

@main
struct RealityApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.gameControllerService) private var gameControllerService
    @State var viewModel: ViewModel?
    var body: some Scene {
        WindowGroup {
            if let viewModel {
                ContentView(viewModel: viewModel)
            } else {
                ProgressView().task { viewModel = .init(gameControllerService: gameControllerService) }
            }
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.0, height: 1.0, depth: 1.0, in: .meters)
        ImmersiveSpace(id: GameView.name) {
            if let game = viewModel?.game {
                GameView(game: game)
            }
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        PlayerComponent.registerComponent()
        PlayerSystem.registerSystem()
        LifetimeComponent.registerComponent()
        LifetimeSystem.registerSystem()
        return true
    }
}
