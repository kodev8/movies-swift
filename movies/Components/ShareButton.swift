//
//  ShareButton.swift
//  movies
//
//  Created by Terran Winner on 2/2/25.
//

import SwiftUI

struct ShareButton: View {
    
    var url: String  = "https://google.com"
    
    var body: some View {
        if let url = URL(string: url) {
            ShareLink(item: url) {
                VStack(spacing: 8) {
                    
                    Image(systemName: "paperplane")
                        .font(.title)
                    
                    
                    Text("Share")
                        .font(.caption)
                        .foregroundStyle(.nLightGray)
                    
                }
                .foregroundStyle(.white)
                .padding(8)
                .background(Color.black.opacity(0.001))
            }
        }
    }
}

#Preview {
    
    ZStack {
        Color.black.ignoresSafeArea()
        ShareButton()
    }
    
}
