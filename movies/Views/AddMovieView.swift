//
//  AddMovieView.swift
//  movies
//
//  Created by Terran Winner on 2/3/25.
//

import SwiftUI
import PhotosUI
import SwiftData
import Combine
import SwiftfulRouting
struct AddMovieView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.router) var router
    @Query private var users: [MovieUser]
   
    @State private var title = ""
    @State private var year = ""
    @State private var rating: Int = 0
    @State private var plot = ""
    @State private var posterURL = ""
    @State private var selectedImage: PhotosPickerItem?
    @State private var displayedImage: Image?
   
    // Optional fields
    @State private var rated = ""
    @State private var released = ""
    @State private var runtime = ""
    @State private var genre = ""
    @State private var director = ""
    @State private var writer = ""
    @State private var actors = ""
    @State private var language = ""
    @State private var country = ""
    @State private var showOptionalFields = false
   
    @State private var showAlert = false
    @State private var alertMessage = ""
   
    @State private var showPreview = false
    @State private var yearValidation = true
    @State private var urlValidation = true
   
    // Add debouncing properties
    @State private var debouncedURL = ""
    @State private var urlValidationPublisher = PassthroughSubject<String, Never>()
    private let debounceDuration: TimeInterval = 0.5
   
    // Add animation states
    @State private var isValidatingURL = false
    @State private var showYearError = false
    @State private var showURLError = false
   
    @State private var imageSource: ImageSource = .none
   
    private enum ImageSource {
        case none
        case url
        case gallery
    }
   
    // Enhanced validation
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
        !title.isEmpty &&
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
                    HStack {
                        Button(action: { router.dismissScreen() }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                        }
                       
                        Spacer()
                       
                        Text("Add Movie")
                            .font(.headline)
                            .foregroundColor(.white)
                       
                        Spacer()
                       
                        Button(action: saveMovie) {
                            Text("Save")
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                   
                    // Required Fields
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Required Fields")
                            .font(.headline)
                            .foregroundColor(.white)
                       
                        MovieTextField(text: $title, placeholder: "Title")
                            .overlay(
                                ValidationCheckmark(isValid: isValidTitle && !title.isEmpty)
                            )
                       
                        VStack(alignment: .leading, spacing: 4) {
                            MovieTextField(text: $year, placeholder: "Year")
                                .keyboardType(.numberPad)
                                .overlay(
                                    ValidationCheckmark(isValid: isValidYear && !year.isEmpty)
                                )
                                .onChange(of: year) { oldValue, newValue in
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
                            .overlay(
                                ValidationCheckmark(isValid: isValidPlot && !plot.isEmpty)
                            )
                       
                        // Rating
                        HStack {
                            Text("Rating:")
                                .foregroundColor(.white)
                            RatingPicker(rating: $rating)
                        }
                       
                        // Poster
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Poster:")
                                .foregroundColor(.white)
                           
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
                                    .onChange(of: posterURL) { oldValue, newValue in
                                        isValidatingURL = true
                                        urlValidationPublisher.send(newValue)
                                       
                                        // Clear gallery image if valid URL is entered
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
                                .disabled(imageSource == .url)
                                .opacity(imageSource == .url ? 0.5 : 1)
                            }
                           
                            if showURLError {
                                Text("Please enter a valid URL starting with http:// or https://")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .transition(.move(edge: .top).combined(with: .opacity))
                            }
                           
                            // Image preview with remove button
                            if let displayedImage {
                                ZStack(alignment: .topTrailing) {
                                    displayedImage
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 200)
                                        .cornerRadius(8)
                                   
                                    Button(action: {
                                        withAnimation {
                                            self.selectedImage = nil
                                            self.displayedImage = nil
                                            self.imageSource = .none
                                        }
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.white)
                                            .background(Color.black.opacity(0.6))
                                            .clipShape(Circle())
                                            .padding(8)
                                    }
                                }
                                .transition(.opacity)
                            }
                        }
                    }
                    .padding()
                   
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
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Optional Fields")
                                .font(.headline)
                                .foregroundColor(.white)
                           
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
                        .padding()
                    }
                   
                    // Preview Button
                    Button(action: { showPreview = true }) {
                        Text("Preview")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(8)
                    }
                    .disabled(!canSave)
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showPreview) {
            MoviePreviewView(
                movie: createPreviewMovie(),
                onSave: saveMovie,
                onCancel: { showPreview = false }
            )
        }
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .onChange(of: selectedImage) { oldValue, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    withAnimation {
                        displayedImage = Image(uiImage: uiImage)
                        posterURL = "" // Clear URL when gallery image is selected
                        imageSource = .gallery
                    }
                }
            }
        }
        .onAppear {
            // Setup URL validation debouncing
            urlValidationPublisher
                .debounce(for: .seconds(debounceDuration), scheduler: RunLoop.main)
                .sink { [self] url in
                    withAnimation(.easeInOut) {
                        urlValidation = isValidURL
                        showURLError = !urlValidation && !url.isEmpty
                        isValidatingURL = false
                    }
                }
                .store(in: &cancellables)
        }
    }
   
    // Store cancellables
    @State private var cancellables = Set<AnyCancellable>()
   
    private func saveMovie() {
        guard !title.isEmpty, !year.isEmpty, !plot.isEmpty,
              (!posterURL.isEmpty || displayedImage != nil) else {
            alertMessage = "Please fill in all required fields"
            showAlert = true
            return
        }
       
        // Handle image source for poster URL
        let finalPosterURL: String
        if imageSource == .gallery {
            // Here you would typically:
            // 1. Upload the image to your server
            // 2. Get back the URL
            // For now, we'll use a placeholder
            finalPosterURL = "gallery-image-placeholder"
        } else {
            finalPosterURL = posterURL
        }
       
        // Create a MovieDetail to initialize DetailedMovie
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
            poster: finalPosterURL,
            ratings: [],
            metascore: "",
            imdbRating: "",
            imdbVotes: "",
            imdbID: UUID().uuidString, // Generate a unique ID
            type: "movie",
            dvd: "",
            boxOffice: "",
            production: "",
            website: "",
            response: "True"
        )
       
        let movie = DetailedMovie(from: movieDetail)
        movie.rating = rating // Set the user rating separately
       
        // Get current user
        if let userId = UserDefaults.standard.string(forKey: "currentUserId"),
           let uuid = UUID(uuidString: userId),
           let user = users.first(where: { $0.id == uuid }) {
            movie.user = user
            modelContext.insert(movie)
            router.dismissScreen()
        } else {
            alertMessage = "Error finding current user"
            showAlert = true
        }
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
// Add ValidationCheckmark component
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
// Update MovieTextField to show validation state
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


#Preview {
    RouterView { _ in
        AddMovieView()
    }
   
}










