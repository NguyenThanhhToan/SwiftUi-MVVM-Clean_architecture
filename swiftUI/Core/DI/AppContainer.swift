//
//  AppContainer.swift
//  swiftUI
//
//  The dependency container builds the object graph for the app.
//  Presentation asks for view models, the container wires them to use cases
//  and repositories, and the lower layers remain unaware of SwiftUI.
//

import Foundation
import SwiftData

final class AppContainer {
    private let authRepository: AuthRepository
    private let provinceRepository: ProvinceRepository
    private let districtRepository: DistrictRepository
    private let noteRepository: NoteRepository
    private let chatRepository: ChatRepository
    private let localAreaContextStore: LocalAreaContextStoring
    private var authSessionStore: AuthSessionStoring
    private let loginUseCase: LoginUseCase
    private let getProvincesUseCase: GetProvincesUseCase
    private let getDistrictsUseCase: GetDistrictsUseCase
    private let getNoteUseCase: GetNoteUseCase
    private let saveNoteUseCase: SaveNoteUseCase
    private let deleteNoteUseCase: DeleteNoteUseCase
    private let sendChatMessageUseCase: SendChatMessageUseCase

    init(modelContainer: ModelContainer) {
        self.authRepository = MockAuthRepository()
        self.provinceRepository = GhnProvinceRepository()
        self.districtRepository = GhnDistrictRepository()
        self.noteRepository = SwiftDataNoteRepository(modelContainer: modelContainer)
        self.chatRepository = GeminiChatRepository()
        self.localAreaContextStore = UserDefaultsLocalAreaContextStore()
        self.authSessionStore = UserDefaultsAuthSessionStore()
        self.loginUseCase = LoginUseCase(authRepository: authRepository)
        self.getProvincesUseCase = GetProvincesUseCase(provinceRepository: provinceRepository)
        self.getDistrictsUseCase = GetDistrictsUseCase(districtRepository: districtRepository)
        self.getNoteUseCase = GetNoteUseCase(noteRepository: noteRepository)
        self.saveNoteUseCase = SaveNoteUseCase(noteRepository: noteRepository)
        self.deleteNoteUseCase = DeleteNoteUseCase(noteRepository: noteRepository)
        self.sendChatMessageUseCase = SendChatMessageUseCase(chatRepository: chatRepository)
    }

    @MainActor
    func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(loginUseCase: loginUseCase)
    }

    @MainActor
    func makeHomeViewModel(user: User) -> HomeViewModel {
        HomeViewModel(
            user: user,
            getProvincesUseCase: getProvincesUseCase,
            localAreaContextStore: localAreaContextStore
        )
    }

    @MainActor
    func makeDistrictViewModel(province: Province) -> DistrictViewModel {
        DistrictViewModel(
            province: province,
            getDistrictsUseCase: getDistrictsUseCase,
            localAreaContextStore: localAreaContextStore
        )
    }

    @MainActor
    func makeNotesViewModel() -> NotesViewModel {
        NotesViewModel(
            getNoteUseCase: getNoteUseCase,
            saveNoteUseCase: saveNoteUseCase,
            deleteNoteUseCase: deleteNoteUseCase,
            localAreaContextStore: localAreaContextStore
        )
    }

    @MainActor
    func makeChatViewModel() -> ChatViewModel {
        ChatViewModel(
            sendChatMessageUseCase: sendChatMessageUseCase,
            getNoteUseCase: getNoteUseCase,
            localAreaContextStore: localAreaContextStore
        )
    }

    func makeLocalAreaContextStore() -> LocalAreaContextStoring {
        localAreaContextStore
    }

    @MainActor
    func makeSettingsViewModel(user: User, onLogout: @escaping () -> Void) -> SettingsViewModel {
        SettingsViewModel(user: user, clearSession: { [weak self] in
            self?.clearLoggedInState()
        }, onLogout: onLogout)
    }

    func makeAuthSessionStore() -> AuthSessionStoring {
        authSessionStore
    }

    func saveLoggedInState(user: User) {
        authSessionStore.isLoggedIn = true
        authSessionStore.currentUser = user
    }

    func clearLoggedInState() {
        authSessionStore.clear()
        authSessionStore.isLoggedIn = false
        authSessionStore.currentUser = nil
        localAreaContextStore.clear()
    }
}
