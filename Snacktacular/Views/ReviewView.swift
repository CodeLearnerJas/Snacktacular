//
//  ReviewView.swift
//  Snacktacular
//
//  Created by GuitarLearnerJas on 18/10/2024.
//

import SwiftUI
import FirebaseFirestore

struct ReviewView: View {
    @StateObject var reviewVM = ReviewViewModel()
    @State var spot: Spot
    @State var review: Review
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack{
            VStack(alignment: .leading) {
                Text(spot.name)
                    .font(.title)
                    .bold()
                    .lineLimit(1)
                
                Text(spot.address)
                    .padding(.bottom)
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Click to Rate:")
                .font(.title2)
                .bold()
            
            HStack{
                StarSelectionView(rating: review.rating)
            }
            .padding(.bottom)
            
            VStack (alignment: .leading){
                Text("Review Title:")
                    .bold()
                
                TextField("Insert Title", text: $review.title)
                    .textFieldStyle(.roundedBorder)
                    .overlay{
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    }
                
                Text("Review:")
                    .bold()
                
                TextField("Ener your review here", text: $review.body, axis: .vertical)
                    .padding(.horizontal, 6)
                    .frame(maxHeight: .infinity, alignment: .topLeading)
                    .overlay{
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.gray.opacity(0.5), lineWidth: 1)
                    }
            }
            .padding(.horizontal)
            .font(.title2)
            
            Spacer()
            
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Save") {
                            Task{
                                let success = await reviewVM.saveReview(spot: spot, review: review)
                                if success {
                                    dismiss()
                                } else {
                                    print("😡 ERROR: saving data in ReviewView")
                                }
                            }
                        }
                    }
                }
            
        }
    }
}

#Preview {
    NavigationStack {
        ReviewView(spot: Spot(name: "Shake Shack", address: "49 Bond St, Sydney 2000 NSW"), review: Review())
    }
}
