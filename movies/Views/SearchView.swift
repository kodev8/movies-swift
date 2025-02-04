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
                                            MovieDetailsView(movie: movie)
                                        }
                                    }
                                    .id(movie.id)
                                }
                                
                                // Bottom loader and detector
                                Color.clear
                                    .frame(height: 50)
                                    .id("bottomLoader")
                                    .overlay {
                                        if movieService.isLoadingMore {
                                            ProgressView()
                                                .tint(.white)
                                        }
                                    }
                            }
                            .padding()
                        }
                        .overlay(
                            GeometryReader { geometry -> Color in
                                let maxY = geometry.frame(in: .named("scrollView")).maxY
                                let height = geometry.size.height
                                
                                DispatchQueue.main.async {
                                    if maxY < height + 100 { // 100 is threshold
                                        loadMoreIfNeeded()
                                    }
                                }
                                return Color.clear
                            }
                        )
                        .coordinateSpace(name: "scrollView")
                    }
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
    
    private func loadMoreIfNeeded() {
        guard !movieService.isLoadingMore,
              movieService.hasMorePages,
              !searchText.isEmpty else {
            return
        }
        
        Task {
            await movieService.searchMovies(query: searchText, loadMore: true)
        }
    }
}


#Preview {
    RouterView { _ in
        SearchView()
    }
}



