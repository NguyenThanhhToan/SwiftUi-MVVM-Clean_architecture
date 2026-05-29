//
//  ChatViewModel.swift
//  swiftUI
//
//  The view model owns the conversation state and prepares Gemini context
//  from the currently selected local area and saved notes.
//

import Combine
import Foundation

@MainActor
final class ChatViewModel: ObservableObject {
    @Published private(set) var messages: [ChatMessage]
    @Published var draftText: String = ""
    @Published private(set) var isSending = false
    @Published var errorMessage: String?

    private let sendChatMessageUseCase: SendChatMessageUseCase
    private let getNoteUseCase: GetNoteUseCase
    private let localAreaContextStore: LocalAreaContextStoring
    private let wordRevealDelayNanoseconds: UInt64 = 70_000_000

    init(
        sendChatMessageUseCase: SendChatMessageUseCase,
        getNoteUseCase: GetNoteUseCase,
        localAreaContextStore: LocalAreaContextStoring
    ) {
        self.sendChatMessageUseCase = sendChatMessageUseCase
        self.getNoteUseCase = getNoteUseCase
        self.localAreaContextStore = localAreaContextStore
        self.messages = [
            ChatMessage(
                role: .model,
                text: "Ask me about your selected area, saved notes, travel ideas, or local recommendations."
            )
        ]
    }

    var currentAreaSummary: String {
        localAreaContextStore.currentContext?.displayTitle ?? "No location selected"
    }

    func sendMessage() {
        let trimmedText = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty, !isSending else { return }

        draftText = ""
        errorMessage = nil
        messages.append(ChatMessage(role: .user, text: trimmedText))
        let conversation = messages
        isSending = true

        Task {
            await sendResponse(for: conversation)
        }
    }

    private func sendResponse(for conversation: [ChatMessage]) async {
        defer { isSending = false }

        do {
            let context = try await buildConversationContext()
            let responseText = try await sendChatMessageUseCase.execute(messages: conversation, context: context)
            await revealResponseWordByWord(responseText)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func buildConversationContext() async throws -> ChatConversationContext {
        guard let area = localAreaContextStore.currentContext else {
            return ChatConversationContext(area: nil, noteDigest: "")
        }

        let notes = try await getNoteUseCase.execute(in: area, query: nil)
        let digest = makeNoteDigest(from: notes)
        return ChatConversationContext(area: area, noteDigest: digest)
    }

    private func makeNoteDigest(from notes: [LocalNote]) -> String {
        guard !notes.isEmpty else { return "" }

        return notes
            .prefix(6)
            .map { note in
                "- [\(note.category.title)] \(note.title): \(note.content)"
            }
            .joined(separator: "\n")
    }

    private func revealResponseWordByWord(_ fullText: String) async {
        let words = fullText
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }

        guard !words.isEmpty else {
            messages.append(ChatMessage(role: .model, text: fullText))
            return
        }

        messages.append(ChatMessage(role: .model, text: ""))
        let messageIndex = messages.count - 1
        var currentText = ""

        for (index, word) in words.enumerated() {
            if !currentText.isEmpty {
                currentText += " "
            }
            currentText += word
            messages[messageIndex] = ChatMessage(role: .model, text: currentText)

            guard index < words.count - 1 else { break }
            try? await Task.sleep(nanoseconds: wordRevealDelayNanoseconds)
        }
    }
}
