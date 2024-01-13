//
//  GameView.swift
//  Cannon
//
//  Created by Joshua Homann on 12/30/23.
//

import RealityKit
import SwiftUI

struct GameView: View {
    @State var game: Game
    var body: some View {
        RealityView(make: game.make)
    }
}
