//
//  DetailsHeader.swift
//  movies
//
//  Created by Terran Winner on 2/2/25.
//

import SwiftUI
import SwiftfulUI

struct DetailsHeader: View {
    var imageName = "https://picsum.photos/200/300";
    var progress: Double = 0.2
    var onAirPlayPressed: (() -> Void)? = nil
    var onXPressed: (() -> Void)? = nil
    
    var body: some View {
        ZStack (alignment: .bottom){
            ImageView(url: imageName)
            CustomProgressBar(
                selection: progress,
                range: 0...1,
                backgroundColor: .nLightGray,
                foregroundColor: .nRed,
                cornerRadius: 2,
                height: 4
            )
            .padding(.bottom, 4)
            .animation(.linear, value: progress)
            
            HStack(spacing: 8) {
                Circle()
                    .fill(.nDarkGray)
                    .overlay(
                        Image(systemName: "tv.badge.wifi")
                            .offset(y: 1)
                    )
                    .frame(width: 36, height: 36)
                    .onTapGesture {
                        onAirPlayPressed?()
                    }
                
                Circle()
                    .fill(.nDarkGray)
                    .overlay(
                        Image(systemName: "xmark")
                            .offset(y: 1)
                    )
                    .frame(width: 36, height: 36)
                    .onTapGesture {
                        onXPressed?()
                    }
                
            }
            .foregroundStyle(.white)
            .font(.subheadline)
            .fontWeight(.bold)
            .padding(8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        }
        .aspectRatio(2, contentMode: .fit)
    }
}

#Preview {
    DetailsHeader()
}
