//
//  swiftUIApp.swift
//  swiftUI
//
//  Created by NUS on 28/5/26.
//

import SwiftUI
import SwiftData

@main
struct swiftUIApp: App {
    private let modelContainer: ModelContainer
    private let container: AppContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: NoteRecord.self)
            container = AppContainer(modelContainer: modelContainer)
        } catch {
            fatalError("Failed to initialize SwiftData container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            AppRootView(container: container)
        }
    }
}
