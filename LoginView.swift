//
//  LoginView.swift
//  Diarista facil
//
//  Created by André Machado on 20/01/26.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var selectedUserType: UserType = .client
    @State private var isPasswordVisible = false
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 36) { // Texto acessando como pra baixo
                    Text("Diarista Fácil")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(primaryTextColor)
                        .padding(.top, 36) // Diarista <-> teto
                    VStack(alignment: .center, spacing: 32) { // botao cliente/diarista pra baixo
                        Text("Acessando como:")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(primaryTextColor.opacity(0.7))
                            .frame(maxWidth: .infinity, alignment: .center)
                        userToggle
                    }
                    Spacer().frame(height: 12)
                    VStack(spacing: 24) { //Botao login pra baixo
                        loginFields
                        actionButtons
                        socialLogin
                        footer
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }

    private var loginFields: some View {
        VStack(spacing: 16) {
            roundedField(placeholder: "E-mail", text: $email, isSecure: false)
            passwordField
            HStack {
                Spacer()
                Button("Esqueceu a senha?") {}
                    .font(.footnote)
                    .foregroundColor(secondaryTextColor)
            }
        }
    }

    private func roundedField(placeholder: String, text: Binding<String>, isSecure: Bool) -> some View {
        HStack {
            if isSecure {
                SecureField(placeholder, text: text)
                    .foregroundColor(fieldTextColor)
            } else {
                TextField(placeholder, text: text)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .foregroundColor(fieldTextColor)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 54)
                .fill(fieldBackgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 54)
                .stroke(fieldBorderColor, lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 54))
    }

    private var passwordField: some View {
        HStack {
            Group {
                if isPasswordVisible {
                    TextField("Senha", text: $password)
                        .textInputAutocapitalization(.never)
                        .foregroundColor(fieldTextColor)
                } else {
                    SecureField("Senha", text: $password)
                        .foregroundColor(fieldTextColor)
                }
            }
            Button {
                isPasswordVisible.toggle()
            } label: {
                Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 54)
                .fill(fieldBackgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 54)
                .stroke(fieldBorderColor, lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 54))
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                authViewModel.login(email: email, password: password, userType: selectedUserType)
            } label: {
                Text("Login")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(colorScheme == .dark ? Color.blue : Color.black)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            Text("ou continue com")
                .font(.caption)
                .foregroundColor(secondaryTextColor)
        }
    }

    private var socialLogin: some View {
        HStack(spacing: 16) {
            socialIconButton(icon: "g.circle", tint: .red)
            socialIconButton(icon: "applelogo", tint: .black)
            socialIconButton(icon: "f.circle", tint: Color(red: 59/255, green: 89/255, blue: 152/255))
        }
    }

    private func socialIconButton(icon: String, tint: Color) -> some View {
        Button {} label: {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(tint)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }

    private var footer: some View {
        HStack(spacing: 4) {
            Text("Ainda não tem conta?")
                .foregroundColor(secondaryTextColor)
            NavigationLink("Cadastre-se", destination: RegistrationView(userType: selectedUserType))
                .foregroundColor(.green)
        }
        .font(.footnote)
    }

    private var userToggle: some View {
        HStack(spacing: 24) {
            userToggleButton(title: "Cliente", type: .client)
            userToggleButton(title: "Diarista", type: .cleaner)
        }
    }

    private func userToggleButton(title: String, type: UserType) -> some View {
        Button {
            selectedUserType = type
        } label: {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 54, style: .continuous)
                        .fill(selectedUserType == type ? Color.blue : toggleBackgroundColor)
                )
                .foregroundColor(selectedUserType == type ? .white : primaryTextColor)
        }
        .buttonStyle(.plain)
    }

    private var backgroundColor: Color {
        colorScheme == .dark ? Color.black : Color.white
    }

    private var primaryTextColor: Color {
        colorScheme == .dark ? Color.white : Color.black
    }

    private var secondaryTextColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.7) : .secondary
    }

    private var fieldBackgroundColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.08) : Color.white
    }

    private var fieldBorderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.5) : Color.black.opacity(0.5)
    }

    private var fieldTextColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.95) : Color.black
    }

    private var fieldPlaceholderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.7) : Color.black.opacity(0.7)
    }

    private var toggleBackgroundColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.15) : Color(.secondarySystemBackground)
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
        .environmentObject(AppearanceSettings())
}
