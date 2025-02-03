//
//  SignInView.swift
//  movies
//
//  Created by Terran Winner on 2/2/25.
//

import SwiftUI
import SwiftfulRouting

struct SignInView: View {
    
    @Environment(\.router) var router
    @Environment(\.managedObjectContext) var managedObjectContext
   
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
                    Button(action: {
                        router.dismissScreen()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                   
                    Spacer()
                   
                    Image("netflix_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                   
                    Spacer()
                   
                    Text("Aide")
                        .foregroundColor(.white)
                }
                .padding()
               
                Spacer()
               
                // Form
                VStack(spacing: 16) {
                    // Email field
                    TextField("", text: $email)
                        .placeholder(when: email.isEmpty) {
                            Text("E-mail ou numéro de téléphone")
                                .foregroundColor(.gray)
                                .padding(.leading, 8)
                        }
                        .textFieldStyle(DarkTextFieldStyle())
                   
                    // Password field
                    HStack {
                        if showPassword {
                            TextField("", text: $password)
                                .placeholder(when: password.isEmpty) {
                                    Text("Mot de passe")
                                        .foregroundColor(.gray)
                                        .padding(.leading, 8)
                                }
                        } else {
                            SecureField("", text: $password)
                                .placeholder(when: password.isEmpty) {
                                    Text("Mot de passe")
                                        .foregroundColor(.gray)
                                        .padding(.leading, 8)
                                }
                        }
                       
                        Button(action: {
                            showPassword.toggle()
                        }) {
                            Text(showPassword ? "MASQUER" : "AFFICHER")
                                .foregroundColor(.gray)
                        }
                    }
                    .textFieldStyle(DarkTextFieldStyle())
                   
                    // Sign In button
                    Button(action: signIn) {
                        Text("S'identifier")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                   
                    Text("OU")
                        .foregroundColor(.gray)
                   
                    Button(action: {
                        router.showScreen(.push) { _ in
                            RegisterView()
                        }
                    }) {
                        Text("Utiliser un code d'identification")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                   
                    Button(action: {}) {
                        Text("Mot de passe oublié ?")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
               
                Spacer()
               
                // Bottom text
                Text("L'identification est protégée par Google\nreCAPTCHA pour nous assurer que vous n'êtes\npas un robot. En savoir plus.")
                    .multilineTextAlignment(.center)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom)
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
        // Validate inputs
        guard !email.isEmpty, !password.isEmpty else {
            alertMessage = "Please fill in all fields"
            showAlert = true
            return
        }
       
        // Check credentials against CoreData
        let fetchRequest = MovieUser.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@ AND password == %@", email, password)
       
        do {
            let users = try managedObjectContext.fetch(fetchRequest)
            if let user = users.first {
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
        } catch {
            alertMessage = "Error signing in"
            showAlert = true
        }
    }
}


#Preview {
    RouterView { _ in
        SignInView()
    }
   
  
}
