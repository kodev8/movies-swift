//
//  FilterPill.swift
//  movies
//
//  Created by Guest User on 15/01/2025.
//

import SwiftUI

struct FilterPill: View {
    var title: String = "cat";
    var isDropdown: Bool = false
    var isSelected: Bool = false
    var body: some View {
        HStack(spacing: 4) {
            Text(title)
            if (isDropdown) {
                Image(systemName: "chevron.down")
            }
                
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            ZStack {
                
                Capsule(style:.circular)
                    .fill(.gray)
                    .opacity(isSelected ? 1 : 0)
                
                Capsule(style:.circular)
                    .stroke(lineWidth: 1)
                }
        )
        .foregroundStyle(.nLightGray)
        
    }
}

#Preview {
    
    ZStack {
        
        Color.black.ignoresSafeArea()
        
        VStack {
            FilterPill()
            FilterPill(isSelected: true)
            FilterPill(isDropdown: true)
            
        }
    }
}
