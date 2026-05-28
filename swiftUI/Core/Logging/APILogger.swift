//
//  APILogger.swift
//  swiftUI
//
//  Shared logging lives in Core so any repository can print requests,
//  responses, and failures in one consistent format.
//

import Foundation

enum APILogger {
    static func logRequest(_ request: URLRequest, apiName: String) {
        print("")
        print("========== API REQUEST: \(apiName) ==========")
        print("Method: \(request.httpMethod ?? "N/A")")
        print("URL: \(request.url?.absoluteString ?? "N/A")")

        let headers = request.allHTTPHeaderFields ?? [:]
        print("Headers: \(formatDictionary(headers))")

        if let body = request.httpBody, !body.isEmpty {
            print("Body: \(formatData(body))")
        } else {
            print("Body: <empty>")
        }
        print("============================================")
    }

    static func logResponse(_ response: URLResponse, data: Data, apiName: String) {
        print("---------- API RESPONSE: \(apiName) ----------")

        if let httpResponse = response as? HTTPURLResponse {
            print("Status Code: \(httpResponse.statusCode)")
            print("Headers: \(formatDictionary(httpResponse.allHeaderFields))")
        } else {
            print("Response: \(response)")
        }

        print("Body: \(formatData(data))")
        print("============================================")
        print("")
    }

    static func logError(_ error: Error, apiName: String) {
        print("********** API ERROR: \(apiName) **********")
        print("Error: \(error.localizedDescription)")
        print("Debug: \(String(reflecting: error))")
        print("==========================================")
        print("")
    }

    static func logDecodedResponse<T: Encodable>(_ response: T, apiName: String) {
        print("---------- API DECODED: \(apiName) ----------")
        if let data = try? JSONEncoder.prettyPrintedData(from: response) {
            print(String(data: data, encoding: .utf8) ?? String(describing: response))
        } else {
            print(String(describing: response))
        }
        print("============================================")
        print("")
    }

    private static func formatData(_ data: Data) -> String {
        guard !data.isEmpty else { return "<empty>" }

        if let jsonObject = try? JSONSerialization.jsonObject(with: data),
           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys]),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            return prettyString
        }

        return String(data: data, encoding: .utf8) ?? "<non-UTF8 data>"
    }

    private static func formatDictionary(_ dictionary: [AnyHashable: Any]) -> String {
        let stringDictionary = dictionary.reduce(into: [String: String]()) { partialResult, element in
            partialResult[String(describing: element.key)] = String(describing: element.value)
        }

        guard let data = try? JSONSerialization.data(withJSONObject: stringDictionary, options: [.prettyPrinted, .sortedKeys]),
              let string = String(data: data, encoding: .utf8) else {
            return String(describing: dictionary)
        }

        return string
    }
}

private extension JSONEncoder {
    static func prettyPrintedData<T: Encodable>(from value: T) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(AnyEncodable(value))
    }
}

private struct AnyEncodable: Encodable {
    private let encodeClosure: (Encoder) throws -> Void

    init<T: Encodable>(_ wrapped: T) {
        self.encodeClosure = wrapped.encode
    }

    func encode(to encoder: Encoder) throws {
        try encodeClosure(encoder)
    }
}
