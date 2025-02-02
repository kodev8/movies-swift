//
//  HomeView.swift
//  movies
//
//  Created by Guest User on 15/01/2025.
//

import SwiftUI
import SwiftfulUI
import SwiftfulRouting

struct movieRow {
    var movies: [Movie];
}

struct HomeView: View {
    
    @Environment(\.router) var router
    
    @State private var filters = Filter.mFitlers;
    @State private var selectedFilter: Filter? = nil;
    @State private var fullHeaderSize: CGSize = .zero;
    @State private var scrollViewOffset: CGFloat = 0;
    @State private var heroMovie: Movie? = nil;
    
    //    @State provate var currentUser: User? = nil;
    
    @State private var movieRows: [movieRow] = [];
    
    
    var body: some View {
        ZStack(alignment: .top){
            Color.nBlack.ignoresSafeArea()
            backgroundGradient
            scrollViewLayer
            fullHeaderWithMenu
        }
        .foregroundStyle(.white)
        .task {
            await getData()
        }
        .toolbar(.hidden, for: .navigationBar)
        
    }
    
    
//    callback
    
    private func getData() async {
        
    }
    
    private func onMoviePressed(movie: Movie) {
        router.showScreen(.sheet) { _ in
            MovieDetailsView(movie: movie)
        }
    }
    
    
    
//    Sections
    
    private var backgroundGradient: some View {
        ZStack {
            LinearGradient(
                colors: [.nDarkGray.opacity(1), .nDarkGray.opacity(0)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            LinearGradient(
                colors: [.nDarkRed.opacity(0.5), .nDarkRed.opacity(0)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
        .frame(maxHeight: max(10, (400 + (scrollViewOffset * 0.75))))
        .opacity(scrollViewOffset < -250 ? 0: 1)
        
    }
        
//    private var genreRows: some View {
//        LazyVStack(spacing: 16) {
//            ForEach(Array(movieRows.enumerated()), id: \.offset){ (rowIndex, row) in
//                VStack(alignment: .leading, spacing: 6) {
//                    Text("")
//                        .font(.headline)
//                        .padding(.horizontal, 16)
//                    
//                    ScrollView(.horizontal) {
//                        LazyHStack {
//                            ForEach(Array(row.movies.enumerated()), id: \.offset) {(index, movie) in
//                                MovieRowItem(
//                                    imageName: movie.poster ,
//                                    title: movie.title,
//                                    isRecentlyAdded: false,
//                                    topTenRanking: rowIndex == 1 ? (index + 1) : nil
//                                ).onTapGesture(
//                                    onMoviePressed(move: movie)
//                                )
//                            }
//                        }
//                        .padding(.horizontal, 16)
//                    }
//                    .scrollIndicators(.hidden)
//                    
//                }
//                
//            }
//        }
//    }
    
    private var scrollViewLayer: some View {
        ScrollViewWithOnScrollChanged(.vertical,
                                      showsIndicators: false,
                                      content: {
            VStack(spacing: 8){
                Rectangle()
                    .opacity(0)
                    .frame(height: fullHeaderSize.height)
                
                if let heroMovie = heroMovie {
                    Hero(
                        imageName: heroMovie.poster,
                        isNetflixFilm: true,
                        title: heroMovie.title,
                        categories: [heroMovie.type],
                        onBackgroundClicked: {
                            onMoviePressed(movie: heroMovie)
                        },
                        onPlayClicked: {
                            onMoviePressed(movie: heroMovie)
                        },
                        onMyListClicked: {
                            
                        }
                        
                    )
                    .padding(24)
                }
                Text("\(scrollViewOffset)")
                    .foregroundStyle(.red)
//                genreRows
            }
            
        },
        onScrollChanged: { offset in
            scrollViewOffset = offset.y
        }
            
        )
        
    }

    private var fullHeaderWithMenu: some View {
        
        VStack(spacing:0) {
            header.padding(.horizontal, 16)
            
            if scrollViewOffset > -20 {
                PillContainer(
                    filters: filters,
                    selectedFilter: selectedFilter,
                    onXClicked: {
                        selectedFilter = nil
                    },
                    onFilterClicked: { newFilter in
                        selectedFilter = newFilter
                        
                    }
                )
                .padding(.top, 16)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
        }
        .padding(.bottom, 8)
        .background(
            ZStack {
                if scrollViewOffset < -70 {
                    Rectangle()
                        .fill(Color.clear)
                        .background(.ultraThinMaterial)
                        .brightness(-0.2)
                        .ignoresSafeArea()
                }
            }
        )
        .animation(.smooth, value: scrollViewOffset)
        .readingFrame { frame in
            if fullHeaderSize == .zero {
                fullHeaderSize = frame.size
            }
            
        }
        
    }
    
    private var header: some View {
        HStack(spacing:0) {
            Text("For you")
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                ).bold()
                .onTapGesture {
                    router.dismissScreen()
                }
            
            HStack(spacing: 16) {
                Image(systemName: "tv.badge.wifi").onTapGesture {
                    //
                    print("tv")
                }
                
                Image(systemName: "arrow.down.to.line").onTapGesture {
                    //
                    print("downnnload")
                }
                
                Image(systemName: "magnifyingglass").onTapGesture {
                    print("search")
                    //
                }
            }
        }.font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
        
        
    }
           
}


    
 


#Preview {
    
    RouterView { _ in
        HomeView()
    }
   
}
