//
//  PlaceLookupView.swift
//  PlaceLookup Demo
//
//  Created by GuitarLearnerJas on 16/10/2024.
//

import SwiftUI
import MapKit

struct PlaceLookupView: View {
    @State private var searchText = ""
    @StateObject var placeVM = PlaceViewModel()
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var locationManager: LocationManager
    @Binding var spot : Spot
    
    var body: some View {
        NavigationStack{
            List(placeVM.places) { place in
                VStack(alignment: .leading) {
                    Text(place.name)
                        .font(.title2)
                    Text(place.address)
                        .font(.title2)
                }
                .onTapGesture {
                    spot.name = place.name
                    spot.address = place.address
                    spot.latitude = place.latitude
                    spot.longitude = place.longitude
                    dismiss()
                }
            }
            .listStyle(.plain)
            .searchable(text: $searchText)
            .onChange(of: searchText) { _, text in
                if !text.isEmpty {
                    placeVM.searchPlace(text: text, region: locationManager.region)
                } else {
                    placeVM.places = []
                }
            }
            .toolbar{
                ToolbarItem(placement: .automatic) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    PlaceLookupView(spot: .constant(Spot()))
        .environmentObject(LocationManager())
}
