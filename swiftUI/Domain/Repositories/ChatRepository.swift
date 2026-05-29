//
//  ChatRepository.swift
//  swiftUI
//
//  Chat is expressed as a repository so the UI can stay ignorant of Gemini's
//  request and response payloads.
//

import Foundation

protocol ChatRepository {
    func send(messages: [ChatMessage], context: ChatConversationContext) async throws -> String
}
