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
        await movieService.getMovies(url: "https://omdbapi.com/?s=titanic&page=1&apikey=708off75")
    }
    
    var body: some View {
        
        
        ZStack{
            
            VStack {
                Rectangle().fill(.black).frame(width: 500, height: 1000)
            }
            
            VStack {
                
                
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Netflix")
                    .foregroundColor(.gray)
                
                    Button(action: signIn) {
                        Label("sign in", systemImage: "arrow.up")
                    }
                
                Button(action: fetchTodos) {
                    Label("fetch posts", systemImage: "arrow.up")
                }
                
                Button(action: clearTodos) {
                    Label("clear", systemImage: "arrow.up")
                }
                
                Button(action: {
                    Task {
                        await fetchMovies()
                    }
                }) {
                    Label("Fetch Movies", systemImage: "film")
                }
                
                List(todos) { todo in
                    VStack {
                        Text(todo.title)
                        Text("\(todo.userId)")
                        if (todo.completed) {
                            Text("co")
                        }else {
                            Text("nco")
                        }
                    }
                }
                .frame(height: 200)
                
                List(movieService.movies) { movie in
                    VStack(alignment: .leading) {
                        Text(movie.title)
                            .font(.headline)
                        Text(movie.year)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .frame(height: 200)
                
            }.padding()
            
            
            
           
            
        }
        
       

    }
    
}

#Preview {
    ContentView()
}
