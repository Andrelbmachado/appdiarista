//
//  AuthViewModel.swift
//  Diarista facil
//
//  Created by André Machado on 20/01/26.
//

import Foundation
import Combine

enum UserType: Hashable {
    case client
    case cleaner
}

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var loginError: String?
    @Published var currentUserType: UserType?
    @Published var clientAddresses: [String]
    @Published var cleanerCoverageAreas: [String]

    private let authService: AuthService

    init(authService: AuthService = MockDataService.shared) {
        self.authService = authService
        self.clientAddresses = authService.clientAddresses()
        self.cleanerCoverageAreas = authService.cleanerCoverageAreas()
    }

    func login(email: String, password: String, userType: UserType) {
        if authService.authenticate(email: email, password: password, userType: userType) {
            isLoggedIn = true
            currentUserType = userType
            loginError = nil
        } else {
            isLoggedIn = false
            loginError = "Login ou senha incorretos."
        }
    }

    func changePassword(for userType: UserType, oldPassword: String, newPassword: String) -> Bool {
        guard authService.changePassword(for: userType, oldPassword: oldPassword, newPassword: newPassword) else {
            loginError = "Senha atual incorreta."
            return false
        }
        loginError = nil
        return true
    }
}
