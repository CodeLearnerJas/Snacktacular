//
//  SpotViewModel.swift
//  Snacktacular
//
//  Created by GuitarLearnerJas on 11/10/2024.
//

import Foundation
import FirebaseFirestore


@MainActor
class SpotViewModel: ObservableObject {
    @Published var spot = Spot()
    
    func saveSpot(spot: Spot) async -> Bool {
        let db = Firestore.firestore() //create instance of the database
        
        if let id = spot.id { //spot already exist, do save
            do {
                try await db.collection("spots").document(id).setData(spot.dictionary)
                print("😎 Successfully Saved")
                return true
            } catch {
                print("😡 Changes Not Saved, \(error.localizedDescription)")
                return false
            }
            
        } else { //no id, add new spot
            do{
                try await db.collection("spots").addDocument(data: spot.dictionary)
                print("👍 Successfully Added")
                return true
            } catch {
                print("😡 Content Not Created, \(error.localizedDescription)")
                return false
            }
        }
    }
}
