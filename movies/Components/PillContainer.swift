//
//  PillContainer.swift
//  movies
//
//  Created by Guest User on 22/01/2025.
//

import SwiftUI

struct Filter: Hashable, Equatable {
        let title: String
        let isDropdown: Bool
    
    static var mFitlers: [Filter] = [
        Filter(title: "hello", isDropdown: false),
        Filter(title: "hello2", isDropdown: false),
        Filter(title: "hello3", isDropdown: true)
    ]

}
struct PillContainer: View {
    
    var filters: [Filter];
    
    var selectedFilter: Filter? = nil;
    var onXClicked: (() -> Void)? = nil;
    var onFilterClicked: ((Filter) -> Void)? = nil;
    
    
    var body: some View {
        ScrollView(.horizontal){
            HStack {
                
                if (selectedFilter != nil){
                    Image(systemName: "xmark")
                        .padding(8)
                        .background(Circle()
                            .stroke(lineWidth: 1)
                        ).foregroundStyle(.nLightGray)
                        .onTapGesture {
                            onXClicked?();
                        }
                        .transition(AnyTransition.move(edge: .leading))
                        .padding(.leading, 16)
                }
                
                ForEach(filters, id: \.self){ f in
                    
                    if selectedFilter == nil || selectedFilter == f {
                        FilterPill(
                            title: f.title,
                            isDropdown: f.isDropdown,
                            isSelected: selectedFilter == f
                        )
                        .background(Color.black.opacity(0.001))
                        .onTapGesture {
                            onFilterClicked?(f)
                        }
                        .padding(.leading, ((selectedFilter == nil) && (f == filters.first) ? 16 : 0))
                    }
                    
                }
            }.padding(.vertical, 4)
            
        }
        .scrollIndicators(.hidden)
        .animation(.bouncy, value: selectedFilter)
    }
}


#Preview {
    
    ZStack(alignment: Alignment(horizontal: .center, vertical: .center), content: {
        PillContainer(filters: Filter.mFitlers)
    })
    
}
