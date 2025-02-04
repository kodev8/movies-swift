//
//  BackButton.swift
//  movies
//
//  Created by Terran Winner on 2/3/25.
//

import SwiftUI

struct BackButton: View {
    @Environment(\.router) var router
    var body: some View {
        Button(action: {
            router.dismissScreen()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.white)
        }
        .padding(.leading)
    }
}

#Preview {
    
    ZStack {
        
        Color.black.ignoresSafeArea()
        VStack(alignment: .center, spacing: 0) {
           
            BackButton()
        }
    }
    
  
}
