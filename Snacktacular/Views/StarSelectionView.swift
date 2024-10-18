//
//  StarSelectionView.swift
//  Snacktacular
//
//  Created by GuitarLearnerJas on 18/10/2024.
//

import SwiftUI

struct StarSelectionView: View {
    @State var rating: Int
    let highestRating: Int = 5
    let unselected = Image(systemName: "star")
    let selected = Image(systemName: "star.fill")
    let font: Font = .largeTitle
    let fillColor: Color = .yellow
    let emptyColor: Color = .gray
    
    var body: some View {
        HStack{
            ForEach(1...highestRating, id:\.self) { i in
               (i <= rating ? selected : unselected)
                    .foregroundStyle(i <= rating ? fillColor : emptyColor)
                    .onTapGesture {
                        rating = i
                    }
                    .font(font)
            }
        }
    }
}

#Preview {
    StarSelectionView(rating: 4)
}
