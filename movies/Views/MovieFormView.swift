import SwiftUI
import PhotosUI
import SwiftData
import Combine
import SwiftfulRouting


struct MovieFormView: View {
    // Environment
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.router) var router
   
    // Mode and data
    enum Mode {
        case add
        case edit(DetailedMovie)
    }
    let mode: Mode
   
    // Form fields
    @State private var title: String = ""
    @State private var year: String = ""
    @State private var rating: Int = 0
    @State private var plot: String = ""
    @State private var posterURL: String = ""
    @State private var selectedImage: PhotosPickerItem?
    @State private var displayedImage: Image?
   
    // Optional fields
    @State private var rated: String = ""
    @State private var released: String = ""
    @State private var runtime: String = ""
    @State private var genre: String = ""
    @State private var director: String = ""
    @State private var writer: String = ""
    @State private var actors: String = ""
    @State private var language: String = ""
    @State private var country: String = ""
    @State private var showOptionalFields = false
   
    // Validation and UI states
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showPreview = false
    @State private var yearValidation = true
    @State private var urlValidation = true
    @State private var isValidatingURL = false
    @State private var showYearError = false
    @State private var showURLError = false
    @State private var imageSource: ImageSource = .none
   
    // Validation publisher
    private let urlValidationPublisher = PassthroughSubject<String, Never>()
    private let debounceDuration: TimeInterval = 0.5
    @State private var cancellables = Set<AnyCancellable>()
   
    private enum ImageSource {
        case none
        case url
        case gallery
    }
   
    init(mode: Mode) {
        self.mode = mode
        if case .edit(let movie) = mode {
            _title = State(initialValue: movie.title)
            _year = State(initialValue: movie.year)
            _plot = State(initialValue: movie.plot)
            _rating = State(initialValue: movie.rating)
            _posterURL = State(initialValue: movie.poster)
            _rated = State(initialValue: movie.rated ?? "")
            _released = State(initialValue: movie.released ?? "")
            _runtime = State(initialValue: movie.runtime ?? "")
            _genre = State(initialValue: movie.genre ?? "")
            _director = State(initialValue: movie.director ?? "")
            _writer = State(initialValue: movie.writer ?? "")
            _actors = State(initialValue: movie.actors ?? "")
            _language = State(initialValue: movie.language ?? "")
            _country = State(initialValue: movie.country ?? "")
           
            if let galleryImage = movie.galleryImage {
                _displayedImage = State(initialValue: galleryImage)
                _imageSource = State(initialValue: .gallery)
            } else if !movie.poster.isEmpty {
                _imageSource = State(initialValue: .url)
            }
        }
    }
   
    // Validation logic
    private var isValidTitle: Bool {
        title.count >= 2
    }
   
    private var isValidPlot: Bool {
        plot.count >= 10
    }
   
    private var isValidYear: Bool {
        guard let yearInt = Int(year) else { return false }
        let currentYear = Calendar.current.component(.year, from: Date())
        return yearInt >= 1888 && yearInt <= currentYear
    }
   
    private var isValidURL: Bool {
        guard !posterURL.isEmpty else { return true }
        return URL(string: posterURL)?.scheme?.hasPrefix("http") ?? false
    }
   
    private var canSave: Bool {
        isValidTitle &&
        !plot.isEmpty &&
        isValidYear &&
        isValidURL &&
        (!posterURL.isEmpty || displayedImage != nil)
    }
   
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
           
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HeaderSection
                   
                    // Required Fields
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Required Fields")
                            .font(.headline)
                            .foregroundColor(.white)
                       
                        RequiredFieldsSection
                       
                        // Poster Section
                        PosterSection
                       
                        // Optional Fields
                        OptionalFieldsSection
                        
                        PreviewButton
                       
                        if case .edit = mode {
                            DeleteButton
                        }
                    }
                    .padding()
                }

            }
        }
        .sheet(isPresented: $showPreview) {
            MoviePreviewView(
                movie: createPreviewMovie(),
                onSave: saveChanges,
                onCancel: { showPreview = false }
            )
        }
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .onChange(of: selectedImage) { _, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    withAnimation {
                        displayedImage = Image(uiImage: uiImage)
                        posterURL = ""
                        imageSource = .gallery
                    }
                }
            }
        }
        .onAppear {
            setupURLValidation()
        }
    }
   
    private var HeaderSection: some View {
        HStack {
            Button(action: {
                if case .add = mode {
                    router.dismissScreen()
                } else {
                    dismiss()
                }
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
            }
           
            Spacer()
           
            Text(mode.title)
                .font(.headline)
                .foregroundColor(.white)
           
            Spacer()
           
            Button(action: saveChanges) {
                Text("Save")
                    .foregroundColor(.red)
            }
            .disabled(!canSave)
        }
        .padding()
    }
   
    private var RequiredFieldsSection: some View {
        VStack(spacing: 16) {
            MovieTextField(text: $title, placeholder: "Title")
                .overlay(ValidationCheckmark(isValid: isValidTitle && !title.isEmpty))
           
            VStack(alignment: .leading, spacing: 4) {
                MovieTextField(text: $year, placeholder: "Year")
                    .keyboardType(.numberPad)
                    .overlay(ValidationCheckmark(isValid: isValidYear && !year.isEmpty))
                    .onChange(of: year) { _, newValue in
                        withAnimation(.easeInOut) {
                            yearValidation = isValidYear
                            showYearError = !yearValidation && !newValue.isEmpty
                        }
                    }
               
                if showYearError {
                    Text("Please enter a valid year (1888-present)")
                        .font(.caption)
                        .foregroundColor(.red)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
           
            MovieTextField(text: $plot, placeholder: "Description")
                .frame(height: 100)
                .overlay(ValidationCheckmark(isValid: isValidPlot && !plot.isEmpty))
           
            HStack {
                Text("Rating:")
                    .foregroundColor(.white)
                RatingPicker(rating: $rating)
            }
        }
    }
   
    private var PosterSection: some View {
        VStack(alignment: .leading, spacing: 4) {

           
            HStack {
                MovieTextField(text: $posterURL, placeholder: "Poster URL")
                    .overlay(
                        HStack {
                            if isValidatingURL {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                    .scaleEffect(0.7)
                            } else {
                                ValidationCheckmark(isValid: urlValidation && !posterURL.isEmpty)
                            }
                        }
                        .padding(.trailing, 8)
                    )
                    .onChange(of: posterURL) { _, newValue in
                        isValidatingURL = true
                        urlValidationPublisher.send(newValue)
                       
                        if isValidURL && !newValue.isEmpty {
                            selectedImage = nil
                            displayedImage = nil
                            imageSource = .url
                        }
                    }
               
                PhotosPicker(selection: $selectedImage) {
                    Image(systemName: "photo")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(8)
                }
            }
           
            if let displayedImage {
                ImagePreview(image: displayedImage) {
                    withAnimation {
                        self.selectedImage = nil
                        self.displayedImage = nil
                        self.imageSource = .none
                    }
                }
            }
        }
    }
   
    private var OptionalFieldsSection: some View {
        VStack(alignment: .leading) {
            // Optional Fields Toggle
            
            
            Button(action: { showOptionalFields.toggle() }) {
                HStack {
                    Text(showOptionalFields ? "Hide Optional Fields" : "Show Optional Fields")
                        .foregroundColor(.white)
                    Image(systemName: showOptionalFields ? "chevron.up" : "chevron.down")
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.gray.opacity(0.3))
                .cornerRadius(8)
            }
       
            // Optional Fields
            if showOptionalFields {
                VStack(spacing: 16) {
               
                   
                    MovieTextField(text: $rated, placeholder: "Rated")
                    MovieTextField(text: $released, placeholder: "Release Date")
                    MovieTextField(text: $runtime, placeholder: "Runtime")
                    MovieTextField(text: $genre, placeholder: "Genre")
                    MovieTextField(text: $director, placeholder: "Director")
                    MovieTextField(text: $writer, placeholder: "Writer")
                    MovieTextField(text: $actors, placeholder: "Actors")
                    MovieTextField(text: $language, placeholder: "Language")
                    MovieTextField(text: $country, placeholder: "Country")
                }
            
            }
        }.padding(.vertical, 16)
    }
   
    private var PreviewButton : some View {
            Button(action: { showPreview = true }) {
                Text("Preview")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canSave ? Color.green.opacity(0.5) : Color.gray.opacity(0.3))
                    .cornerRadius(8)
            }
            .disabled(!canSave)
            .padding()
    }
    private var DeleteButton: some View {
        Button(action: {
            if case .edit(let movie) = mode {
                modelContext.delete(movie)
                dismiss()
            }
        }) {
            Text("Delete Movie")
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .cornerRadius(8)
        }.padding()
    }
   

//   funcs
    private func setupURLValidation() {
        urlValidationPublisher
            .debounce(for: .seconds(debounceDuration), scheduler: RunLoop.main)
            .sink { url in
                // Only validate URL and show progress when the image source is URL
                if self.imageSource == .url {
                    withAnimation(.easeInOut) {
                        self.urlValidation = self.isValidURL
                        self.showURLError = !self.urlValidation && !url.isEmpty
                        self.isValidatingURL = false
                    }
                } else {
                    // Reset URL validation state when not using URL
                    self.isValidatingURL = false
                    self.urlValidation = true
                    self.showURLError = false
                }
            }
            .store(in: &cancellables)
    }

   
    private func saveChanges() {
        guard canSave else {
            alertMessage = "Please fill in all required fields correctly"
            showAlert = true
            return
        }
       
        switch mode {
        case .add:
            saveNewMovie()
        case .edit(let movie):
            updateMovie(movie)
        }
    }
   
    private func saveNewMovie() {
        let movieDetail = MovieDetail(
            title: title,
            year: year,
            rated: rated,
            released: released,
            runtime: runtime,
            genre: genre,
            director: director,
            writer: writer,
            actors: actors,
            plot: plot,
            language: language,
            country: country,
            awards: "",
            poster: posterURL,
            ratings: [],
            metascore: "",
            imdbRating: "",
            imdbVotes: "",
            imdbID: UUID().uuidString,
            type: "movie",
            dvd: "",
            boxOffice: "",
            production: "",
            website: "",
            response: "True"
        )
       
        let movie = DetailedMovie(from: movieDetail, galleryImage: imageSource == .gallery ? displayedImage : nil)
        movie.rating = rating
       
        if let userId = UserDefaults.standard.string(forKey: "currentUserId"),
           let uuid = UUID(uuidString: userId),
           let user = try? modelContext.fetch(FetchDescriptor<MovieUser>()).first(where: { $0.id == uuid }) {
            movie.user = user
            modelContext.insert(movie)
            router.dismissScreen()
        } else {
            alertMessage = "Error finding current user"
            showAlert = true
        }
    }
   
    private func updateMovie(_ movie: DetailedMovie) {
        movie.title = title
        movie.year = year
        movie.plot = plot
        movie.rating = rating
        movie.rated = rated
        movie.released = released
        movie.runtime = runtime
        movie.genre = genre
        movie.director = director
        movie.writer = writer
        movie.actors = actors
        movie.language = language
        movie.country = country
       
        switch imageSource {
        case .url:
            movie.poster = posterURL
            movie.galleryImage = nil
        case .gallery:
            movie.poster = ""
            movie.galleryImage = displayedImage
        case .none:
            movie.poster = ""
            movie.galleryImage = nil
        }
       
        try? modelContext.save()
        dismiss()
    }
   
    private func createPreviewMovie() -> DetailedMovie {
        let movieDetail = MovieDetail(
            title: title,
            year: year,
            rated: rated,
            released: released,
            runtime: runtime,
            genre: genre,
            director: director,
            writer: writer,
            actors: actors,
            plot: plot,
            language: language,
            country: country,
            awards: "",
            poster: posterURL,
            ratings: [],
            metascore: "",
            imdbRating: "",
            imdbVotes: "",
            imdbID: UUID().uuidString,
            type: "movie",
            dvd: "",
            boxOffice: "",
            production: "",
            website: "",
            response: "True"
        )
       
        let movie = DetailedMovie(from: movieDetail, galleryImage: imageSource == .gallery ? displayedImage : nil)
        movie.rating = rating
        return movie
    }
}


// MARK: - Supporting Types


extension MovieFormView.Mode {
    var title: String {
        switch self {
        case .add:
            return "Add Movie"
        case .edit:
            return "Edit Movie"
        }
    }
}


struct ImagePreview: View {
    let image: Image
    let onDelete: () -> Void
   
    var body: some View {
        ZStack(alignment: .topTrailing) {
            
            HStack {
                Spacer()
                image
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(8)
               
                Spacer()
            }
           
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
                    .padding(8)
            }
        }
    }
}

struct ValidationCheckmark: View {
    let isValid: Bool
   
    var body: some View {
        HStack {
            Spacer()
            if !isValid {
                Image(systemName: "exclamationmark.circle")
                    .foregroundColor(.red)
                    .opacity(0.7)
            } else {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.green)
                    .opacity(0.7)
            }
        }
        .padding(.trailing, 8)
        .transition(.scale.combined(with: .opacity))
    }
}


struct MovieTextField: View {
    @Binding var text: String
    var placeholder: String
   
    var body: some View {
        TextField("", text: $text)
            .placeholder(when: text.isEmpty) {
                Text(placeholder)
                    .foregroundColor(.gray)
                    .padding(.leading, 8)
            }
            .textFieldStyle(DarkTextFieldStyle())
            .animation(.easeInOut, value: text)
    }
}

// Add preview
#Preview {
    RouterView { _ in
        MovieFormView(mode: .add)
    }
}


#Preview("Edit Mode") {
    let previewMovie = DetailedMovie(from: MovieDetail(
        title: "Test Movie",
        year: "2024",
        rated: "PG-13",
        released: "2024-03-15",
        runtime: "120 min",
        genre: "Action",
        director: "John Doe",
        writer: "Jane Smith",
        actors: "Actor 1, Actor 2",
        plot: "A test movie plot",
        language: "English",
        country: "USA",
        awards: "",
        poster: "https://example.com/poster.jpg",
        ratings: [],
        metascore: "",
        imdbRating: "",
        imdbVotes: "",
        imdbID: "custom123",
        type: "movie",
        dvd: "",
        boxOffice: "",
        production: "",
        website: "",
        response: "True"
    ))
   
    return RouterView { _ in
        MovieFormView(mode: .edit(previewMovie))
    }
}


