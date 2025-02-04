//
//  Hero.swift
//  movies
//
//  Created by Guest User on 22/01/2025.
//

import SwiftUI
import SwiftfulUI

struct Hero: View {
    var imageName: String = "";
    var isNetflixFilm: Bool = true;
    var title: String = "Players";
    
    // actions
    var onBackgroundClicked: (() -> Void)? = nil;
    var onPlayClicked: (() -> Void)? = nil;
    var onMyListClicked: (() -> Void)? = nil;
    var body: some View {
        ZStack(alignment: .bottom){
            ImageView(url: imageName);
            VStack(spacing: 16) {
                if isNetflixFilm {
                    HStack {
                        Text("N")
                            .foregroundStyle(.nRed)
                            .font(.largeTitle)
                            .fontWeight(.black)
                        
                        // kerning is spacing between chars
                        Text("FILM")
                            .kerning(3)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    }
                    Spacer()
//                    Text(title)
//                        .font(.system(size: 50, weight: .medium, design: .serif))
                }
                
                
                HStack(spacing: 16){
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Play")
                    }
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                    .padding(.vertical, 8)
                    .foregroundStyle(.nDarkGray)
                    .background(.white)
                    .cornerRadius(4)
                    .asButton(.press){

                    }
                    
                    HStack {
                        Image(systemName: "plus")
                        Text("My List")
                    }
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                    .padding(.vertical, 8)
                    .foregroundStyle(.white)
                    .background(.nDarkGray)
                    .cornerRadius(4)
                    .asButton(.press){

                    }
                }
                .font(.callout)
                .fontWeight(.medium)
                
                    
            }
            .padding(24)
            .background(
                LinearGradient(colors: [
                    .nBlack.opacity(0),
                    .nBlack.opacity(0.4),
                    .nBlack.opacity(0.4),
                    .nBlack.opacity(0.4)
                ],
                startPoint: .top,
                endPoint: .bottom
                )
            )
        }
        .foregroundStyle(.white)
        .cornerRadius(10)
        .aspectRatio(0.8, contentMode: .fit)
        .asButton(.tap){

        }
    }
}

#Preview {
    Hero(imageName: "https://picsum.photos/200/300")
}
