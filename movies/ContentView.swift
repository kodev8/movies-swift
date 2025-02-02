//
//  ContentView.swift
//  movies
//
//  Created by Guest User on 11/01/2025.
//

import SwiftUI

struct Todo: Codable, Identifiable {
    let id: Int
    let userId: Int
    let title: String
    let completed: Bool
}

struct ContentView: View {
    
    @StateObject private var movieService = MovieService()
    @State private var todos: [Todo] = []
    
    func signIn() {
        print("Hello")
    }
    
    func fetchTodos() {
        
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/todos/")
        else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                if let decodedTodos = try? JSONDecoder().decode([Todo].self, from: data) {
//                    print(decodedTodos) 
                    DispatchQueue.main.async {
                        self.todos = decodedTodos
                    }
                }
            }
            
        }.resume()
        
    }
    
    func clearTodos (){
        DispatchQueue.main.async {
            self.todos = []
        }
    }
    
    func fetchMovies() async {
        await movieService.getMovies(url: "https://www.omdbapi.com/?s=titanic&apikey=YOUR_API_KEY")
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "film")
                        .imageScale(.large)
                        .foregroundStyle(.red)
                    Text("Movie Browser")
                        .font(.title)
                        .foregroundColor(.white)
                }
                .padding(.top)
                
                // Fetch Movies Button
                Button(action: {
                    Task {
                        await fetchMovies()
                    }
                }) {
                    Label("Search Movies", systemImage: "magnifyingglass")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(8)
                }
                
                // Movies List
                if !movieService.movies.isEmpty {
                    List {
                        ForEach(movieService.movies) { movie in
                            MovieRowItem(movie: movie)
                                .listRowBackground(Color.black)
                        }
                    }
                    .listStyle(.plain)
                    .background(Color.black)
                } else {
                    Spacer()
                    Text("Search for movies to get started")
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
            .padding()
        }
    }
    
}

#Preview {
    ContentView()
}
