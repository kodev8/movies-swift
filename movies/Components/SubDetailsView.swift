//
//  SubDetailsView.swift
//  movies
//
//  Created by Terran Winner on 2/2/25.
//

import SwiftUI
import SwiftfulUI

struct SubDetailsView: View {
    var title: String = "Movie Title"
    var isNew: Bool = true
    var yearReleased: String = "2024"
    var seasonCount: Int? = 2
    var hasClosedCaptions: Bool = true
    var isTopTen: Int? = 6
    var description: String? = ""
    var cast: String? = ""
    
    var onPlayPressed: (() -> Void)? = nil;
    var onDownloadPressed: (() -> Void)? = nil;
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 8) {
                if isNew {
                    Text("New")
                        .foregroundStyle(.green)
                }
                Text(yearReleased)
                
                if let seasonCount {
                    Text("\(seasonCount) seasons")
                }
                
                if hasClosedCaptions {
                    Image(systemName: "captions.bubble")
                }
                
                if let isTopTen {
                    HStack(spacing: 8) {
                        topTenIcon
                        Text("#\(isTopTen) in Shows Today")
                            .font(.headline)
                    }
                }
            }
                
                VStack(spacing: 8){
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
                        onPlayPressed?()
                    }
                    
                    HStack {
                        Image(systemName: "arrow.down.to.line.alt")
                        Text("Download")
                    }
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                    .padding(.vertical, 8)
                    .foregroundStyle(.white)
                    .background(.nDarkGray)
                    .cornerRadius(4)
                    .asButton(.press){
                        onDownloadPressed?()
                    }
                }
                .font(.callout)
                .fontWeight(.medium)
            
            Group {
                if let description {
                    Text(description)
                }
                
                if let cast {
                    Text(cast)
                        .foregroundStyle(.nLightGray)
                }
            }
            .font(.callout)
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
                
            
        }
        .foregroundStyle(.white)
    }
    
    private var topTenIcon: some View {
    Rectangle()
        .fill(.nRed)
        .frame(width: 28, height: 28)
        .overlay(
            VStack(spacing: -1) {
                Text("TOP")
                    .fontWeight(.bold)
                    .font(.system(size:8))
                Text("10")
                    .fontWeight(.bold)
                    .font(.system(size:8))
            }
        )
        .offset(y:1)
    }
}

#Preview {
    
    ZStack {
        Color.black.ignoresSafeArea()
        SubDetailsView()
    }
    
}
