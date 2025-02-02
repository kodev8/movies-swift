//
//  HomeView.swift
//  movies
//
//  Created by Guest User on 15/01/2025.
//

import SwiftUI

struct movieRow {
    var movies: [Movie];
}

struct HomeView: View {
    
    @State private var filters = Filter.mFitlers;
    @State private var selectedFilter: Filter? = nil;
    @State private var fullHeaderSize: CGRect = .zero;
    @State private var heroMovie: Movie? = nil;
    
    //    @State provate var currentUser: User? = nil;
    
    @State private var movieRows: [movieRow] = [];
    
    
    var body: some View {
        ZStack(alignment: .top){
            Color.nBlack.ignoresSafeArea()
            
            ScrollView(.vertical){
                VStack(spacing: 8){
                    Rectangle()
                        .opacity(0)
                        .frame(height: fullHeaderSize.height)
                    
                    if let heroMovie = heroMovie {
                        Hero(
                            imageName: heroMovie.poster,
                            isNetflixFilm: true,
                            title: heroMovie.title,
                            categories: [heroMovie.genre],
                            onBackgroundClicked: {
                                
                            },
                            onPlayClicked: {
                                
                            },
                            onMyListClicked: {
                                
                            }
                            
                        )
                        .padding(24)
                    }
                    
                    genreRows
                }
                
            }
            .scrollIndicators(.hidden)
            
            VStack(spacing:0) {
                header.padding(.horizontal, 16)
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
            }
            .background(Color.blue)
            //        .readingFrame { frame in
            //            fullHeaderSize = frame.size
            //        }
            
        }
        .foregroundStyle(.white)
        //        .task {
        //            await getData()
        //        }
        .toolbar(.hidden, for: .navigationBar)
        
    }
    
    private func getData() async {
        
    }
        
        private var genreRows: some View {
            LazyVStack(spacing: 16) {
                ForEach(Array(movieRows.enumerated()), id: \.offset){ (rowIndex, row) in
                    VStack(alignment: .leading, spacing: 6) {
                        Text("")
                            .font(.headline)
                            .padding(.horizontal, 16)
                        
                        ScrollView(.horizontal) {
                            LazyHStack {
                                ForEach(Array(row.movies.enumerated()), id: \.offset) {(index, movie) in
                                    MovieRowItem(
                                        imageName: movie.poster ,
                                        title: movie.title,
                                        isRecentlyAdded: false,
                                        topTenRanking: rowIndex == 1 ? (index + 1) : nil
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .scrollIndicators(.hidden)
                        
                    }
                    
                }
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


#Preview {
    HomeView()
}
