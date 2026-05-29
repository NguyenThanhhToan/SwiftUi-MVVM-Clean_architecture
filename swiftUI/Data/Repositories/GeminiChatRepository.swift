//
//  GeminiChatRepository.swift
//  swiftUI
//
//  This repository sends the full conversation to Gemini using the REST API.
//  The response is parsed into a single assistant message for the UI.
//

import Foundation

final class GeminiChatRepository: ChatRepository {
    private let session: URLSession
    private let apiKeyProvider: () throws -> String
    private let modelName: String

    init(
        session: URLSession = .shared,
        modelName: String = GeminiConfiguration.modelName,
        apiKeyProvider: @escaping () throws -> String = GeminiConfiguration.apiKey
    ) {
        self.session = session
        self.modelName = modelName
        self.apiKeyProvider = apiKeyProvider
    }

    func send(messages: [ChatMessage], context: ChatConversationContext) async throws -> String {
        let apiKey = try apiKeyProvider()
        let request = try makeRequest(messages: messages, context: context, apiKey: apiKey)

        APILogger.logRequest(request, apiName: "Gemini Chat")

        do {
            let (data, response) = try await session.data(for: request)
            APILogger.logResponse(response, data: data, apiName: "Gemini Chat")
            try validate(response: response, data: data)

            let decodedResponse = try JSONDecoder().decode(GeminiGenerateContentResponse.self, from: data)
            APILogger.logDecodedResponse(decodedResponse, apiName: "Gemini Chat")

            guard let answer = decodedResponse.candidates?
                .first?
                .content?
                .parts
                .compactMap(\.text)
                .joined(separator: "\n")
                .trimmingCharacters(in: .whitespacesAndNewlines),
                  !answer.isEmpty else {
                throw URLError(.badServerResponse)
            }

            return answer
        } catch {
            APILogger.logError(error, apiName: "Gemini Chat")
            throw error
        }
    }

    private func makeRequest(messages: [ChatMessage], context: ChatConversationContext, apiKey: String) throws -> URLRequest {
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/\(modelName):generateContent"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-goog-api-key")
        request.httpBody = try JSONEncoder().encode(
            GeminiGenerateContentRequest(
                systemInstruction: GeminiContentDTO(
                    role: "system",
                    parts: [
                        GeminiPartDTO(
                            text: makeSystemInstruction(context: context)
                        )
                    ]
                ),
                contents: messages.map { $0.geminiContent }
            )
        )

        return request
    }

    private func makeSystemInstruction(context: ChatConversationContext) -> String {
        let areaText = context.area?.displayTitle ?? "No selected area"
        let noteText = context.noteDigest.isEmpty ? "No saved local notes yet." : context.noteDigest

        return """
        You are Local Life AI, a premium local assistant for city and district planning, note organization, and recommendations.
        Reply naturally in the user's language.
        Keep answers concise unless the user asks for detail.
        Current selected area: \(areaText)
        Relevant saved local notes:
        \(noteText)
        Use the local notes and selected area as context when making suggestions, summaries, itineraries, and rewrites.
        If information is missing, say so clearly and offer a practical next step.
        """
    }

    private func validate(response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        guard !data.isEmpty else {
            throw URLError(.zeroByteResource)
        }
    }
}
