//
//  MyListView.swift
//  movies
//
//  Created by Terran Winner on 2/3/25.
//
import SwiftUI
import SwiftData
import SwiftfulRouting
struct MyListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.router) var router
   
    @Query private var users: [MovieUser]
    @State private var showingEditSheet = false
    @State private var selectedMovie: DetailedMovie?
    @State private var showingDeleteAlert = false
    @State private var searchText = ""
   
    // Add view mode toggle
    enum ViewMode: String {
        case grid = "square.grid.2x2"
        case list = "list.bullet"
    }
   
    // Add more sorting options
    enum SortOption: String, CaseIterable {
        case dateAdded = "Date Added"
        case title = "Title"
        case rating = "Rating"
        case year = "Year"
    }
   
    enum MovieFilter: String, CaseIterable {
        case all = "All"
        case custom = "My Movies"
        case api = "From IMDB"
    }
   
    @AppStorage("mylist.viewMode") private var viewMode: ViewMode = .grid
    @AppStorage("mylist.selectedRating") private var selectedRatingRaw: Int = -1
    @AppStorage("mylist.sortOption") private var sortOption: SortOption = .dateAdded
    @AppStorage("mylist.sortAscending") private var sortAscending = true
    @State private var selectedFilter: MovieFilter = .all
   
    // Date formatter for relative time
    private let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter
    }()
   
    private var selectedRating: Int? {
        get { selectedRatingRaw == -1 ? nil : selectedRatingRaw }
        set { selectedRatingRaw = newValue ?? -1 }
    }
   
    private var currentUser: MovieUser? {
        guard let userId = UserDefaults.standard.string(forKey: "currentUserId"),
              let uuid = UUID(uuidString: userId) else { return nil }
        return users.first { $0.id == uuid }
    }
   
    private var filteredMovies: [DetailedMovie] {
        let movies = currentUser?.movies ?? []
       
        return movies.filter { movie in
            // Apply search filter
            let matchesSearch = searchText.isEmpty ||
                movie.title.localizedCaseInsensitiveContains(searchText)
           
            // Apply rating filter
            let matchesRating = selectedRating == nil || movie.rating == selectedRating
           
            // Apply source filter
            let matchesSource: Bool
            if let imdbID = movie.imdbID {
                switch selectedFilter {
                case .all:
                    matchesSource = true
                case .custom:
                    matchesSource = !imdbID.hasPrefix("tt")
                case .api:
                    matchesSource = imdbID.hasPrefix("tt")
                }
            } else {
                matchesSource = selectedFilter != .api
            }
           
            return matchesSearch && matchesRating && matchesSource
        }.sorted { first, second in
            let result: Bool
            switch sortOption {
            case .title:
                result = first.title < second.title
            case .rating:
                result = first.rating > second.rating
            case .dateAdded:
                result = (first.dateAdded ?? .distantPast) > (second.dateAdded ?? .distantPast)
            case .year:
                let year1 = Int(first.year) ?? 0
                let year2 = Int(second.year) ?? 0
                result = year1 > year2
            }
            return sortAscending ? result : !result
        }
    }
   
    // Add menu state
    @State private var showRatingMenu = false
    @State private var showSourceMenu = false
   
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
           
            VStack(spacing: 0) {
                
                VStack(spacing: 16) {
                    HeaderSection
                    
                    SearchBarSection
                   
                    FilterSection
                }
                .padding(.vertical)
               
                // Content with grid/list toggle
                if filteredMovies.isEmpty {
                    VStack(spacing: 16) {
                        if currentUser?.movies.isEmpty ?? true {
                            // No movies at all
                            Image(systemName: "film")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                           
                            Text("No movies in your list")
                                .font(.headline)
                                .foregroundColor(.gray)
                           
                            Button(action: {
                                router.showScreen(.push) { _ in
                                    AddMovieView()
                                }
                            }) {
                                Text("Add a movie")
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color.red)
                                    .cornerRadius(5)
                            }
                        } else {
                            // No movies match filters
                            Text("No movies match your filters")
                                .font(.headline)
                                .foregroundColor(.gray)
                           
                            Button(action: {
                                // Reset filters
                                clearFilters()
                            }) {
                                Text("Clear filters")
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color.red)
                                    .cornerRadius(5)
                            }
                        }
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    ZStack(alignment: .bottomTrailing) {
                        ScrollView {
                            if viewMode == .grid {
                                LazyVGrid(columns: [
                                    GridItem(.flexible(), spacing: 16),
                                    GridItem(.flexible(), spacing: 16)
                                ], spacing: 16) {
                                    ForEach(filteredMovies) { movie in
                                        MovieCard(movie: movie) {
                                            selectedMovie = movie
                                            if let imdbID = movie.imdbID {
                                                if imdbID.hasPrefix("tt") {
                                                    router.showScreen(.sheet) { _ in
                                                        MovieDetailsView(movie: movie.asMovie)
                                                    }
                                                } else {
                                                    showingEditSheet = true
                                                }
                                            }
                                        }
                                        .transition(.scale.combined(with: .opacity))
                                    }
                                }
                                .padding()
                            } else {
                                LazyVStack(spacing: 16) {
                                    ForEach(filteredMovies) { movie in
                                        MovieListItem(movie: movie) {
                                            selectedMovie = movie
                                            if let imdbID = movie.imdbID {
                                                if imdbID.hasPrefix("tt") {
                                                    router.showScreen(.sheet) { _ in
                                                        MovieDetailsView(movie: movie.asMovie)
                                                    }
                                                } else {
                                                    showingEditSheet = true
                                                }
                                            }
                                        }
                                        .transition(.scale.combined(with: .opacity))
                                    }
                                }
                                .padding()
                            }
                        }
                        .animation(.spring(response: 0.3), value: filteredMovies)
                        
                        
                        Button(action: {
                            router.showScreen(.push) { _ in
                                AddMovieView()
                            }
                        }) {
                            Circle()
                                .fill(.white)
                                .overlay(
                                    Image(systemName: "plus")
                                )
                                .frame(width: 36, height: 36)
                                .padding(.trailing)
                                .padding(.bottom)
                            
                        }.foregroundStyle(.nDarkGray)
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showingEditSheet) {
            if let movie = selectedMovie {
                EditMovieView(movie: movie)
            }
        }
        .alert("Remove from My List", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive) {
                if let movie = selectedMovie {
                    modelContext.delete(movie)
                }
            }
        } message: {
            Text("Do you want to remove this movie from your list?")
        }
    }
    
    
    private var HeaderSection: some View {
        ZStack {
            // Title in the center
            Text("My List")
                .font(.system(size: 24, weight: .bold, design: .default))
                .foregroundColor(.white)
            
            // HStack to align the button on the left
            HStack {
                Button(action: {
                    router.dismissScreen()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.title2)
                }
                Spacer()
            }
            .padding(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 10)
    }






   
    private var SearchBarSection : some View {
        HStack {
            
            
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search movies", text: $searchText)
                    .textFieldStyle(DarkTextFieldStyle())
            }
           
            // View mode toggle
            Button(action: {
                withAnimation(.spring(response: 0.3)) {
                    viewMode = viewMode == .grid ? .list : .grid
                }
            }) {
                Image(systemName: viewMode.rawValue)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal)
    }
   
    private var FilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Source Filter with dropdown
                Menu {
                    ForEach(MovieFilter.allCases, id: \.self) { filter in
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                selectedFilter = filter
                            }
                        } label: {
                            HStack {
                                Text(filter.rawValue)
                                if selectedFilter == filter {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    FilterPill(
                        title: selectedFilter.rawValue,
                        isDropdown: true,
                        isSelected: selectedFilter != .all
                    )
                }
               
                // Rating Filter with dropdown
                Menu {
                    ForEach(0...5, id: \.self) { rating in
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                selectedRatingRaw = rating == 0 ? -1 : rating
                            }
                        } label: {
                            HStack {
                                Text(rating == 0 ? "Any Rating" : "\(rating) ★")
                                if rating == selectedRating ?? 0 {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    FilterPill(
                        title: selectedRating == nil ? "Rating" : "\(selectedRating!) ★",
                        isDropdown: true,
                        isSelected: selectedRating != nil
                    )
                }
               
                // Sort option with dropdown
                Menu {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Button {
                            withAnimation {
                                if sortOption == option {
                                    sortAscending.toggle()
                                } else {
                                    sortOption = option
                                    sortAscending = true
                                }
                            }
                        } label: {
                            HStack {
                                Text(option.rawValue)
                                if sortOption == option {
                                    Image(systemName: sortAscending ? "chevron.up" : "chevron.down")
                                }
                            }
                        }
                    }
                } label: {
                    FilterPill(
                        title: "\(sortOption.rawValue) \(sortAscending ? "↑" : "↓")",
                        isDropdown: true,
                        isSelected: true
                    )
                }
               
                if hasActiveFilters {
                    Button(action: clearFilters) {
                        FilterPill(
                            title: "Clear All",
                            isSelected: false
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
   
    private var hasActiveFilters: Bool {
        selectedFilter != .all || selectedRating != nil
    }
   
    private func clearFilters() {
        withAnimation(.spring(response: 0.3)) {
            selectedFilter = .all
            selectedRatingRaw = -1
            searchText = ""
        }
    }
}
extension View {
    func formatRelativeDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
struct MovieCard: View {
    let movie: DetailedMovie
    let onTap: () -> Void
   
    private var dateAddedText: String {
        formatRelativeDate(movie.dateAdded)
    }
   
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Movie poster
                Group {
                    if let galleryImage = movie.galleryImage {
                        galleryImage
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width / 2 - 32 , height: 200)
                            .clipped()
                    } else if !movie.poster.isEmpty {
                        AsyncImage(url: URL(string: movie.poster)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: UIScreen.main.bounds.width / 2 - 32, height: 200)
                                .clipped()
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundColor(.gray)
                                )
                        }
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            )
                    }
                }
                .frame(height: 200)
                .clipped()
               
                VStack(alignment: .leading, spacing: 4) {
                    Text(movie.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(1)
                   
                    Text(movie.year)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                   
                    if !dateAddedText.isEmpty {
                        Text(dateAddedText)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                   
                    if movie.rating > 0 {
                        RatingPicker(rating: .constant(movie.rating))
                            .scaleEffect(0.8)
                            .frame(height: 20)
                    }
                   
                    // Source indicator
                    HStack {
                        if let imdbid = movie.imdbID {
                            Image(systemName: imdbid.hasPrefix("tt") ? "network" : "pencil")
                                .foregroundColor(.gray)
                            Text(imdbid.hasPrefix("tt") ? "From IMDB" : "Custom")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
    }
}
// Add MovieListItem view for list mode
struct MovieListItem: View {
    let movie: DetailedMovie
    let onTap: () -> Void
   
    private var dateAddedText: String {
        formatRelativeDate(movie.dateAdded)
    }
   
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Poster
                if let galleryImage = movie.galleryImage {
                    galleryImage
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 150)
                        .clipped()
                } else {
                    AsyncImage(url: URL(string: movie.poster)) { image in
                        image
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 150)
                            .clipped()
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            )
                    }
                    .frame(width: 100, height: 150)
                    .clipped()
                }
               
                VStack(alignment: .leading, spacing: 8) {
                    Text(movie.title)
                        .font(.headline)
                        .foregroundColor(.white)
                   
                    HStack {
                        Text(movie.year)
                        if !dateAddedText.isEmpty {
                            Text("•")
                            Text(dateAddedText)
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                   
                    if movie.rating > 0 {
                        RatingPicker(rating: .constant(movie.rating))
                            .scaleEffect(0.8)
                            .frame(height: 20)
                    }
                   
                    if let genre = movie.genre {
                        Text(genre)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
               
                Spacer()
               
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
    }
}


#Preview("Movie List Item Variations") {
    // Custom Movie: Manually added with gallery image
    let customMovie = DetailedMovie(from: MovieDetail(
        title: "Custom Movie with Gallery Image",
        year: "2024",
        rated: "PG-13",
        released: "2024-02-04",
        runtime: "90 min",
        genre: "Drama",
        director: "John Doe",
        writer: "Jane Smith",
        actors: "Actor 1, Actor 2",
        plot: "An inspiring story about personal growth",
        language: "English",
        country: "USA",
        awards: "Best Independent Film",
        poster: "",
        ratings: [
            Rating(source: "IMDB", value: "7.5/10"),
            Rating(source: "Rotten Tomatoes", value: "85%")
        ],
        metascore: "75",
        imdbRating: "7.5",
        imdbVotes: "5,000",
        imdbID: "custom123",
        type: "movie",
        dvd: "2024-03-01",
        boxOffice: "$5,000,000",
        production: "Independent Films Inc.",
        website: "www.custommovie.com",
        response: "True"
    ))
    customMovie.rating = 4
    customMovie.galleryImage = Image(systemName: "star")
    customMovie.dateAdded = Date().addingTimeInterval(-86400)
    
    // IMDB Movie: Imported from IMDB with network poster
    let imdbMovie = DetailedMovie(from: MovieDetail(
        title: "IMDB Synced Movie",
        year: "2023",
        rated: "R",
        released: "2023-06-15",
        runtime: "120 min",
        genre: "Action",
        director: "Michael Bay",
        writer: "Action Screenplay Writer",
        actors: "Big Action Star, Supporting Actor",
        plot: "High-octane action thriller",
        language: "English",
        country: "USA",
        awards: "Best Action Sequence",
        poster: "https://example.com/poster.jpg",
        ratings: [
            Rating(source: "IMDB", value: "6.5/10"),
            Rating(source: "Metacritic", value: "65/100")
        ],
        metascore: "65",
        imdbRating: "6.5",
        imdbVotes: "50,000",
        imdbID: "tt1234567",
        type: "movie",
        dvd: "2023-09-01",
        boxOffice: "$200,000,000",
        production: "Major Studio Productions",
        website: "www.actionmovie.com",
        response: "True"
    ))
    imdbMovie.rating = 5
    imdbMovie.dateAdded = Date().addingTimeInterval(-7 * 86400)
    imdbMovie.poster = "https://picsum.photos/200/300"
    
    // No Image Movie: Movie without any poster
    let noImageMovie = DetailedMovie(from: MovieDetail(
        title: "Movie Without Image",
        year: "2022",
        rated: "PG",
        released: "2022-12-25",
        runtime: "105 min",
        genre: "Comedy",
        director: "Comedy Director",
        writer: "Funny Screenwriter",
        actors: "Comedian 1, Comedian 2",
        plot: "A hilarious comedy about everyday life",
        language: "English",
        country: "USA",
        awards: "Audience Choice Award",
        poster: "",
        ratings: [
            Rating(source: "IMDB", value: "7.0/10")
        ],
        metascore: "70",
        imdbRating: "7.0",
        imdbVotes: "10,000",
        imdbID: "custom456",
        type: "movie",
        dvd: "2023-03-01",
        boxOffice: "$50,000,000",
        production: "Comedy Studios",
        website: "www.comedymovie.com",
        response: "True"
    ))
    noImageMovie.rating = 3
    
    return ZStack {
        Color.black.edgesIgnoringSafeArea(.all)
        
        ScrollView {
            VStack(spacing: 16) {
                Text("List Item Variations")
                    .font(.title)
                    .foregroundColor(.white)
                
                MovieListItem(movie: customMovie) {}
                MovieListItem(movie: imdbMovie) {}
                MovieListItem(movie: noImageMovie) {}
            }
            .padding()
        }
    }
}


#Preview("Movie Card Variations") {
    // Custom Movie: Manually added with gallery image
    let customMovie = DetailedMovie(from: MovieDetail(
        title: "Custom Movie with Gallery Image",
        year: "2024",
        rated: "PG-13",
        released: "2024-02-04",
        runtime: "90 min",
        genre: "Drama",
        director: "John Doe",
        writer: "Jane Smith",
        actors: "Actor 1, Actor 2",
        plot: "An inspiring story about personal growth",
        language: "English",
        country: "USA",
        awards: "Best Independent Film",
        poster: "",
        ratings: [
            Rating(source: "IMDB", value: "7.5/10"),
            Rating(source: "Rotten Tomatoes", value: "85%")
        ],
        metascore: "75",
        imdbRating: "7.5",
        imdbVotes: "5,000",
        imdbID: "custom123",
        type: "movie",
        dvd: "2024-03-01",
        boxOffice: "$5,000,000",
        production: "Independent Films Inc.",
        website: "www.custommovie.com",
        response: "True"
    ))
    customMovie.rating = 4
    customMovie.galleryImage = Image(systemName: "star")
    customMovie.dateAdded = Date().addingTimeInterval(-86400)
    
    // IMDB Movie: Imported from IMDB with network poster
    let imdbMovie = DetailedMovie(from: MovieDetail(
        title: "IMDB Synced Movie",
        year: "2023",
        rated: "R",
        released: "2023-06-15",
        runtime: "120 min",
        genre: "Action",
        director: "Michael Bay",
        writer: "Action Screenplay Writer",
        actors: "Big Action Star, Supporting Actor",
        plot: "High-octane action thriller",
        language: "English",
        country: "USA",
        awards: "Best Action Sequence",
        poster: "https://example.com/poster.jpg",
        ratings: [
            Rating(source: "IMDB", value: "6.5/10"),
            Rating(source: "Metacritic", value: "65/100")
        ],
        metascore: "65",
        imdbRating: "6.5",
        imdbVotes: "50,000",
        imdbID: "tt1234567",
        type: "movie",
        dvd: "2023-09-01",
        boxOffice: "$200,000,000",
        production: "Major Studio Productions",
        website: "www.actionmovie.com",
        response: "True"
    ))
    imdbMovie.rating = 5
    imdbMovie.dateAdded = Date().addingTimeInterval(-7 * 86400)
    imdbMovie.poster = "https://picsum.photos/200/300"
    
    // No Image Movie: Movie without any poster
    let noImageMovie = DetailedMovie(from: MovieDetail(
        title: "Movie Without Image",
        year: "2022",
        rated: "PG",
        released: "2022-12-25",
        runtime: "105 min",
        genre: "Comedy",
        director: "Comedy Director",
        writer: "Funny Screenwriter",
        actors: "Comedian 1, Comedian 2",
        plot: "A hilarious comedy about everyday life",
        language: "English",
        country: "USA",
        awards: "Audience Choice Award",
        poster: "",
        ratings: [
            Rating(source: "IMDB", value: "7.0/10")
        ],
        metascore: "70",
        imdbRating: "7.0",
        imdbVotes: "10,000",
        imdbID: "custom456",
        type: "movie",
        dvd: "2023-03-01",
        boxOffice: "$50,000,000",
        production: "Comedy Studios",
        website: "www.comedymovie.com",
        response: "True"
    ))
    noImageMovie.rating = 3
    
    return ZStack {
        Color.black.edgesIgnoringSafeArea(.all)
        
        ScrollView {
            VStack(spacing: 16) {
                Text("Card Variations")
                    .font(.title)
                    .foregroundColor(.white)
                
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    MovieCard(movie: customMovie) {}
                    MovieCard(movie: imdbMovie) {}
                    MovieCard(movie: noImageMovie) {}
                }
            }
            .padding()
        }
    }
}



















