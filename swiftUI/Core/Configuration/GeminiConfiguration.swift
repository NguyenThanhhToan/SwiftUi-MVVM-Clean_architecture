//
//  GeminiConfiguration.swift
//  swiftUI
//
//  Gemini needs an API key at runtime. The app reads it from the generated
//  Info.plist using the `GEMINI_API_KEY` key.
//

import Foundation

enum GeminiConfigurationError: LocalizedError {
    case missingAPIKey

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "GEMINI_API_KEY is missing. Add it to the app's Info.plist."
        }
    }
}

enum GeminiConfiguration {
    static let modelName = "gemini-2.5-flash"
    static let apiKeyInfoDictionaryKey = "GEMINI_API_KEY"

    static func apiKey() throws -> String {
        let value = Bundle.main.object(forInfoDictionaryKey: apiKeyInfoDictionaryKey) as? String
        let apiKey = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !apiKey.isEmpty, apiKey != "YOUR_GEMINI_API_KEY" else {
            throw GeminiConfigurationError.missingAPIKey
        }

        return apiKey
    }
}
