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
    struct Credentials {
        let email: String
        let password: String
    }

    @Published var isLoggedIn = false
    @Published var loginError: String?
    @Published var currentUserType: UserType?
    @Published var clientAddresses: [String] = [
        "Rua das Flores, 123, Cidade, Estado",
        "Av. Paulista, 1500, São Paulo",
        "Rua do Mercado, 45, Centro"
    ]
    @Published var cleanerCoverageAreas: [String] = [
        "São Paulo e região",
        "Avenida Paulista",
        "Bairro Jardins"
    ]
    private var clientCredentials = Credentials(email: "cliente@diarista.com", password: "cliente123")
    private var cleanerCredentials = Credentials(email: "diarista@diarista.com", password: "diarista123")

    func login(email: String, password: String, userType: UserType) {
        let expected = userType == .client ? clientCredentials : cleanerCredentials
        if email.lowercased() == expected.email.lowercased() && password == expected.password {
            isLoggedIn = true
            currentUserType = userType
            loginError = nil
        } else {
            isLoggedIn = false
            loginError = "Login ou senha incorretos."
        }
    }

    func changePassword(for userType: UserType, oldPassword: String, newPassword: String) -> Bool {
        var credentials = userType == .client ? clientCredentials : cleanerCredentials
        guard oldPassword == credentials.password else {
            loginError = "Senha atual incorreta."
            return false
        }
        credentials = Credentials(email: credentials.email, password: newPassword)
        if userType == .client {
            clientCredentials = credentials
        } else {
            cleanerCredentials = credentials
        }
        loginError = nil
        return true
    }
}
