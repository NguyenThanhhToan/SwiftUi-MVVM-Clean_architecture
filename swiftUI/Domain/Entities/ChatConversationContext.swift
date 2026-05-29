//
//  ChatConversationContext.swift
//  swiftUI
//
//  Gemini receives a local context payload so responses can be grounded in
//  the selected area and the user's saved notes.
//

import Foundation

struct ChatConversationContext: Equatable {
    let area: LocalAreaContext?
    let noteDigest: String
}
