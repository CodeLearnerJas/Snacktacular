//
//  Spot.swift
//  Snacktacular
//
//  Created by GuitarLearnerJas on 11/10/2024.
//

import Foundation
import FirebaseFirestore

struct Spot: Identifiable, Codable {
    @DocumentID var id: String?
    var name = ""
    var address = ""
    var latitude = 0.0
    var longitude = 0.0
    
    var dictionary: [String: Any] {
        return [
            "name": name,
            "address": address,
            "latitude": latitude,
            "longitude": longitude
        ]
    }
}
