import SwiftUI
import SwiftData
import SwiftfulRouting


struct ProfileView: View {
    @Environment(\.router) var router
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [MovieUser]
   
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var currentUser: MovieUser?
    @State private var isEditing: Bool = false
    @State private var showPasswordSheet: Bool = false
   
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
           
            VStack(spacing: 0) {
                // Header
                
                ZStack(alignment: .leading) {
                   
                    HStack {
                        
                        Spacer()
                        Text("Profile")
                            .foregroundColor(.white)
                            .font(.headline)
                       
                        Spacer()
                       
                       
                    }
                    .padding()
                    
                    HStack {
                        BackButton()
                            
                        Spacer()
                        Button(action: logout) {
                            Text("Logout")
                                .foregroundColor(.red)
                        }.padding(.trailing)
                    }
                   
                }
              
               
                // Profile Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Info Section
                        VStack(alignment: .leading, spacing: 16) {
                            if isEditing {
                                // Edit Mode
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Name")
                                        .foregroundColor(.gray)
                                   
                                    TextField("", text: $name)
                                        .textFieldStyle(DarkTextFieldStyle())
                                }
                               
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Email")
                                        .foregroundColor(.gray)
                                   
                                    TextField("", text: $email)
                                        .textFieldStyle(DarkTextFieldStyle())
                                        .autocapitalization(.none)
                                }
                            } else {
                                // Display Mode
                                VStack(alignment: .leading, spacing: 16) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Name")
                                            .foregroundColor(.gray)
                                        Text(name)
                                            .foregroundColor(.white)
                                    }
                                   
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Email")
                                            .foregroundColor(.gray)
                                        Text(email)
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                       
                        // Action Buttons
                        VStack(spacing: 12) {
                            if isEditing {
                                Button(action: updateProfile) {
                                    Text("Save Changes")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.red)
                                        .foregroundColor(.white)
                                        .cornerRadius(4)
                                }
                               
                                Button(action: { isEditing = false }) {
                                    Text("Cancel")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.gray.opacity(0.3))
                                        .foregroundColor(.white)
                                        .cornerRadius(4)
                                }
                            } else {
                                Button(action: { isEditing = true }) {
                                    Text("Edit Profile")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.red)
                                        .foregroundColor(.white)
                                        .cornerRadius(4)
                                }
                               
                                Button(action: { showPasswordSheet = true }) {
                                    Text("Change Password")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.gray.opacity(0.3))
                                        .foregroundColor(.white)
                                        .cornerRadius(4)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showPasswordSheet) {
            PasswordUpdateSheet(currentUser: currentUser, showSheet: $showPasswordSheet)
        }
        .alert("Message", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear(perform: loadUserData)
    }
   
    private func loadUserData() {
        if let userId = UserDefaults.standard.string(forKey: "currentUserId"),
           let uuid = UUID(uuidString: userId),
           let user = users.first(where: { $0.id == uuid }) {
            currentUser = user
            name = user.name
            email = user.email
        }
    }
   
    private func updateProfile() {
        guard let user = currentUser else { return }
       
        // Validate email change
        if email.lowercased() != user.email {
            let formattedEmail = email.lowercased()
           
            // Check if email exists
            let emailExists = users.contains { $0.id != user.id && $0.email == formattedEmail }
            if emailExists {
                alertMessage = "Email already exists"
                showAlert = true
                return
            }
           
            user.email = formattedEmail
        }
       
        // Update name
        let formattedName = SecurityHelper.formatName(name)
        if !formattedName.isEmpty {
            user.name = formattedName
        }
       
        do {
            try modelContext.save()
            alertMessage = "Profile updated successfully"
            showAlert = true
            isEditing = false
        } catch {
            alertMessage = "Error updating profile"
            showAlert = true
        }
    }
   
    private func logout() {
        UserDefaults.standard.removeObject(forKey: "currentUserId")
        router.showScreen(.push) { _ in
            LandingView()
        }
    }
}


struct PasswordUpdateSheet: View {
    @Environment(\.modelContext) private var modelContext
    let currentUser: MovieUser?
    @Binding var showSheet: Bool
   
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
   
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
               
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Password")
                            .foregroundColor(.gray)
                       
                        SecureField("", text: $currentPassword)
                            .textFieldStyle(DarkTextFieldStyle())
                    }
                   
                    VStack(alignment: .leading, spacing: 8) {
                        Text("New Password")
                            .foregroundColor(.gray)
                       
                        SecureField("", text: $newPassword)
                            .textFieldStyle(DarkTextFieldStyle())
                    }
                   
                    Button(action: updatePassword) {
                        Text("Update Password")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                }
                .padding()
            }
            .navigationTitle("Change Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showSheet = false
                    }
                }
            }
        }
        .alert("Message", isPresented: $showAlert) {
            Button("OK", role: .cancel) {
                if alertMessage == "Password updated successfully" {
                    showSheet = false
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
   
    private func updatePassword() {
        guard let user = currentUser else { return }
       
        // Verify both passwords are provided
        guard !currentPassword.isEmpty && !newPassword.isEmpty else {
            alertMessage = "Please provide both current and new password"
            showAlert = true
            return
        }
       
        // Verify current password
        let hashedCurrentPassword = SecurityHelper.hashPassword(currentPassword)
        guard user.password == hashedCurrentPassword else {
            alertMessage = "Current password is incorrect"
            showAlert = true
            return
        }
       
        // Validate new password
        guard SecurityHelper.isValidPassword(newPassword) else {
            alertMessage = "New password must contain at least 8 characters, including uppercase, lowercase, number and special character"
            showAlert = true
            return
        }
       
        // Update password
        user.password = SecurityHelper.hashPassword(newPassword)
       
        do {
            try modelContext.save()
            alertMessage = "Password updated successfully"
            showAlert = true
        } catch {
            alertMessage = "Error updating password"
            showAlert = true
        }
    }
}


#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: MovieUser.self, configurations: config)
   
    // Create and insert sample user
    let sampleUser = MovieUser(
        email: "john.doe@example.com",
        name: "John Doe",
        password: SecurityHelper.hashPassword("Password123!"),
        dateOfBirth: Date()
    )
    container.mainContext.insert(sampleUser)
   
    // Store the sample user's ID in UserDefaults
    UserDefaults.standard.set(sampleUser.id.uuidString, forKey: "currentUserId")
   
    return RouterView { _ in
        ProfileView()
    }
    .modelContainer(container)
}



