//
//  MovieRowItem.swift
//  movies
//
//  Created by Terran Winner on 2/2/25.
//

import SwiftUI

struct MovieRowItem: View {
    
    var width: CGFloat = 90;
    var height: CGFloat = 130;
    
    var movie: Movie? = nil
    var imageName: String = "";
    var title: String? = "";
    var isRecentlyAdded: Bool = true;
    var topTenRanking: Int? = nil;
    
    
    var body: some View {
        HStack(alignment: .bottom, spacing: -8){
            if let topTenRanking {
                Text("\(topTenRanking)")
                    .font(.system(
                        size: 100,
                        weight: .medium,
                        design: .serif)
                    )
                    .offset(y: 20)
            }
            
            ZStack(alignment: .bottom) {
                ImageView(url: imageName)
                
                VStack(spacing: 0) {
                    if let title, let firstWord = title.components(separatedBy:" " ).first {
                        Text(firstWord)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .lineLimit(1)
                        
                    }
                    
                    
                    Text("Recently Added")
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .padding(.bottom, 2)
                        .frame(maxWidth: .infinity)
                        .background(.green)
                        .cornerRadius(2)
                        .offset(y: 2)
                        .lineLimit(1)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .minimumScaleFactor(0.1)
                        .padding(.horizontal, 8)
                        .opacity(isRecentlyAdded ? 1 : 0)
                }
                .padding(.top, 6)
                .background(
                    LinearGradient(colors: [
                        .black.opacity(0),
                        .black.opacity(0.3),
                        .black.opacity(0.4)
                        
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                    )
                )
            }
            .cornerRadius(4)
            .frame(width: width, height: height)
            
        }
        .foregroundStyle(.white)
    }
        
}

#Preview {
    MovieRowItem(isRecentlyAdded: true)
    MovieRowItem(isRecentlyAdded: false)
}
