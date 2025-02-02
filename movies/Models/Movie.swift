//
//  Movie.swift
//  movies
//
//  Created by Guest User on 24/01/2025.
//

import Foundation

struct Movie: Codable, Identifiable {
    let title: String
    let year: String
    let imdbID: String
    let type: String
    let poster: String
    
    // Conform to Identifiable protocol
    var id: String { imdbID }
    
    // Custom coding keys to match API response
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case imdbID = "imdbID"
        case type = "Type"
        case poster = "Poster"
    }
}

// Root response structure from OMDB API
struct MovieResponse: Codable {
    let search: [Movie]
    let totalResults: String
    let response: String
    
    enum CodingKeys: String, CodingKey {
        case search = "Search"
        case totalResults
        case response = "Response"
    }
}

struct Rating: Codable {
    let source, value: String

    enum CodingKeys: String, CodingKey {
        case source = "Source"
        case value = "Value"
    }
}


