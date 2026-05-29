//
//  ChatMessage.swift
//  swiftUI
//
//  Chat messages stay in the domain layer so the Gemini repository and the
//  SwiftUI screen can share the same conversation model.
//

import Foundation

enum ChatRole: String, Codable, Equatable {
    case user
    case model
}

struct ChatMessage: Identifiable, Equatable {
    let id: UUID
    let role: ChatRole
    let text: String

    init(id: UUID = UUID(), role: ChatRole, text: String) {
        self.id = id
        self.role = role
        self.text = text
    }
}
