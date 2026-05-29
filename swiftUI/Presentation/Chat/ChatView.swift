//
//  ChatView.swift
//  swiftUI
//
//  The chat screen keeps the UI focused on conversation, with a compact
//  composer and Gemini-styled bubbles.
//

import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel
    @FocusState private var isComposerFocused: Bool

    init(viewModel: ChatViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            backgroundView

            VStack(spacing: 18) {
                headerSection

                messagesSection

                composerSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 16)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isComposerFocused = false
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension ChatView {
    var headerSection: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThinMaterial)
                    .frame(width: 56, height: 56)

                Image(systemName: "sparkles")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.cyan)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Local Life AI")
                    .font(.system(size: 32, weight: .bold))

                Text(viewModel.currentAreaSummary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }

    var messagesSection: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        ChatBubble(message: message)
                            .id(message.id)
                    }

                    if viewModel.isSending {
                        HStack {
                            TypingBubble()
                            Spacer()
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: viewModel.messages.count) { _, _ in
                scrollToLatest(using: proxy)
            }
            .onChange(of: viewModel.isSending) { _, _ in
                scrollToLatest(using: proxy)
            }
            .onAppear {
                scrollToLatest(using: proxy)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.white.opacity(0.45), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.08), radius: 24, x: 0, y: 12)
        }
    }

    var composerSection: some View {
        VStack(spacing: 10) {
            if let errorMessage = viewModel.errorMessage {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)

                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.orange.opacity(0.10))
                )
            }

            HStack(alignment: .bottom, spacing: 10) {
                TextField("Nhập tin nhắn...", text: $viewModel.draftText, axis: .vertical)
                    .lineLimit(1...4)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 22)
                            .fill(Color.white.opacity(0.92))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(Color.cyan.opacity(0.16), lineWidth: 1)
                    )
                    .focused($isComposerFocused)
                    .submitLabel(.send)
                    .onSubmit {
                        viewModel.sendMessage()
                    }

                Button {
                    viewModel.sendMessage()
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(sendButtonBackground)
                            .frame(width: 54, height: 54)

                        if viewModel.isSending {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                                .offset(x: 1, y: -1)
                        }
                    }
                }
                .disabled(viewModel.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isSending)
                .opacity(viewModel.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.65 : 1)
            }
        }
    }

    var backgroundView: some View {
        LinearGradient(
            colors: [
                Color.cyan.opacity(0.16),
                Color.blue.opacity(0.08),
                Color.white
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(Color.blue.opacity(0.12))
                .frame(width: 240)
                .blur(radius: 44)
                .offset(x: 82, y: -42)
        }
    }

    var sendButtonBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color.cyan,
                Color.blue
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    func scrollToLatest(using proxy: ScrollViewProxy) {
        guard let lastMessage = viewModel.messages.last else { return }
        withAnimation(.easeOut(duration: 0.2)) {
            proxy.scrollTo(lastMessage.id, anchor: .bottom)
        }
    }
}

private struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.role == .model {
                bubble
                Spacer(minLength: 40)
            } else {
                Spacer(minLength: 40)
                bubble
            }
        }
    }

    private var bubble: some View {
        Text(message.text)
            .font(.body)
            .foregroundStyle(message.role == .user ? .white : .primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(borderColor, lineWidth: 1)
            )
            .frame(maxWidth: 280, alignment: message.role == .user ? .trailing : .leading)
    }

    private var backgroundColor: AnyShapeStyle {
        switch message.role {
        case .user:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [Color.blue, Color.cyan],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .model:
            return AnyShapeStyle(Color.white.opacity(0.94))
        }
    }

    private var borderColor: Color {
        switch message.role {
        case .user:
            return Color.white.opacity(0.12)
        case .model:
            return Color.cyan.opacity(0.12)
        }
    }
}

private struct TypingBubble: View {
    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(Color.cyan.opacity(0.8)).frame(width: 8, height: 8)
            Circle().fill(Color.cyan.opacity(0.55)).frame(width: 8, height: 8)
            Circle().fill(Color.cyan.opacity(0.35)).frame(width: 8, height: 8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white.opacity(0.94))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.cyan.opacity(0.12), lineWidth: 1)
        )
    }
}
