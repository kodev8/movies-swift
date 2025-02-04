import SwiftUI
import SwiftfulRouting


struct SearchView: View {
    @Environment(\.router) var router
    @StateObject private var movieService = MovieService()
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var searchTask: Task<Void, Never>?
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                // Search header
                HStack(spacing: 16) {
                   BackButton()
                    
                    // Search field
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("", text: $searchText)
                            .placeholder(when: searchText.isEmpty) {
                                Text("Search shows, movies...")
                                    .foregroundColor(.gray)
                                    .padding(.leading, 8)
                            }
                            .textFieldStyle(DarkTextFieldStyle())
                    }
                }
                .padding()
                
                // Results
                if !movieService.movies.isEmpty {
                    MoviesSection
                } else if isSearching {
                    ProgressView()
                        .tint(.white)
                } else if !searchText.isEmpty && searchText.count >= 3 {
                    Text("No results found")
                        .foregroundColor(.gray)
                        .padding(.top, 32)
                }
                
                Spacer()
            }
        }
        .onChange(of: searchText) { oldValue, newValue in
            searchTask?.cancel()
            
            if newValue.isEmpty {
                movieService.reset()
            } else if newValue.count >= 3 {
                searchTask = Task {
                    try? await Task.sleep(for: .milliseconds(500))
                    
                    if !Task.isCancelled {
                        isSearching = true
                        await movieService.searchMovies(query: newValue)
                        isSearching = false
                    }
                }
            }
        }.toolbar(.hidden, for: .navigationBar)
    }
    
    
    private var MoviesSection: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3),
                    spacing: 16
                ) {
                    ForEach(movieService.movies) { movie in
                        MovieRowItem(
                            movie: movie,
                            imageName: movie.poster,
                            title: movie.title
                        )
                        .onTapGesture {
                            router.showScreen(.sheet) { _ in
                                MovieDetailsView(movie: movie, movieService: movieService)
                                
                            }
                        }
                        .onAppear {
                            if movie == movieService.movies.last {
                                
                                Task {
                                    await movieService.searchMovies(query: searchText, loadMore: true)
                                }
                            }
                        }
                        .id(movie.id)
                    }
                    
//                    // Bottom loader and detector
//                    Color.clear
//                        .frame(height: 50)
//                        .id("bottomLoader")
//                        .overlay {
                            if movieService.isLoadingMore {
                                ProgressView()
                                    .tint(.white)
//                            }
                        }
                }
                .padding()
            }
        }
    }
}


#Preview {
    RouterView { _ in
        SearchView()
    }
}



