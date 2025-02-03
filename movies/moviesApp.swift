//
//  moviesApp.swift
//  movies
//
//  Created by Guest User on 11/01/2025.
//

import SwiftUI
import SwiftfulRouting

@main
struct moviesApp: App {
    let coreDataManager = CoreDataManager.shared
//    init() {
//        coreDataManager.verifyModelExists()
//    }
    var body: some Scene {
        WindowGroup {
            RouterView { _ in
                LandingView()
            }.environment(\.managedObjectContext, coreDataManager.container.viewContext)
            
        }
    }
}
