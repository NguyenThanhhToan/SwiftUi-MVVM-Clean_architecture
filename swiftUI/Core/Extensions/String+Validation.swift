//
//  String+Validation.swift
//  swiftUI
//
//  Core contains shared utilities that can be reused across presentation,
//  domain, and data layers without creating circular dependencies.
//

import Foundation

extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isValidEmail: Bool {
        let pattern = #"^[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        return range(of: pattern, options: .regularExpression) != nil
    }

    var isValidPassword: Bool {
        trimmed.count >= 8
    }
}

