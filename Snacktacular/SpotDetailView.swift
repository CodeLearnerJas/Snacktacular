//
//  SpotDetailView.swift
//  Snacktacular
//
//  Created by GuitarLearnerJas on 11/10/2024.
//TODO: Optional: Fix the deprecation on MapAnnotation

import SwiftUI
import MapKit

struct SpotDetailView: View {
    
    struct Annotation: Identifiable { //Hold the id and coordinates before saving to firebase cloud
        let id = UUID().uuidString
        let name: String
        let address: String
        var coordinate: CLLocationCoordinate2D
    }
    @State private var annotations: [Annotation] = []
    @State var spot: Spot
    @EnvironmentObject var spotVM: SpotViewModel
    @EnvironmentObject var locationManager: LocationManager
    @Environment(\.dismiss) private var dismiss
    @State private var mapRegion = MKCoordinateRegion()
    @State private var showPlaceLookupSheet: Bool = false
    let regionSize: CLLocationDistance = 500 //meters, value type has to be double/CL
    
    var body: some View {
        VStack{
            
            Group {
                TextField("Name", text: $spot.name)
                    .font(.title)
                TextField("Address", text: $spot.address)
                    .font(.title2)
            }
            .disabled(spot.id == nil ? false : true)
            .textFieldStyle(.roundedBorder)
            .overlay{
                RoundedRectangle(cornerRadius: 15)
                    .stroke(.gray.opacity(0.5),lineWidth:spot.id == nil ? 2 : 0)
            }
            .padding(.horizontal)
            
            Spacer()
            
            Map(coordinateRegion: $mapRegion, showsUserLocation: true, annotationItems: annotations) { annotation in
                MapAnnotation(coordinate: annotation.coordinate) {}
            }
            .onChange(of: spot) { _, _ in
                annotations = [Annotation(name: spot.name, address: spot.address, coordinate: spot.coordinate)]
                mapRegion.center = spot.coordinate
            }
        }
        .onAppear{               //if data exist, show the data coordinate in the center of the map, else show current location as center
            Task{ @MainActor in
                if spot.id != nil {
                    mapRegion = MKCoordinateRegion(center: spot.coordinate, latitudinalMeters: regionSize, longitudinalMeters: regionSize)
                } else {
                    mapRegion = MKCoordinateRegion(center: locationManager.location?.coordinate ?? CLLocationCoordinate2D(), latitudinalMeters: regionSize, longitudinalMeters: regionSize)
                }
            }
            annotations = [Annotation(name: spot.name, address: spot.address, coordinate: spot.coordinate)]
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(spot.id == nil)
        .toolbar{
            if spot.id == nil {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        Task{
                            let success = await spotVM.saveSpot(spot: spot)
                            if success {
                                dismiss()
                            } else {
                                print("Error saving spot")
                            }
                        }
                        dismiss()
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    HStack{
                        Spacer()
                        Button {
                            showPlaceLookupSheet.toggle()
                        } label: {
                            Image(systemName: "magnifyingglass")
                            Text("Lookup Place")
                        }
                    }
                }
            }
            
        }
        .fullScreenCover(isPresented: $showPlaceLookupSheet) {
            PlaceLookupView(spot: $spot)
        }
    }
}

#Preview {
    SpotDetailView(spot: Spot())
        .environmentObject(SpotViewModel())
        .environmentObject(LocationManager())
}
