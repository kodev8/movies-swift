//
//  MovieDetailsView.swift
//  movies
//
//  Created by Terran Winner on 2/2/25.
//

import SwiftUI

struct MovieDetailsView: View {
    
    @Environment(\.router) var router
    var movie: Movie? = nil;
    
    @State private var progress: Double = 0.8
    @State private var isMyList: Bool = false
    @State private var movies: [Movie] = []
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Color.nDarkGray.opacity(0.3).ignoresSafeArea()
            
            VStack(spacing: 0){
                DetailsHeader(
                    progress: progress,
                    onXPressed: {
                        router.dismissScreen()
                    }
                )
                
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 16) {
                        detailsSection
                        buttonSection
                        suggestionSection
                      
                    }
                    .padding(8)
                    
                }
                .scrollIndicators(.hidden)
            }
        }
        .task{
            
        }
        .toolbar(.hidden, for: .navigationBar )
    }
    
    
// CallBack
    private func onMoviePressed(movie: Movie) {
        router.showScreen(.sheet) { _ in
            MovieDetailsView(movie: movie)
        }
    }
    
//    SECTIONS
    
    private var detailsSection: some View {
        SubDetailsView(
            title: movie?.title
            ?? "No Title"
            
        )
    }
    
    private var buttonSection: some View {
        HStack(spacing: 32) {
            MyListButton(isMyList: isMyList) {
                isMyList.toggle()
            }
            
            RateButton { selection in
            }
            
            ShareButton()
            
            
        }
        .padding(.leading, 32)
    }
    
    private var suggestionSection: some View {
        
        VStack(alignment: .leading) {
            Text("More Like this")
                .font(.headline)
            
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3),
                alignment: .center,
                spacing: 8,
                pinnedViews: [],
                content: {
                    ForEach(movies) { movie in
                        MovieRowItem(movie: movie)
                            .onTapGesture{
                                onMoviePressed(movie: movie)
                            }
                    }
                }
                      
            )
        }
        .foregroundStyle(.white)
    }
}

#Preview {
    MovieDetailsView()
}
