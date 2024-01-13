//
//  AsyncSequence+Operators.swift
//  Cannon
//
//  Created by Joshua Homann on 12/28/23.
//

import Foundation

extension AsyncSequence {
    func onMainSubscribe(
        forEach: @escaping (Element) -> Void,
        onError: @escaping (Error) -> Void = { _ in }
    ) -> Task<Void, Never> {
        Task.detached { @MainActor in
            do {
                for try await value in self {
                    forEach(value)
                }
            } catch {
                onError(error)
            }
        }
    }

    func onMainAssign<Base: AnyObject>(to keyPath: ReferenceWritableKeyPath<Base, Element>, on base: Base) -> Task<Void, Never> {
        Task.detached { @MainActor [weak base] in
            do {
                for try await value in self {
                    guard let base else { return }
                    base[keyPath: keyPath] = value
                }
            } catch {
                assertionFailure("Error not expected in assignable sequence")
            }
        }
    }

    func with<O: AnyObject>(unretained object: O) -> AsyncCompactMapSequence<Self, (O, Self.Element)> {
        compactMap { [weak object] element in
            object.map { ($0, element) }
        }
    }
}
