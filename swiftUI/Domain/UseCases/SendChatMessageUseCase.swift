//
//  SendChatMessageUseCase.swift
//  swiftUI
//
//  The chat screen sends the full conversation through this use case so the
//  model can answer with the current context.
//

import Foundation

struct SendChatMessageUseCase {
    let chatRepository: ChatRepository

    func execute(messages: [ChatMessage], context: ChatConversationContext) async throws -> String {
        try await chatRepository.send(messages: messages, context: context)
    }
}
