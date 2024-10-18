//
//  LocationManager.swift
//  PlaceLookup Demo
//
//  Created by GuitarLearnerJas on 16/10/2024.
//

import Foundation
import MapKit

@MainActor
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var location: CLLocation?
    @Published var region = MKCoordinateRegion()
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters //Use 'kCLLocationAccuracyBest' for best result
        locationManager.distanceFilter = 50 //'kCLDistanceFilterNone' any location change will trigger the update
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation() //Remember to update Info.plist
        locationManager.delegate = self
    }
}

extension LocationManager {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        Task{ @MainActor in
            self.location = location
            self.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
        }
    }
}
