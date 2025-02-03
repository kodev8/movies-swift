//
//  MovieUser.swift
//  movies
//
//  Created by Terran Winner on 2/2/25.
//

import Foundation
import SwiftData


@Model
class MovieUser {
    var id: UUID
    var email: String
    var name: String
    var password: String
    var dateOfBirth: Date
    @Relationship(deleteRule: .cascade) var movies: [DetailedMovie]
   
    init(email: String, name: String, password: String, dateOfBirth: Date) {
        self.id = UUID()
        self.email = email
        self.name = name
        self.password = password
        self.dateOfBirth = dateOfBirth
        self.movies = []
    }
   
    // For preview
    static var preview: MovieUser {
        MovieUser(
            email: "test@example.com",
            name: "John Doe",
            password: "password123",
            dateOfBirth: Date()
        )
    }
}




