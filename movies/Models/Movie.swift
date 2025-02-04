//
//  Movie.swift
//  movies
//
//  Created by Guest User on 24/01/2025.
//

import Foundation

struct MovieResponse: Codable {
    let search: [Movie]?
    let totalResults: String?
    let response: String
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case search = "Search"
        case totalResults = "totalResults"
        case response = "Response"
        case error = "Error"
    }
}

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
    
    init(from detailedMovie: DetailedMovie) {
        title = detailedMovie.title
        year = detailedMovie.year
        imdbID = detailedMovie.imdbID!
        type = "movie"
        poster = detailedMovie.poster
    }
    
    init(from tmdbMovie: TMDBMovie) {
        title = tmdbMovie.title
        year = String(tmdbMovie.releaseDate.prefix(4))
        imdbID = String(tmdbMovie.id)
        type = "movie"
        poster = "https://image.tmdb.org/t/p/w500\(tmdbMovie.posterPath)"
    }
}

extension Movie: Equatable {
    static func == (lhs: Movie, rhs: Movie) -> Bool {
        return lhs.id == rhs.id
    }
}
   
struct Rating: Codable {
    let source, value: String

    enum CodingKeys: String, CodingKey {
        case source = "Source"
        case value = "Value"
    }
}

// TMDB MOVIE FOR POPULAR, UPCOMING, TOPRATED

struct TMDBMovie: Codable {
    let adult: Bool
//    let backdropPath: String
//    let genreIDS: [Int]
    let id: Int
    let originalLanguage, originalTitle, overview: String
    let popularity: Double
    let posterPath, releaseDate, title: String
//    let video: Bool
    let voteAverage: Double
    let voteCount: Int


    enum CodingKeys: String, CodingKey {
        case adult
//        case backdropPath = "backdrop_path"
//        case genreIDS = "genre_ids"
        case id
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case overview, popularity
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case title
//             video
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}


