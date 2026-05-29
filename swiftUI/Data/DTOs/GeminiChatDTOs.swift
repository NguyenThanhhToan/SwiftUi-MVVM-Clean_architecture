//
//  GeminiChatDTOs.swift
//  swiftUI
//
//  The Gemini REST API uses a small JSON contract. These DTOs isolate that
//  shape from the rest of the app.
//

import Foundation

struct GeminiGenerateContentRequest: Codable {
    let systemInstruction: GeminiContentDTO
    let contents: [GeminiContentDTO]

    enum CodingKeys: String, CodingKey {
        case systemInstruction = "system_instruction"
        case contents
    }
}

struct GeminiContentDTO: Codable {
    let role: String?
    let parts: [GeminiPartDTO]
}

struct GeminiPartDTO: Codable {
    let text: String?
}

struct GeminiGenerateContentResponse: Codable {
    let candidates: [GeminiCandidateDTO]?
}

struct GeminiCandidateDTO: Codable {
    let content: GeminiContentDTO?
}

extension ChatMessage {
    var geminiContent: GeminiContentDTO {
        GeminiContentDTO(
            role: role.rawValue,
            parts: [GeminiPartDTO(text: text)]
        )
    }
}
