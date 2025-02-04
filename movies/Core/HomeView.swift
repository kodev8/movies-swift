//
//  HomeView.swift
//  movies
//
//  Created by Guest User on 15/01/2025.
//
import SwiftUI
import SwiftfulUI
import SwiftfulRouting
struct movieRow: Identifiable {
    let id = UUID()
    var movies: [Movie]
}
struct HomeView: View {
   
    @Environment(\.router) var router
    @StateObject private var tmdbService = TMDBService()
   
    @State private var filters = [
        Filter(title: "Popular", isDropdown: false),
        Filter(title: "Top 20", isDropdown: false),
        Filter(title: "Upcoming", isDropdown: false),
        ]
    @State private var selectedFilter: Filter? = nil;
    @State private var fullHeaderSize: CGSize = .zero;
    @State private var scrollViewOffset: CGFloat = 0;
    @State private var heroMovie: Movie? = nil;
   
    //    @State provate var currentUser: User? = nil;
   
    private var movieRows: [movieRow] {
        [
            movieRow(movies: tmdbMoviesToMovies(tmdbService.popularMovies)),
            movieRow(movies: tmdbMoviesToMovies(tmdbService.topRatedMovies)),
            movieRow(movies: tmdbMoviesToMovies(tmdbService.upcomingMovies))
        ]
    }
    var body: some View {
        ZStack(alignment: .top) {
            Color.nBlack.ignoresSafeArea()
            backgroundGradient
            Rectangle()
                .opacity(0)
                .frame(height: fullHeaderSize.height)
            
            MovieContentView(
                heroMovie: heroMovie,
                movieRows: movieRows,
                selectedFilter: selectedFilter,
                scrollViewOffset: scrollViewOffset,
                fullHeaderSize: fullHeaderSize,
                onMoviePressed: onMoviePressed,
                onScrollChanged: { offset in
                    scrollViewOffset = offset.y
                }
            )
            
            
            fullHeaderWithMenu
        }
        .foregroundStyle(.white)
        .task {
            await getData()
        }
        .toolbar(.hidden, for: .navigationBar)
    }
   
   
//    callback
   
    private func getData() async {
        do {
            // Fetch all movie categories
            async let popular: () = tmdbService.fetchPopularMovies()
            async let topRated: () = tmdbService.fetchTopRatedMovies()
            async let upcoming: () = tmdbService.fetchUpcomingMovies()
           
            try await (popular, topRated, upcoming)
           
            // Set hero movie from popular movies
            if !tmdbService.popularMovies.isEmpty {
                heroMovie = Movie(from: tmdbService.popularMovies.randomElement()!)
            }
        } catch {
            print("Error fetching movies: \(error)")
        }
    }
    private func tmdbMoviesToMovies(_ tmdbMovies: [TMDBMovie]) -> [Movie] {
        tmdbMovies.map { tmdbMovie in
            Movie(from: tmdbMovie)
        }
    }
    private func onMoviePressed(movie: Movie) {
        router.showScreen(.sheet) { _ in
            MovieDetailsView(movie: movie, movieService: tmdbService)
        }
    }
   
   
//    Sections
   
    private var backgroundGradient: some View {
        ZStack {
            LinearGradient(
                colors: [.nDarkGray.opacity(1), .nDarkGray.opacity(0)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
           
            LinearGradient(
                colors: [.nDarkRed.opacity(0.5), .nDarkRed.opacity(0)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
        .frame(maxHeight: max(10, (400 + (scrollViewOffset * 0.75))))
        .opacity(scrollViewOffset < -250 ? 0: 1)
       
    }


   
    private var fullHeaderWithMenu: some View {
        VStack(spacing: 0) {
            header.padding(.horizontal, 16)
           
            PillContainer(
                filters: filters,
                selectedFilter: selectedFilter,
                onXClicked: {
                    withAnimation {
                        selectedFilter = nil
                    }
                },
                onFilterClicked: { newFilter in
                    withAnimation {
                        if selectedFilter?.title == newFilter.title {
                            selectedFilter = nil
                        } else {
                            selectedFilter = newFilter
                        }
                    }
                }
            )
            .padding(.top, 16)
        }
        .padding(.bottom, 8)
        .background(
            ZStack {
                if scrollViewOffset < -30 {
                    Rectangle()
                        .fill(Color.clear)
                        .background(.ultraThinMaterial)
                        .brightness(-0.2)
                        .ignoresSafeArea()
                }
            }
        )
        .animation(.smooth, value: scrollViewOffset)
        .readingFrame { frame in
            if fullHeaderSize == .zero {
                fullHeaderSize = frame.size
            }
        }
    }
   
    private var header: some View {
        HStack(spacing: 0) {
            Text("For you")
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                ).bold()
                .onTapGesture {
                    router.dismissScreen()
                }
           
            HStack(spacing: 16) {
                Image(systemName: "arrow.down.to.line").onTapGesture {
                    router.showScreen(.push){ _ in
                        MyListView()
                    }
                }
               
                Image(systemName: "magnifyingglass").onTapGesture {
                    router.showScreen(.push){ _ in
                        SearchView()
                    }
                }
               
                Image(systemName: "person.circle").onTapGesture {
                    router.showScreen(.push){ _ in
                        ProfileView()
                    }
                }
            }
        }.font(.title)
       
       
    }
           
}

#Preview {
   
    RouterView { _ in
        HomeView()
    }
   
}
