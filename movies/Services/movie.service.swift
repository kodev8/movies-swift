//
//  movie.service.swift
//  movies
//
//  Created by Guest User on 24/01/2025.
//

import Foundation


class MovieService: ObservableObject {
    @Published var movies: [Movie] = []
    
    @MainActor
    func getMovies(url: String) async {
        // Use the working API key from your response
        
        do {
            let (data, _) = try await URLSession.shared.data(from: URL(string: url)!)
            let decodedResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
            
            if let searchResults = decodedResponse.search {
                self.movies = searchResults
            } else if let error = decodedResponse.error {
                print("API Error: \(error)")
            }
        } catch {
            print("Error fetching movies: \(error)")
        }
    }
}

