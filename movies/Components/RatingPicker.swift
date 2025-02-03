//
//  RatingPicker.swift
//  movies
//
//  Created by Terran Winner on 2/3/25.
//

import SwiftUI


struct RatingPicker: View {
    @Binding var rating: Int
    let maxRating: Int
    let size: CGFloat
    let spacing: CGFloat
    let color: Color
   
    init(rating: Binding<Int>,
         maxRating: Int = 5,
         size: CGFloat = 24,
         spacing: CGFloat = 4,
         color: Color = .yellow) {
        self._rating = rating
        self.maxRating = maxRating
        self.size = size
        self.spacing = spacing
        self.color = color
    }
   
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(1...maxRating, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .font(.system(size: size))
                    .foregroundColor(color)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            if rating == index {
                                rating = 0  // Allow deselecting
                            } else {
                                rating = index
                            }
                        }
                    }
                    .scaleEffect(rating == index ? 1.1 : 1.0)
            }
        }
    }
}





#Preview {
//    RatingPicker()
}
