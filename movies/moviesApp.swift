//
//  moviesApp.swift
//  movies
//
//  Created by Guest User on 11/01/2025.
//

import SwiftUI
import SwiftData
import SwiftfulRouting


enum AppState {
    case loading
    case loggedIn
    case loggedOut
}


@main
struct moviesApp: App {
    let container: ModelContainer
    @State private var appState: AppState = .loading
   
    init() {
        do {
            container = try ModelContainer(
                for: MovieUser.self, DetailedMovie.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: false)
            )
        } catch {
            fatalError("Failed to initialize ModelContainer")
        }
    }
   
    var body: some Scene {
        WindowGroup {
            RouterView { _ in
                Group {
                    switch appState {
                    case .loading:
                        loadingView
                    case .loggedIn:
                        HomeView()
                    case .loggedOut:
                        LandingView()
                    }
                }
                .task {
                 
                    try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                   
                
                    if let userId = UserDefaults.standard.string(forKey: "currentUserId"),
                       let _ = UUID(uuidString: userId) {
                        appState = .loggedIn
                    } else {
                        appState = .loggedOut
                    }
                }
            }
        }
        .modelContainer(container)
    }
   
    private var loadingView: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
           
            VStack {
                Image("netflix_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
               
                ProgressView()
                    .tint(.red)
                    .scaleEffect(1.5)
                    .padding(.top, 20)
            }
        }
    }
}
