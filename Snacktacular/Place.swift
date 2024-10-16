//
//  Place.swift
//  PlaceLookup Demo
//
//  Created by GuitarLearnerJas on 16/10/2024.
//

import Foundation
import MapKit
struct Place: Identifiable {
    let id = UUID().uuidString
    private var mapItem: MKMapItem
    
    init(mapItem: MKMapItem) {
        self.mapItem = mapItem
    } //passing in one by one the results in the results array when we put the searchText in the searchField and press Return
    var name: String {
        self.mapItem.name ?? ""
    }
    var address: String {
        let placemark = self.mapItem.placemark
        var cityAndState: String = ""
        var address: String = ""
        
        cityAndState = placemark.locality ?? ""
        if let state = placemark.administrativeArea {
            cityAndState = cityAndState.isEmpty ? state : "\(cityAndState), \(state)"
        }
        address = placemark.subThoroughfare ?? ""
        if let street = placemark.thoroughfare {
            address = address.isEmpty ? street : "\(address) \(street)"
        }
        if address.trimmingCharacters(in: .whitespaces).isEmpty && !cityAndState.isEmpty {
            address = cityAndState
        } else {
            address = cityAndState.isEmpty ? address : "\(address), \(cityAndState)"
        }
        return address
    }
    var latitude: CLLocationDegrees {
        self.mapItem.placemark.coordinate.latitude
    }
    var longitude: CLLocationDegrees {
        self.mapItem.placemark.coordinate.longitude
    }
}
