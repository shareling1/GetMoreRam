//
//  SettingsView.swift
//  Entitlement
//
//  Created by s s on 2025/3/14.
//  Translated by jlj1102 on 2026/2/19.

import SwiftUI
import StosSign
import PrivacyScreen

struct SettingsView: View {

    @State var email = ""
    @State var teamId = ""
    @StateObject var viewModel : LoginViewModel
    @EnvironmentObject private var sharedModel : SharedModel
    
    @State private var errorShow = false
    @State private var errorInfo = ""
    

    var body: some View {
        Form {

            Section {
                if sharedModel.isLogin {
                    HStack {
                        Text("email")
                        Spacer()
                        Text(email)
                            .privacySensitive(level: .high)
                    }
                    HStack {
                        Text("teamid")
                        Spacer()
                        Text(teamId)
                            .privacySensitive(level: .high)
                    }
                } else {
                    Button("login") {
                        viewModel.loginModalShow = true
                    }
                }
            } header: {
                Text("account")
            }
            
            Section {
                HStack {
                    Text("aniserv")
                    Spacer()
                    TextField("", text: $sharedModel.anisetteServerURL)
                        .multilineTextAlignment(.trailing)
                }
            } footer: {
                Text("aniservdesc")
            }
            
            Section {
                Button("clrkey") {
                    cleanUp()
                }
            } footer: {
                Text("clrkeydesc")
            }
        }
        .alert("err", isPresented: $errorShow){
            Button("ok".loc, action: {
            })
        } message: {
            Text(errorInfo)
        }
        
        .sheet(isPresented: $viewModel.loginModalShow) {
            loginModal
        }
    }
    
    var loginModal: some View {
        NavigationView {
            Form {
                Section {
                    TextField("", text: $viewModel.appleID)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .disabled(viewModel.isLoginInProgress)
                        .privacySensitive(level: .high)
                } header: {
                    Text("Apple ID")
                }
                Section {
                    SecureField("", text: $viewModel.password)
                        .disabled(viewModel.isLoginInProgress)
                } header: {
                    Text("password")
                }
                if viewModel.needVerificationCode {
                    Section {
                        TextField("", text: $viewModel.verificationCode)
                            .privacySensitive(level: .high)
                    } header: {
                        Text("twofa")
                    }
                }
                Section {
                    Button("continue") {
                        Task{ await loginButtonClicked() }
                    }
                }
                
                Section {
                    Text(viewModel.logs)
                        .font(.system(.subheadline, design: .monospaced))
                        .privacySensitive(level: .medium)
                } header: {
                    Text("debugging")
                }
            }
            .navigationTitle("login")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("cancel", role: .cancel) {
                        viewModel.loginModalShow = false
                    }
                }
            }
        }
        .onAppear {
            if let email = Keychain.shared.appleIDEmailAddress, let password = Keychain.shared.appleIDPassword {
                viewModel.appleID = email
                viewModel.password = password
            }
        }
    }
    
    func loginButtonClicked() async {
        do {
            if viewModel.needVerificationCode {
                viewModel.submitVerficationCode()
                return
            }
            
            let result = try await viewModel.authenticate()
            if result {
                viewModel.loginModalShow = false
                email = sharedModel.account!.appleID
                teamId = sharedModel.team!.identifier
            }
            
        } catch {
            errorInfo = error.localizedDescription
            errorShow = true
        }
    }
    
    func cleanUp() {
        Keychain.shared.adiPb = nil
        Keychain.shared.identifier = nil
        Keychain.shared.appleIDPassword = nil
        Keychain.shared.appleIDEmailAddress = nil
    }
    
}
