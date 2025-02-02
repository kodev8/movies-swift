//
//  ImageView.swift
//  movies
//
//  Created by Guest User on 24/01/2025.
//

import SwiftUI
import SDWebImageSwiftUI;



struct ImageView: View {
    var url: String = "https://picsum.photos/200/300";
    var resizingMode: ContentMode = .fill
    
    var body: some View {
        Rectangle()
            .opacity(0.001)
            .overlay(
                WebImage(url: URL(string: url))
                    .resizable()
                    .indicator(.activity)
                    .aspectRatio(contentMode: resizingMode)
                    .allowsHitTesting(false)
                
            )
            .clipped()
    }
}

#Preview {
    ImageView()
        .cornerRadius(30)
        .padding(40)
        .padding(.vertical, 60)
}
