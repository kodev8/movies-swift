//
//  movie.service.swift
//  movies
//
//  Created by Guest User on 24/01/2025.
//


import Foundation


protocol MovieServiceProtocol {
    func fetchMovieDetails(id: String) async throws -> MovieDetail
}


class MovieService: ObservableObject, MovieServiceProtocol {
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
                
//                print("Page: \(currentPage), Total Results: \(totalResults), Has More: \(hasMorePages)")
                
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
    
    func fetchMovieDetails(id: String) async throws -> MovieDetail {
           let urlString = "https://www.omdbapi.com/?i=\(id)&apikey=\(apiKey)"
           guard let url = URL(string: urlString) else {
               throw URLError(.badURL)
           }
          
           let (data, _) = try await URLSession.shared.data(from: url)
           return try JSONDecoder().decode(MovieDetail.self, from: data)
       }


}

struct TMDBResponse: Codable {
    let page: Int
    let results: [TMDBMovie]
    let totalPages: Int
    let totalResults: Int
   
    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}


// these api keys are for demo only and will not be in usable once the repo is made public
class TMDBService: ObservableObject, MovieServiceProtocol {
    private let apiKey = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI4ZDEyNjkyM2EzNmE2YTk5NDNiZDc0ZmNmOTg1MWRiOCIsIm5iZiI6MTczODY0MzMxNC43MDQsInN1YiI6IjY3YTE5NzcyODBlNTkzZDVmZGUyYzVmMyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.FvB_e86tOCMLFe71dB24369Uuer5-PbfpUfN7JUxbUU"
    private let baseURL = "https://api.themoviedb.org/3"
   
    @Published var popularMovies: [TMDBMovie] = []
    @Published var topRatedMovies: [TMDBMovie] = []
    @Published var upcomingMovies: [TMDBMovie] = []
   
    @Published var isLoadingMore = false
    @Published var hasMorePages = true
    private var currentPopularPage = 1
    private let maxPages = 10
   
  
    private func createRequest(path: String, queryItems: [URLQueryItem]) -> URLRequest {
        var components = URLComponents(string: baseURL + path)!
        components.queryItems = queryItems
       
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = [
            "accept": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]
       
        return request
    }
   
    @MainActor
    func fetchPopularMovies(loadMore: Bool = false) async throws {
        guard !isLoadingMore else { return }
        
    
//        print("Fetching page: \(currentPopularPage), loadMore: \(loadMore), hasMorePages: \(hasMorePages)")
//        
        // Handle pagination
        if loadMore {
            guard hasMorePages else {
                print("No more pages available")
                return
            }
            
            guard currentPopularPage < maxPages else {
                print("Reached max pages limit")
                hasMorePages = false
                return
            }
            
            currentPopularPage += 1
        } else {
            // Only reset when explicitly requesting a fresh load
            currentPopularPage = 1
            popularMovies = []
            hasMorePages = true
        }
        
        isLoadingMore = true
        
        let queryItems = [
            URLQueryItem(name: "include_adult", value: "false"),
            URLQueryItem(name: "include_video", value: "false"),
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: String(currentPopularPage)),
            URLQueryItem(name: "sort_by", value: "popularity.desc")
        ]
        
        do {
            let request = createRequest(path: "/discover/movie", queryItems: queryItems)
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(TMDBResponse.self, from: data)
            
            
            
            if loadMore {
                popularMovies.append(contentsOf: response.results)
            } else {
                popularMovies = response.results
            }
            
        
            hasMorePages = currentPopularPage < min(maxPages, response.totalPages)
            
            print("Updated hasMorePages: \(hasMorePages)")
        } catch {
            print("Error fetching movies: \(error)")
        }
        isLoadingMore = false
    }



   
    @MainActor
    func fetchTopRatedMovies() async throws {
        let queryItems = [
            URLQueryItem(name: "include_adult", value: "false"),
            URLQueryItem(name: "include_video", value: "false"),
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "sort_by", value: "vote_average.desc"),
            URLQueryItem(name: "without_genres", value: "99,10755"),
            URLQueryItem(name: "vote_count.gte", value: "200")
        ]
       
        let request = createRequest(path: "/discover/movie", queryItems: queryItems)
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(TMDBResponse.self, from: data)
        topRatedMovies = response.results
    }
   
    @MainActor
    func fetchUpcomingMovies() async throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let minDate = dateFormatter.string(from: Date())
        let maxDate = dateFormatter.string(from: Calendar.current.date(byAdding: .month, value: 3, to: Date())!)
       
        let queryItems = [
            URLQueryItem(name: "include_adult", value: "false"),
            URLQueryItem(name: "include_video", value: "false"),
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "sort_by", value: "popularity.desc"),
            URLQueryItem(name: "with_release_type", value: "2|3"),
            URLQueryItem(name: "release_date.gte", value: minDate),
            URLQueryItem(name: "release_date.lte", value: maxDate)
        ]
       
        let request = createRequest(path: "/discover/movie", queryItems: queryItems)
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(TMDBResponse.self, from: data)
        upcomingMovies = response.results
    }
   
    @MainActor
    func fetchMovieDetailsBase(id: String) async throws -> TMDBMovieDetail {
        let queryItems = [
            URLQueryItem(name: "language", value: "en-US")
        ]
       
        let request = createRequest(path: "/movie/\(id)", queryItems: queryItems)
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(TMDBMovieDetail.self, from: data)
    }
   
    @MainActor
    func fetchMovieCredits(id: String) async throws -> TMDBMovieCredits {
        let request = createRequest(path: "/movie/\(id)/credits", queryItems: [])
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(TMDBMovieCredits.self, from: data)
    }
   
    private func processCredits(_ credits: TMDBMovieCredits) -> (directors: String, actors: String, writers: String) {
        let directors = credits.crew
            .filter { $0.knownForDepartment == .directing }
            .prefix(3)
            .map { $0.name }
            .joined(separator: ", ")
       
        let actors = credits.cast
            .filter { $0.knownForDepartment == .acting }
            .prefix(3)
            .map { $0.name }
            .joined(separator: ", ")
       
        let writers = credits.crew
            .filter { $0.knownForDepartment == .writing }
            .prefix(3)
            .map { $0.name }
            .joined(separator: ", ")
       
        return (directors, actors, writers)
    }
   
    @MainActor
    func fetchMovieDetails(id: String) async throws -> MovieDetail {
        async let detailTask = fetchMovieDetailsBase(id: id)
        async let creditsTask = fetchMovieCredits(id: id)
       
        let (detail, credits) = try await (detailTask, creditsTask)
        let (directors, actors, writers) = processCredits(credits)
       
        let runtime = "\(detail.runtime) min"
        let genres = detail.genres.map { $0.name }.joined(separator: ", ")
        
        
       
        return MovieDetail(
            title: detail.title,
            year: String(detail.releaseDate.prefix(4)),
            rated: detail.adult ? "R" : "PG-13",
            released: detail.releaseDate,
            runtime: runtime,
            genre: genres,
            director: directors,
            writer: writers,
            actors: actors,
            plot: detail.overview,
            language: detail.spokenLanguages.first?.englishName ?? "",
            country: detail.productionCountries.first?.name ?? "",
            awards: "",
            poster: "https://image.tmdb.org/t/p/w500\(detail.posterPath)",
            ratings: [Rating(source: "Public", value: String(format: "%.1f", detail.voteAverage))],
            metascore: "",
            imdbRating: String(format: "%.1f", detail.voteAverage),
            imdbVotes: String(detail.voteCount),
            imdbID: detail.imdbID,
            type: "movie",
            dvd: "",
            boxOffice: "",
            production: "",
            website: detail.homepage,
            response: "True"
        )
    }
}

