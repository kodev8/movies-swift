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
        do {
            let (data, _) = try await URLSession.shared.data(from: URL(string: url)!)
            let decodedResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
            self.movies = decodedResponse.search
        } catch {
            print("Error fetching movies: \(error)")
        }
    }
}

