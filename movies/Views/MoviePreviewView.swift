//
//  MoviePreviewView.swift
//  movies
//
//  Created by Terran Winner on 2/3/25.
//

import SwiftUI
import SwiftData


struct MoviePreviewView: View {
    let movie: DetailedMovie
    let onSave: () -> Void
    let onCancel: () -> Void
   
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
           
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack {
                        Button(action: onCancel) {
                            Text("Cancel")
                                .foregroundColor(.red)
                        }
                       
                        Spacer()
                       
                        Text("Preview")
                            .font(.headline)
                            .foregroundColor(.white)
                       
                        Spacer()
                       
                        Button(action: onSave) {
                            Text("Save")
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                   
                    // Movie Details
                    VStack(alignment: .leading, spacing: 16) {
                        // Use gallery image if available, otherwise use URL
                        if let galleryImage = movie.galleryImage {
                            galleryImage
                                .resizable()
                                .scaledToFit()
                                .frame(height: 300)
                                .cornerRadius(8)
                        } else {
                            AsyncImage(url: URL(string: movie.poster)) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                            } placeholder: {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .overlay(
                                        Image(systemName: "photo")
                                            .foregroundColor(.gray)
                                    )
                            }
                            .frame(height: 300)
                            .cornerRadius(8)
                        }
                       
                        Text(movie.title)
                            .font(.title)
                            .foregroundColor(.white)
                       
                        HStack {
                            Text(movie.year)
                            if let rated = movie.rated {
                                Text("•")
                                Text(rated)
                            }
                            if let runtime = movie.runtime {
                                Text("•")
                                Text(runtime)
                            }
                        }
                        .foregroundColor(.gray)
                       
                        if movie.rating > 0 {
                            RatingPicker(rating: .constant(movie.rating))
                        }
                       
                        Text(movie.plot)
                            .foregroundColor(.white)
                       
                        if let genre = movie.genre {
                            Text("Genre: \(genre)")
                                .foregroundColor(.gray)
                        }
                       
                        if let director = movie.director {
                            Text("Director: \(director)")
                                .foregroundColor(.gray)
                        }
                       
                        if let actors = movie.actors {
                            Text("Cast: \(actors)")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                }
            }
        }
    }
}



//#Preview {
//    MoviePreviewView()
//}
