//
//  Subscriptions.swift
//  Reality
//
//  Created by Joshua Homann on 12/13/23.
//

import Foundation

final class Subscriptions {
    private var cancellations: [() -> Void] = []
    deinit {
        for cancel in cancellations {
            cancel()
        }
    }
    static func += <Value, Failure>(lhs: Subscriptions, rhs: Task<Value, Failure>) {
        lhs.cancellations.append(rhs.cancel)
    }
    func onMain(perform operation: @escaping () async -> Void) {
        self += Task.detached { @MainActor in
            await operation()
        }
    }
}
