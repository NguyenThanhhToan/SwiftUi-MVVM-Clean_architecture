//
//  ChatViewModel.swift
//  swiftUI
//
//  The view model owns the conversation state and the async request lifecycle.
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
    private let wordRevealDelayNanoseconds: UInt64 = 70_000_000

    init(sendChatMessageUseCase: SendChatMessageUseCase) {
        self.sendChatMessageUseCase = sendChatMessageUseCase
        self.messages = [
            ChatMessage(
                role: .model,
                text: "Xin chào, hãy gửi câu hỏi hoặc yêu cầu của bạn."
            )
        ]
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
            let responseText = try await sendChatMessageUseCase.execute(messages: conversation)
            await revealResponseWordByWord(responseText)
        } catch {
            errorMessage = error.localizedDescription
        }
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

        for word in words {
            if !currentText.isEmpty {
                currentText += " "
            }
            currentText += word
            messages[messageIndex] = ChatMessage(role: .model, text: currentText)

            guard word != words.last else { break }
            try? await Task.sleep(nanoseconds: wordRevealDelayNanoseconds)
        }
    }
}
