//
//  ContentView.swift
//  Snacktacular
//
//  Created by GuitarLearnerJas on 10/10/2024.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct LoginView: View {
    enum Field {
        case email, password
    }
    @FocusState private var focusedField: Field?
    @State private var buttonDisabled: Bool = true
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var alertMessage = ""
    @State private var showingAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            Image("logo")
                .resizable()
                .scaledToFit()
                .padding()
            Group{
                TextField("Enter Your Email Here", text: $email)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .submitLabel(.next)
                    .focused($focusedField, equals: .email)
                    .onSubmit {
                        focusedField = .password
                    }
                    .onChange(of: email) { oldValue, _ in
                        enableButtons()
                    }
                
                SecureField("Password", text: $password)
                    .textInputAutocapitalization(.never)
                    .submitLabel(.done)
                    .focused($focusedField, equals: .password)
                    .onSubmit {
                        focusedField = nil
                    }
                    .onChange(of: password) { oldValue, _ in
                        enableButtons()
                    }
            }
            .textFieldStyle(.roundedBorder)
            .overlay{
                RoundedRectangle(cornerRadius: 5)
                    .stroke(.gray.opacity(0.4), lineWidth: 2)
            }
            .padding(.horizontal)
            
            HStack{
                Button {
                    register()
                } label: {
                    Text("Sign Up")
                }
                .padding(.trailing)
                
                Button {
                    login()
                } label: {
                    Text("Log In")
                }
                .padding(.leading, 5.0)
            }
            .disabled(buttonDisabled)
            .buttonStyle(.borderedProminent)
            .tint(Color("SnackColor"))
            .font(.title2)
            .padding()
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert(alertMessage, isPresented: $showingAlert) {
            Button(role: .cancel) {} label: {
                Text("OK")
            }

        }
    }
    func enableButtons() {
        let validEmail = email.count > 6 && email.contains("@")
        let validPassword = password.count >= 6
        if validEmail && validPassword {
            buttonDisabled = false
        }
    }
    func register(){
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error {  //if there is an error
                print("Sign In Error: \(error.localizedDescription)")
                alertMessage = "Sign In Error: \(error.localizedDescription)"
                showingAlert = true
            } else {
                print("😎 Thanks for your registration!")
                //TODO: Load ListView
            }
        }
    }
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error {  //if there is an error
                print("Login Error: \(error.localizedDescription)")
                alertMessage = "Login Error: \(error.localizedDescription)"
                showingAlert = true
            } else {
                print("Successfully logged in!")
                //TODO: Load ListView
            }
        }
    }
}

#Preview {
    LoginView()
}
