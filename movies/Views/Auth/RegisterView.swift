//
//  RegisterView.swift
//  movies
//
//  Created by Terran Winner on 2/2/25.
//




import SwiftUI
import SwiftData
import SwiftfulRouting




struct RegisterView: View {
    @Environment(\.router) var router
    @Environment(\.modelContext) private var modelContext
   
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
                
                ZStack(alignment: .leading) {
                    BackButton()
                    HStack {
                      
                       
                        Spacer()
                       
                        Text("Register")
                            .foregroundColor(.white)
                            .font(.headline)
                       
                        Spacer()
                    }
                    .padding()
                }
                
               
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
        // Format inputs
        let formattedEmail = email.lowercased()
        let formattedName = SecurityHelper.formatName(name)
       
        // Validate all fields
        guard !formattedName.isEmpty, !formattedEmail.isEmpty, !password.isEmpty else {
            alertMessage = "Please fill in all fields"
            showAlert = true
            return
        }
       
        // Validate password
        guard SecurityHelper.isValidPassword(password) else {
            alertMessage = "Password must contain at least 8 characters, including uppercase, lowercase, number and special character"
            showAlert = true
            return
        }
       
        // Check for duplicate email
        let existingUser = try? modelContext.fetch(FetchDescriptor<MovieUser>(
            predicate: #Predicate<MovieUser> { user in
                user.email == formattedEmail
            }
        )).first
       
        if existingUser != nil {
            alertMessage = "Email already registered"
            showAlert = true
            return
        }
       
        // Hash password and create user
        let hashedPassword = SecurityHelper.hashPassword(password)
       
        let user = MovieUser(
            email: formattedEmail,
            name: formattedName,
            password: hashedPassword,
            dateOfBirth: dateOfBirth
        )
       
        modelContext.insert(user)
       
        do {
            try modelContext.save()
            UserDefaults.standard.set(user.id.uuidString, forKey: "currentUserId")
           
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















