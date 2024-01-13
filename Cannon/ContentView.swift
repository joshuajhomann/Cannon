//
//  ContentView.swift
//  Reality
//
//  Created by Joshua Homann on 11/18/23.
//

import OSLog
import SwiftUI
import RealityKit


let log = Logger(subsystem: "com.josh.example", category: "error")

@MainActor
struct ContentView: View {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @State var viewModel: ViewModel
    var body: some View {
        Group {
            if viewModel.needsController {
                Text("Connect a controller \(viewModel.needsController.description)")
            } else {
                Grid {
                    GridRow {
                        Toggle("Button", isOn: $viewModel.buttonDown)
                    }.gridCellColumns(2)
                    GridRow {
                        Text("Left x: \(viewModel.leftStick.x.formatted(.percent))")
                        Text("Right x: \(viewModel.rightStick.x.formatted(.percent))")
                    }
                    GridRow {
                        Text("Left y: \(viewModel.leftStick.y.formatted(.percent))")
                        Text("Right y: \(viewModel.rightStick.y.formatted(.percent))")
                    }
                }
            }
        }
        .frame(width: 500)
        .padding(40)
        .glassBackgroundEffect()
        .task {
            let result = await openImmersiveSpace(id: GameView.name)
            log.log("await openImmersiveSpace \(String(describing: result))")
        }
    }
}

@MainActor
@Observable
final class ViewModel {
    var buttonDown = false
    private(set) var leftStick = SIMD2<Float>.zero
    private(set) var rightStick = SIMD2<Float>.zero
    private(set) var needsController = false
    private(set) var game: Game

    private let gameControllerService: GameControllerService
    private let subscriptions = Subscriptions()
    init(gameControllerService: GameControllerService) {
        self.gameControllerService = gameControllerService
        game = .init(gameControllerService: gameControllerService)

        subscriptions += gameControllerService
            .stream(of: \.currentController)
            .map { $0 == nil }
            .onMainAssign(to: \.needsController, on: self)

        subscriptions += gameControllerService
            .stream(of: \.leftStick)
            .onMainAssign(to: \.leftStick, on: self)

        subscriptions += gameControllerService
            .stream(of: \.rightStick)
            .onMainAssign(to: \.rightStick, on: self)

        subscriptions += gameControllerService
            .stream(of: \.buttonDown)
            .removeDuplicates()
            .filter { !$0 }
            .dropFirst()
            .with(unretained: self)
            .onMainSubscribe { unretained, value in
                unretained.buttonDown.toggle()
            }
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView(viewModel: .init(gameControllerService: .init()))
}
