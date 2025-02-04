//
//  LandingView.swift
//  movies
//
//  Created by Terran Winner on 2/2/25.
//

import SwiftUI
import SwiftfulRouting
import SwiftData


struct LandingView: View {
    @Environment(\.router) var router
   
    var body: some View {
        ZStack {
            // Background
            Color.black.edgesIgnoringSafeArea(.all)
           
            VStack(spacing: 0) {
                // Top bar with Netflix logo and Sign In
                HStack {
                    Image(uiImage: UIImage(named: "netflix_logo.png")!)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120)
                   
                    Spacer()
                   
                    Button(action: {
                        router.showScreen(.push) { _ in
                            SignInView()
                        }
                    }) {
                        Text("Sign In")
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(8)
                    }
                }
                .padding()
               
                Spacer()
               
                // Center content
                VStack(spacing: 24) {
                    // Illustration
                    Image("watch_everywhere")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 300)
                   
                    // Text content
                    VStack(spacing: 16) {
                        Text("Watch everywhere")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                       
                        Text("Stream on your phone, tablet,\nlaptop and TV.")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                }
               
                Spacer()
               
                // Bottom content
                VStack(spacing: 24) {
                    // Create account button (styled as a link)
                    Button(action: {
                        // Navigate to HomeView
                        router.showScreen(.push) { _ in
                            HomeView()
                        }
                    }) {
                        Text("Create a Netflix account")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    .background(Color.black.opacity(0.3))
                            )
                            .asButton(.press){
                                router.showScreen(.push) { _ in
                                    RegisterView()
                                }
                            }
                    }
                    .padding(.horizontal)
                   
                    // Bottom text
                    Text("Go to netflix.com/more")
                        .foregroundColor(.blue)
                        .padding(.bottom, 32)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}


#Preview {
    let container: ModelContainer = {
        do {
            return try ModelContainer(
                for: MovieUser.self, DetailedMovie.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: false)
            )
        } catch {
            fatalError("Failed to initialize ModelContainer")
        }
    }()
    
    RouterView { _ in
        LandingView()
    }
    .modelContainer(container)
}




