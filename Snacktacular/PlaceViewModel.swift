//
//  PlaceViewModel.swift
//  PlaceLookup Demo
//
//  Created by GuitarLearnerJas on 16/10/2024.
//

import Foundation
import MapKit
@MainActor
class PlaceViewModel: ObservableObject {
    @Published var places: [Place] = []
    
    func searchPlace(text: String, region: MKCoordinateRegion) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = text
        searchRequest.region = region
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response else {
                print("Error: \(error?.localizedDescription ?? "No response")")
                return
            }
            self.places = response.mapItems.map(Place.init)
        }
    }
    
}

