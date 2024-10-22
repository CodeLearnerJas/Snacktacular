//
//  Photo.swift
//  Snacktacular
//
//  Created by GuitarLearnerJas on 21/10/2024.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct Photo: Codable, Identifiable {
    @DocumentID var id: String?
    var imageURLString: String = ""  //used to hold the URL for loading the image
    var description = ""
    var reviewer = Auth.auth().currentUser?.email ?? ""
    var postedOn = Date()
    
    var dictionary: [String: Any] {
        return [
            "imageURLString": imageURLString,
            "description": description,
            "reviewer": reviewer,
            "postedOn": Timestamp(date: Date())
        ]
    }
}
