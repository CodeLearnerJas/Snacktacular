//
//  ReviewViewModel.swift
//  Snacktacular
//
//  Created by GuitarLearnerJas on 18/10/2024.
//

import Foundation
import FirebaseFirestore


class ReviewViewModel: ObservableObject {
    @Published var review = Review()
    
    func saveReview(spot: Spot, review: Review) async -> Bool {
        let db = Firestore.firestore() //create instance of the database
        
        guard let spotID = spot.id else {
            print("😎 ERROR: spot.id = nil")
            return false
        }
        
        let collectionString = "spots/\(spotID)/reviews"
        
        if let id = review.id { //review already exist, do save
            do {
                try await db.collection(collectionString).document(id).setData(review.dictionary)
                print("😎 Successfully Saved")
                return true
            } catch {
                print("😡 Changes Not Saved in Review, \(error.localizedDescription)")
                return false
            }
            
        } else { //no id, new review to be added
            do{
                _ = try await db.collection(collectionString).addDocument(data: review.dictionary)
                print("👍 Successfully Added")
                return true
            } catch {
                print("😡 ERROR: Review Not Created, \(error.localizedDescription)")
                return false
            }
        }
    }
}
