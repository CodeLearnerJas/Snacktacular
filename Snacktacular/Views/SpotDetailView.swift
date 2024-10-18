//
//  SpotDetailView.swift
//  Snacktacular
//
//  Created by GuitarLearnerJas on 11/10/2024.


import SwiftUI
import MapKit
import FirebaseFirestore

struct SpotDetailView: View {
    
    struct Annotation: Identifiable { //Hold the id and coordinates before saving to firebase cloud
        let id = UUID().uuidString
        let name: String
        let address: String
        var coordinate: CLLocationCoordinate2D
    }
    @EnvironmentObject var spotVM: SpotViewModel
    @EnvironmentObject var locationManager: LocationManager
    //'spots' isnt the right path for the data, will direct in onAppear instead
    @FirestoreQuery(collectionPath: "spots") var reviews: [Review]
    @State var spot: Spot
    @State private var showPlaceLookupSheet: Bool = false
    @State private var showReviewSheet: Bool = false
    @State private var annotations: [Annotation] = []
    @State private var mapRegion = MKCoordinateRegion()
    let regionSize: CLLocationDistance = 500 //meters, value type has to be double/CL
    var previewRunning: Bool = false
    @Environment(\.dismiss) private var dismiss
    
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
                    .stroke(.gray.opacity(0.5),lineWidth: spot.id == nil ? 2 : 0)
            }
            .padding(.horizontal)
            
            
            Map(coordinateRegion: $mapRegion, showsUserLocation: true, annotationItems: annotations) { annotation in
                MapMarker(coordinate: annotation.coordinate)
            }
            //TODO: Optional: Fix the deprecation on MapAnnotation
            .frame(height: 250)
            .onChange(of: spot) { _, _ in
                annotations = [Annotation(name: spot.name, address: spot.address, coordinate: spot.coordinate)]
                mapRegion.center = spot.coordinate
            }
            
            List{
                Section {
                    ForEach(reviews) { review in
                        NavigationLink {
                            ReviewView(spot: spot, review: review)
                        } label: {
                            Text(review.title) //TODO: Build a custom cell showing stars, title and body
                        }
                    }
                } header: {
                    HStack{
                        Text("Average Rating:")
                            .font(.title2)
                            .bold()
                        Text("4.5") //TODO: changed to computed property
                            .font(.title)
                            .fontWeight(.black)
                            .foregroundStyle(.snack)
                        Spacer()
                        Button("Rate It") {
                            showReviewSheet.toggle()
                        }
                        .buttonStyle(.borderedProminent)
                        .bold()
                        .tint(.snack)
                    }
                }
                .headerProminence(.increased)
            }
            .listStyle(.plain)
            
            Spacer()
        }
        .onAppear {
            if !previewRunning && spot.id != nil {
                $reviews.path = "spots/\(spot.id ?? "")/reviews"
                print("reviews.path = \($reviews.path)")
            } else { //spot.id starts out as nil
                print("Invalid spot ID: Cannot fetch reviews.")
            }
        
        if spot.id != nil { //If spot exist, use that to get the center
            mapRegion = MKCoordinateRegion(center: spot.coordinate, latitudinalMeters: regionSize, longitudinalMeters: regionSize)
        } else { // otherwise use the default center
            Task{
                mapRegion = MKCoordinateRegion(center: locationManager.location?.coordinate ?? CLLocationCoordinate2D(), latitudinalMeters: regionSize, longitudinalMeters: regionSize)
            }
        }
            annotations = [Annotation(name: spot.name, address: spot.address, coordinate: spot.coordinate)]
    }
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarBackButtonHidden(spot.id == nil)
    .toolbar{
        if spot.id == nil { //new spot
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
        } else {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
    .sheet(isPresented: $showPlaceLookupSheet) {
        PlaceLookupView(spot: $spot)
    }
    .sheet(isPresented: $showReviewSheet) {
        NavigationStack{
            ReviewView(spot: spot, review: Review() ) //use Review() for new sheet
        }
    }
}
}

#Preview {
    NavigationStack{
        SpotDetailView(spot: Spot(), previewRunning: true)
            .environmentObject(SpotViewModel())
            .environmentObject(LocationManager())
    }
}
