//
//  EditMovieView.swift
//  movies
//
//  Created by Terran Winner on 2/3/25.
//

import SwiftUI
import SwiftData
import PhotosUI
import Combine


struct EditMovieView: View {
    let movie: DetailedMovie
   
    var body: some View {
        MovieFormView(mode: .edit(movie))
    }
}





//#Preview {
//    EditMovieView()
//}
