//
//  ReviewView.swift
//  Snacktacular
//
//  Created by GuitarLearnerJas on 18/10/2024.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ReviewView: View {
    @StateObject var reviewVM = ReviewViewModel()
    @State var spot: Spot
    @State var review: Review
    @State var rateOrReviewerString: String = "Click to Rate:" //or show reviewer and post date
    @State private var postedByThisUser: Bool = false
    @FocusState private var keyboardActive: Bool
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
            
            Text(rateOrReviewerString)
                .font(postedByThisUser ? .title2 : .subheadline)
                .bold(postedByThisUser)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .padding(.horizontal)
            
            HStack{
                //TODO: Need to fix the star update issue when changing the existing review stars
                StarSelectionView(rating: $review.rating)
                    .disabled(postedByThisUser == false)
                    .overlay{
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray.opacity(0.5), lineWidth: postedByThisUser ? 1.5 : 0)
                    }
            }
            .padding(.bottom)
            
            VStack (alignment: .leading){
                Text("Review Title:")
                    .bold()
                    
                
                TextField("Insert Title", text: $review.title)
                    .padding(.horizontal, 6)
                    .overlay{
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray.opacity(0.5), lineWidth: postedByThisUser ? 1.5 : 0.3)
                    }
                    .focused($keyboardActive)
                    .onSubmit {
                        keyboardActive = false
                    }
                    .submitLabel(.done)
                
                Text("Review:")
                    .bold()
                
                TextField("Ener your review here", text: $review.body, axis: .vertical)
                    .padding(.horizontal, 6)
                    .frame(maxHeight: .infinity, alignment: .topLeading)
                    .overlay{
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.gray.opacity(0.5), lineWidth: postedByThisUser ? 1.5 : 0.3)
                    }
                    .focused($keyboardActive)
                    .submitLabel(.done)
                    .onChange(of: review.body) { //TODO: Works but need to understand the logic
                        if review.body.last?.isNewline == .some(true) {
                            review.body.removeLast()
                            keyboardActive = false
                        }
                    }
            }
            .disabled(postedByThisUser == false)
            .padding(.horizontal)
            .font(.title2)
            
            Spacer()
            
                .toolbar {
                    if postedByThisUser {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
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
                        ToolbarItem(placement: .bottomBar) {
                            HStack{
                                Spacer()
                                Button {
                                    Task{
                                        let success = await reviewVM.deleteReview(spot: spot, review: review)
                                        if success {
                                            dismiss()
                                        } else {
                                            print ("😡 ERROR: deleting data in ReviewView")
                                        }
                                    }
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .padding(.horizontal)
                                .disabled(review.id == nil)
                            }
                        }
                    }
                }
            
        }
        .onAppear{
            if review.reviewer == Auth.auth().currentUser?.email {
                postedByThisUser = true
            } else {
                let reviewDate = review.postedOn.formatted(date: .numeric, time: .omitted)
                rateOrReviewerString = "by \(review.reviewer) on \(reviewDate)"
            }
        }
        .navigationBarBackButtonHidden(postedByThisUser) //hide Back Button if posted by this user
    }
}

#Preview {
    NavigationStack {
        ReviewView(spot: Spot(name: "Shake Shack", address: "49 Bond St, Sydney 2000 NSW"), review: Review())
    }
}
