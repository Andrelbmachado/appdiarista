//
//  RegistrationView.swift
//  Diarista facil
//
//  Created by André Machado on 20/01/26.
//

import SwiftUI

struct RegistrationView: View {
    let userType: UserType
    @State private var name = ""
    @State private var email = ""
    @State private var age = ""
    @State private var cpf = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var isRegistered = false
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 10)
            Image("AppLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 110, height: 110)
                .clipShape(RoundedRectangle(cornerRadius: 56, style: .continuous))
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 5)
            Text("Diarista Fácil")
                .font(.system(.title3, design: .rounded))
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            Text("Cadastro")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            TextField("Nome completo", text: $name)
                .textFieldStyle(.roundedBorder)
            
            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            TextField("Idade", text: $age)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
            
            TextField("CPF", text: $cpf)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
            
            TextField("Telefone para contato", text: $phone)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.phonePad)
            
            SecureField("Senha", text: $password)
                .textFieldStyle(.roundedBorder)
            
            Button(action: {
                // Registration action
                isRegistered = true
            }) {
                Text("Registrar")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(56)
            }
            Spacer(minLength: 10)
        }
        .padding()
        .navigationTitle("Novo " + (userType == .client ? "Cliente" : "Diarista"))
        .fullScreenCover(isPresented: $isRegistered) {
            ContentView()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    RegistrationView(userType: .client)
}
