//
//  SignInView.swift
//  movies
//
//  Created by Terran Winner on 2/2/25.
//


import SwiftUI
import SwiftfulRouting
import SwiftData




struct SignInView: View {
   
    @Environment(\.router) var router
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [MovieUser]
   
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
   
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
           
            VStack(spacing: 20) {
                // Header
                HStack {
                    BackButton()
                   
                    Spacer()
                   
                    Image("netflix_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                   
                    Spacer()
                   
                    Text("Help")
                        .foregroundColor(.white)
                }
                .padding()
               
                Spacer()
               
                // Form
                VStack(spacing: 16) {
                    // Email field
                    TextField("", text: $email)
                        .placeholder(when: email.isEmpty) {
                            Text("E-mail")
                                .foregroundColor(.gray)
                                .padding(.leading, 8)
                        }
                        .textFieldStyle(DarkTextFieldStyle())
                   
                    // Password field
                    ZStack(alignment: .trailing) {
                        if showPassword {
                            TextField("", text: $password)
                                .placeholder(when: password.isEmpty) {
                                    Text("Password")
                                        .foregroundColor(.gray)
                                        .padding(.leading, 8)
                                }
                        } else {
                            SecureField("", text: $password)
                                .placeholder(when: password.isEmpty) {
                                    Text("Password")
                                        .foregroundColor(.gray)
                                        .padding(.leading, 8)
                                }
                        }
                       
                        Button(action: {
                            showPassword.toggle()
                        }) {
                            Text(showPassword ? "SHOW" : "HIDE")
                                .foregroundColor(.gray)
                        }.padding(.trailing)
                    }
                    .textFieldStyle(DarkTextFieldStyle())
                   
                    // Sign In button
                    Button(action: signIn) {
                        Text("Sign In")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                   
                    Text("OR")
                        .foregroundColor(.gray)
                   
                    Text("Don't have an account?")
                        .foregroundStyle(.white)
                    Button(action: {
                        router.showScreen(.push) { _ in
                            RegisterView()
                        }
                    }) {
                        Text("Sign Up")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                   
                    Button(action: {}) {
                        
                    }
                }
                .padding(.horizontal)
               
                Spacer()
               
                // Bottom text
            
            }
        }
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
   
    private func signIn() {
        guard !email.isEmpty, !password.isEmpty else {
            alertMessage = "Please fill in all fields"
            showAlert = true
            return
        }
       
        let formattedEmail = email.lowercased()
        let hashedPassword = SecurityHelper.hashPassword(password)
       
        if let user = users.first(where: {
            $0.email.lowercased() == formattedEmail &&
            $0.password == hashedPassword
        }) {
            // Store current user
            UserDefaults.standard.set(user.id.uuidString, forKey: "currentUserId")
           
            // Navigate to HomeView
            router.showScreen(.push) { _ in
                HomeView()
            }
        } else {
            alertMessage = "Invalid credentials"
            showAlert = true
        }
    }
}




#Preview {
    RouterView { _ in
        SignInView()
    }
   
 
}
