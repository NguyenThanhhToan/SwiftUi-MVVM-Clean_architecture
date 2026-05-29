//
//  LocalAreaContextStore.swift
//  swiftUI
//
//  The selected province/district is persisted so notes and chat can reuse it
//  across launches.
//

import Foundation

protocol LocalAreaContextStoring: AnyObject {
    var currentContext: LocalAreaContext? { get set }
    func clear()
}

final class UserDefaultsLocalAreaContextStore: LocalAreaContextStoring {
    private enum Keys {
        static let currentContext = "localArea.currentContext"
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var currentContext: LocalAreaContext? {
        get {
            guard let data = userDefaults.data(forKey: Keys.currentContext) else { return nil }
            return try? JSONDecoder().decode(LocalAreaContext.self, from: data)
        }
        set {
            guard let newValue else {
                userDefaults.removeObject(forKey: Keys.currentContext)
                return
            }

            let data = try? JSONEncoder().encode(newValue)
            userDefaults.set(data, forKey: Keys.currentContext)
        }
    }

    func clear() {
        userDefaults.removeObject(forKey: Keys.currentContext)
    }
}
