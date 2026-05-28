//
//  AuthSessionStore.swift
//  swiftUI
//
//  Temporary auth persistence lives in Core so the app can remember whether
//  the user is signed in until a real token-based flow exists.
//

import Foundation

protocol AuthSessionStoring {
    var isLoggedIn: Bool { get set }
    var currentUser: User? { get set }
    func clear()
}

final class UserDefaultsAuthSessionStore: AuthSessionStoring {
    private enum Keys {
        static let isLoggedIn = "auth.isLoggedIn"
        static let currentUser = "auth.currentUser"
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var isLoggedIn: Bool {
        get {
            userDefaults.bool(forKey: Keys.isLoggedIn)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.isLoggedIn)
        }
    }

    var currentUser: User? {
        get {
            guard let data = userDefaults.data(forKey: Keys.currentUser) else { return nil }
            return try? JSONDecoder().decode(User.self, from: data)
        }
        set {
            guard let newValue else {
                userDefaults.removeObject(forKey: Keys.currentUser)
                return
            }

            let data = try? JSONEncoder().encode(newValue)
            userDefaults.set(data, forKey: Keys.currentUser)
        }
    }

    func clear() {
        userDefaults.removeObject(forKey: Keys.isLoggedIn)
        userDefaults.removeObject(forKey: Keys.currentUser)
    }
}
