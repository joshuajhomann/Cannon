//
//  CustomError.swift
//  Reality
//
//  Created by Joshua Homann on 12/13/23.
//

import Foundation

enum CustomError: Error {
    case message(description: String, file: StaticString, line: Int)
    init(_ message: String, file: StaticString = #file, line: Int = #line) {
        self = .message(description: message, file: file, line: line)
    }
    var localizedDescription: String {
        switch self {
        case let .message(description, file, line): "\(description)\nLine: \(line) in: \(file)"
        }
    }
}
