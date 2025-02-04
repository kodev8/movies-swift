//
//  MovieDetailsView.swift
//  movies
//
//  Created by Terran Winner on 2/2/25.
//


import SwiftUI
import SwiftData
import SwiftfulRouting


struct MovieDetailsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.router) var router
    @Query private var users: [MovieUser]
   
    var movie: Movie? = nil
   
    @State private var progress: Double = 0.8
    @State private var isMyList: Bool = false
    @State private var detailedMovie: MovieDetail?
    @State private var isLoading = true
   
    private let movieService = MovieService()
   
    private var currentUser: MovieUser? {
        guard let userId = UserDefaults.standard.string(forKey: "currentUserId"),
              let uuid = UUID(uuidString: userId) else { return nil }
        return users.first { $0.id == uuid }
    }
   
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
           
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Hero Image
                        
                        HStack {
                            Spacer()
                            AsyncImage(url: URL(string: detailedMovie?.poster ?? "")) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 400)
                                    .clipped()
                            } placeholder: {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 400)
                            }
                            Spacer()
                        }
                       
                       
                        VStack(alignment: .leading, spacing: 20) {
                            // Title and Year
                            VStack(alignment: .leading, spacing: 8) {
                                Text(detailedMovie?.title ?? "")
                                    .font(.title)
                                    .fontWeight(.bold)
                               
                                HStack {
                                    Text(detailedMovie?.year ?? "")
                                    Text("•")
                                    Text(detailedMovie?.runtime ?? "")
                                    if let rating = detailedMovie?.rated {
                                        Text("•")
                                        Text(rating)
                                    }
                                }
                                .foregroundColor(.gray)
                            }
                           
                            // Action Buttons
                            HStack(spacing: 32) {
                                MyListButton(isMyList: isMyList) {
                                    toggleMyList()
                                }
                               
                                ShareButton()
                               
                                RateButton()
                            }
                           
                            // Plot
                            if let plot = detailedMovie?.plot {
                                Text(plot)
                                    .lineSpacing(4)
                            }
                           
                            // Details
                            VStack(alignment: .leading, spacing: 12) {
                                if let genre = detailedMovie?.genre {
                                    DetailRow(title: "Genre", content: genre)
                                }
                                if let director = detailedMovie?.director {
                                    DetailRow(title: "Director", content: director)
                                }
                                if let writer = detailedMovie?.writer {
                                    DetailRow(title: "Writer", content: writer)
                                }
                                if let actors = detailedMovie?.actors {
                                    DetailRow(title: "Cast", content: actors)
                                }
                                if let awards = detailedMovie?.awards, !awards.isEmpty {
                                    DetailRow(title: "Awards", content: awards)
                                }
                            }
                           
                            // Ratings
                            if let ratings = detailedMovie?.ratings, !ratings.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Ratings")
                                        .font(.headline)
                                   
                                    ForEach(ratings, id: \.source) { rating in
                                        HStack {
                                            Text(rating.source)
                                            Spacer()
                                            Text(rating.value)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .task {
            await fetchMovieDetails()
            checkMyList()
        }
        .foregroundStyle(Color.white.opacity(0.8))
        .toolbar(.hidden, for: .navigationBar)
        
    }
   
    private func fetchMovieDetails() async {
        guard let movie = movie else { return }
        isLoading = true
        do {
            detailedMovie = try await movieService.fetchMovieDetails(imdbID: movie.imdbID)
        } catch {
            print("Error fetching movie details: \(error)")
        }
        isLoading = false
    }
   
    private func checkMyList() {
        guard let movie = movie,
              let currentUser = currentUser else { return }
       
        isMyList = currentUser.movies.contains { $0.imdbID == movie.imdbID }
    }
   
    private func toggleMyList() {
        guard let movie = movie,
              let detailedMovie = detailedMovie,
              let currentUser = currentUser else { return }
       
        if isMyList {
            // Remove from list
            if let movieToRemove = currentUser.movies.first(where: { $0.imdbID == movie.imdbID }) {
                modelContext.delete(movieToRemove)
            }
        } else {
            // Add to list
            let newMovie = DetailedMovie(from: detailedMovie)
            currentUser.movies.append(newMovie)
        }
       
        try? modelContext.save()
        isMyList.toggle()
    }
}


struct DetailRow: View {
    let title: String
    let content: String
   
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            Text(content)
        }
    }
}


#Preview {
    MovieDetailsView()
}




