//
//  MovieContentView.swift
//  movies
//
//  Created by Terran Winner on 2/4/25.
//

import SwiftUI
import SwiftfulUI


struct MovieContentView: View {
    let heroMovie: Movie?
    let movieRows: [movieRow]
    let selectedFilter: Filter?
    let scrollViewOffset: CGFloat
    let fullHeaderSize: CGSize
    let onMoviePressed: (Movie) -> Void
    let onScrollChanged: (CGPoint) -> Void
   
    var body: some View {
        ZStack {
            // Regular content
            scrollViewLayer
            .opacity(selectedFilter == nil ? 1 : 0)
           
            // Grid content
            if let filter = selectedFilter {
                movieGridView(for: filter)
                    .transition(.opacity)
            }
        }
        .animation(.smooth, value: selectedFilter)
    }
   
    private var scrollViewLayer: some View {
        ScrollViewWithOnScrollChanged(.vertical,
                                    showsIndicators: false,
                                    content: {
            VStack(spacing: 8) {
                Rectangle()
                    .opacity(0)
                    .frame(height: fullHeaderSize.height)
               
                if let heroMovie = heroMovie {
                    Hero(
                        imageName: heroMovie.poster,
                        isNetflixFilm: true,
                        title: heroMovie.title,
                        onBackgroundClicked: {
                            onMoviePressed(heroMovie)
                        }
                    )
                    .padding(24)
                }
                genreRows
            }
        },
        onScrollChanged: onScrollChanged)
    }
   
    private var genreRows: some View {
        LazyVStack(spacing: 16) {
            ForEach(Array(movieRows.enumerated()), id: \.offset) { rowIndex, row in
                MovieGenreRow(
                    rowIndex: rowIndex,
                    movies: row.movies,
                    onMoviePressed: onMoviePressed
                )
            }
        }
    }
    
    private struct MovieGenreRow: View {
           let rowIndex: Int
           let movies: [Movie]
           let onMoviePressed: (Movie) -> Void
          
           var body: some View {
               VStack(alignment: .leading, spacing: 6) {
                   Text(getRowTitle(rowIndex: rowIndex))
                       .font(.headline)
                       .padding(.horizontal, 16)
                  
                   ScrollView(.horizontal) {
                       LazyHStack {
                           ForEach(Array(movies.enumerated()), id: \.offset) { index, movie in
                               MovieRowItem(
                                   imageName: movie.poster,
                                   title: movie.title,
                                   isRecentlyAdded: rowIndex == 2,
                                   topTenRanking: rowIndex == 1 ? index + 1 : nil
                               )
                               .onTapGesture {
                                   onMoviePressed(movie)
                               }
                           }
                       }
                       .padding(.horizontal, 16)
                   }
                   .scrollIndicators(.hidden)
               }
           }
          
           private func getRowTitle(rowIndex: Int) -> String {
               switch rowIndex {
               case 0:
                   return "Popular Movies"
               case 1:
                   return "Top 20 Today"
               case 2:
                   return "Recently Added"
               default:
                   return "Movies"
               }
           }
       }
       
   
    @ViewBuilder
    private func movieGridView(for filter: Filter) -> some View {
        let movies: [Movie] = {
            switch filter.title {
            case "Popular":
                return movieRows[0].movies
            case "Top 20":
                return movieRows[1].movies
            case "Upcoming":
                return movieRows[2].movies
            default:
                return []
            }
        }()
       
        MovieGridView(
            title: filter.title,
            movies: movies,
            fullHeaderSize: fullHeaderSize,
            onMoviePressed: onMoviePressed,
            onScrollChanged: onScrollChanged
        )
    }
    
    
    private struct MovieGridView: View {
        let title: String
        let movies: [Movie]
        let fullHeaderSize: CGSize
        let onMoviePressed: (Movie) -> Void
        let onScrollChanged: (CGPoint) -> Void
        @State private var gridColumns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 2)
       
        var body: some View {
            ScrollViewWithOnScrollChanged(.vertical,
            showsIndicators: false,
            content: {
                Rectangle()
                    .opacity(0)
                    .frame(height: fullHeaderSize.height)
                LazyVGrid(columns: gridColumns, spacing: 16) {
                    ForEach(movies) { movie in
                        MovieGridItem(movie: movie)
                            .onTapGesture {
                                onMoviePressed(movie)
                            }
                    }
                }
                .padding()
            },
            onScrollChanged: onScrollChanged)
        }
    }


    private struct MovieGridItem: View {
        let movie: Movie
       
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                // Movie Poster
                AsyncImage(url: URL(string: movie.poster)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .foregroundColor(.gray.opacity(0.3))
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 8))
               
                // Movie Title
                Text(movie.title)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .font(.caption)
            }
        }
    }
}
// preview in home
