//
//  StarSelectionView.swift
//  Snacktacular
//
//  Created by GuitarLearnerJas on 18/10/2024.
//

import SwiftUI

struct StarSelectionView: View {

    @Binding var rating: Int
    @State var interactive = true //used to control whether the user are able to modify the stars
    let highestRating: Int = 5
    let unselected = Image(systemName: "star")
    let selected = Image(systemName: "star.fill")
    var font: Font = .largeTitle
    let fillColor: Color = .yellow
    let emptyColor: Color = .gray
    
    var body: some View {
        HStack{
            ForEach(1...highestRating, id:\.self) { i in
                (i <= rating ? selected : unselected)
                    .foregroundStyle(i <= rating ? fillColor : emptyColor)
                    .onTapGesture {
                        if interactive{
                            rating = i
                        } //only when it is allowed to modify
                    }
                    .font(font)
            }
        }
    }
}

#Preview {
    StarSelectionView(rating: .constant(4))
}
