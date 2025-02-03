//
//  RegisterView.swift
//  movies
//
//  Created by Terran Winner on 2/2/25.
//

import SwiftUI
import SwiftfulRouting

struct RegisterView: View {
    @Environment(\.router) var router
    @Environment(\.managedObjectContext) var managedObjectContext
   
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var dateOfBirth = Date()
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
   
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
           
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        router.dismissScreen()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                   
                    Spacer()
                   
                    Text("Register")
                        .foregroundColor(.white)
                        .font(.headline)
                   
                    Spacer()
                }
                .padding()
               
                // Form
                VStack(spacing: 24) {
                    TextField("", text: $name)
                        .placeholder(when: name.isEmpty) {
                            Text("Name")
                                .foregroundColor(.gray)
                                .padding(.leading, 8)
                        }
                        .textFieldStyle(DarkTextFieldStyle())
                   
                    TextField("", text: $email)
                        .placeholder(when: email.isEmpty) {
                            Text("Email")
                                .foregroundColor(.gray)
                                .padding(.leading, 8)
                        }
                        .textFieldStyle(DarkTextFieldStyle())
                   
                    SecureField("", text: $password)
                        .placeholder(when: password.isEmpty) {
                            Text("Password")
                                .foregroundColor(.gray)
                                .padding(.leading, 8)
                        }
                        .textFieldStyle(DarkTextFieldStyle())
                   
                    HStack {
                        Text("Date of Birth")
                            .foregroundColor(.gray)
                        Spacer()
                        DatePicker("",
                                  selection: $dateOfBirth,
                                  displayedComponents: .date)
                            .colorScheme(.dark)
                            .accentColor(.red)
                            .labelsHidden()
                    }
                   
                    Button(action: register) {
                        Text("Register")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 40)
               
                Spacer()
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
   
    private func register() {
        // Validate inputs
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            alertMessage = "Please fill in all fields"
            showAlert = true
            return
        }
       
        // Create new user
        let user = MovieUser(context: managedObjectContext)
        user.id = UUID()
        user.name = name
        user.email = email
        user.password = password
        user.dateOfBirth = dateOfBirth
       
        do {
            try managedObjectContext.save()
           
            // Store current user
            UserDefaults.standard.set(user.id.uuidString, forKey: "currentUserId")
           
            // Navigate to HomeView
            router.showScreen(.push) { _ in
                HomeView()
            }
        } catch {
            alertMessage = "Error creating account"
            showAlert = true
        }
    }
}

#Preview {
    
    
    RouterView { _ in
        RegisterView()
    }
   
}
