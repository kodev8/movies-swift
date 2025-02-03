//
//  moviesApp.swift
//  movies
//
//  Created by Guest User on 11/01/2025.
//


import SwiftUI
import SwiftData
import SwiftfulRouting


@main
struct moviesApp: App {
    let container: ModelContainer
   
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
                LandingView()
            }
        }
        .modelContainer(container)
    }
}





