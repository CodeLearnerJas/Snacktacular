//
//  SpotViewModel.swift
//  Snacktacular
//
//  Created by GuitarLearnerJas on 11/10/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import UIKit

@MainActor
class SpotViewModel: ObservableObject {
    @Published var spot = Spot() //<- this is self.spot
    
    func saveSpot(spot: Spot) async -> Bool { // the 'spot' here is the right one in 'self.spot = spot', constant
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
                let documentRef = try await db.collection("spots").addDocument(data: spot.dictionary)
                self.spot = spot //the constant spot value is the latest spot update to be updated
                self.spot.id = documentRef.documentID
                print("👍 Successfully Added")
                return true
            } catch {
                print("😡 Content Not Created, \(error.localizedDescription)")
                return false
            }
        }
    }
    
    func saveImage(spot: Spot, photo: Photo, image: UIImage) async -> Bool {
        guard let spotID = spot.id else {
            print("ERROR: No ID")
            return false }
        
        var photoName = UUID().uuidString //This will be the name of the image file
        if photo.id != nil {
            photoName = photo.id! //if photo id already exist, use it as the photoName. This happens if we are updating an existing photo's descriptive info. It will resave the photo and overwrite the existing one.
        }
        let storage = Storage.storage() //initialize the storage
        let storageRef = storage.reference().child("\(spotID)/\(photoName).jpeg")
        
        guard let resizedImage = image.jpegData(compressionQuality: 0.2) else {
            print("Error: Could not resize image")
            return false
        }
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg" //Setting metadata allows you to see console image in the web browser. This will also work for png
        
        var imageURLString = "" //set this after the image is successfully saved
        
        do {
            let _ = try await storageRef.putDataAsync(resizedImage, metadata: metadata)
            print("😎 Successfully Saved Image")
            do {
                let imageURL = try await storageRef.downloadURL()
                imageURLString = "\(imageURL)" //Save this to Cloud Firestore as part of document in 'photos' collection
            } catch {
                print("😡 ERROR: Getting download URL, \(error.localizedDescription)")
                return false
            }
        } catch {
            print("😡 ERROR: uploading image to FirebaseStorage, \(error.localizedDescription)")
            return false
        }
        
        //Now save to the "photos" collection of the spot document "spotID"
        let db = Firestore.firestore()
        let collectionString = "spots/\(spotID)/photos"
        
        do {
            var newPhoto = photo
            newPhoto.imageURLString = imageURLString
            try await db.collection(collectionString).document(photoName).setData(newPhoto.dictionary) //already have document, so using setData instead of addDocument
            print("😎 Data updated successfully")
            return true
        } catch {
            print("😡 ERROR: could not update data in 'photos' for spotID \(spotID)")
            return false
        }
    }
}

