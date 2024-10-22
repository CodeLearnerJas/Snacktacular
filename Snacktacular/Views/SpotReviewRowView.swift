//
//  ReviewRowView.swift
//  Snacktacular
//
//  Created by GuitarLearnerJas on 20/10/2024.
//

import SwiftUI

struct SpotReviewRowView: View {
    @State var review: Review

    var body: some View {
        VStack(alignment: .leading) {
            Text(review.title)
            HStack{
                StarSelectionView(rating: $review.rating, interactive: false, font: .callout)
                    
                Text(review.body)
                    .font(.callout)
                    .lineLimit(1)
            }
        }
    }
}

#Preview {
    SpotReviewRowView(review: Review(title: "Unbelievable Place", body: "Fantastic Place to vist, just god damn good", rating: 5))
}
