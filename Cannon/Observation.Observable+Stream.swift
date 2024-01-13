//
//  AsyncStream+Observe.swift
//  Reality
//
//  Created by Joshua Homann on 12/13/23.
//

import Foundation

extension Observation.Observable {
    func stream<Value>(of keyPath: KeyPath<Self, Value>) ->  AsyncStream<Value> where Self: AnyObject {
        let (output, input) = AsyncStream.makeStream(of: Value.self, bufferingPolicy: .bufferingNewest(1))
        @Sendable
        func subscribe() {
            input.yield(withObservationTracking {
                self[keyPath: keyPath]
            } onChange: { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    input.yield(self[keyPath: keyPath])
                    subscribe()
                }
            })
        }
        subscribe()
        return output
    }
}
