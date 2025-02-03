//
//  ViewExtensions.swift
//  movies
//
//  Created by Terran Winner on 2/2/25.
//

import SwiftUI


extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
       
        ZStack(alignment: alignment) {
            placeholder()
                .opacity(shouldShow ? 1 : 0)
                .padding(.leading, 8)
            self
        }
    }
}


struct DarkTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.gray.opacity(0.3))
            .foregroundColor(.white)
            .cornerRadius(4)
            .tint(.white)
            .accentColor(.white)
            .textInputAutocapitalization(.never)
    }
}
