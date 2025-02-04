//
//  AddMovieView.swift
//  movies
//
//  Created by Terran Winner on 2/3/25.
//

import SwiftUI
import SwiftData
import PhotosUI
import Combine
import SwiftfulRouting


struct AddMovieView: View {
   
    var body: some View {
        MovieFormView(mode: .add)
    }
}


#Preview {
    RouterView { _ in
        AddMovieView()
    }
   
}










