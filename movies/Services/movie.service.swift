//
//  movie.service.swift
//  movies
//
//  Created by Guest User on 24/01/2025.
//


import Foundation




class MovieService: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var isLoadingMore = false
    @Published var hasMorePages = true
    
    private let apiKey = "7080ff75"
    private var currentPage = 1
    private var totalResults = 0
    private var currentQuery = ""
    
    @MainActor
    func getMovies(url: String) async {
        do {
            let (data, _) = try await URLSession.shared.data(from: URL(string: url)!)
            let decodedResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
            
            if let searchResults = decodedResponse.search {
                // Update total results count if this is first page
                if currentPage == 1 {
                    if let total = decodedResponse.totalResults {
                        totalResults = Int(total) ?? 0
                    }
                    movies = searchResults
                } else {
                    movies.append(contentsOf: searchResults)
                }
                
                // Calculate if more pages exist
                // OMDB returns 10 results per page and supports up to page 100
                let maxPages = min(100, (totalResults + 9) / 10)
                hasMorePages = currentPage < maxPages && !searchResults.isEmpty
                
                print("Page: \(currentPage), Total Results: \(totalResults), Has More: \(hasMorePages)")
                
            } else {
                hasMorePages = false
                if currentPage == 1 {
                    movies = []
                }
            }
        } catch {
            print("Error fetching movies: \(error)")
            hasMorePages = false
        }
    }
    
    @MainActor
    func searchMovies(query: String, loadMore: Bool = false) async {
        // Don't proceed if already loading
        guard !isLoadingMore else { return }
        
        // If this is a new search, reset everything
        if query != currentQuery {
            reset()
            currentQuery = query
        }
        
        // Handle pagination
        if loadMore {
            guard hasMorePages else { return }
            currentPage += 1
        }
        
        isLoadingMore = true
        
        let urlString = "https://www.omdbapi.com/?s=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&page=\(currentPage)&apikey=\(apiKey)"
        await getMovies(url: urlString)
        
        isLoadingMore = false
    }
    
    func reset() {
        movies = []
        currentPage = 1
        totalResults = 0
        hasMorePages = true
        currentQuery = ""
    }
}

