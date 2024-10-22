//
//  SpotDetailView.swift
//  Snacktacular
//
//  Created by GuitarLearnerJas on 11/10/2024.


import SwiftUI
import MapKit
import FirebaseFirestore
import PhotosUI

struct SpotDetailView: View {
    enum ButtonPressed {
        case review, photo
    }
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
    @State private var showSaveAlert: Bool = false
    @State private var showingAsSheet: Bool = false
    @State private var showPhotoSheet: Bool = false
    @State private var buttonPressed = ButtonPressed.review
    @State private var uiImageSelected = UIImage()
    @State private var annotations: [Annotation] = []
    @State private var mapRegion = MKCoordinateRegion()
    @State private var selectedPhoto: PhotosPickerItem?
    let regionSize: CLLocationDistance = 500 //meters, value type has to be double/CL
    var previewRunning: Bool = false
    var avgRating: String {
        guard reviews.count > 0 else { 
            return "-.-"
        }
        let avgStar = Double(reviews.reduce(0) { $0 + $1.rating }) / Double(reviews.count)
        return String(format: "%.1f", avgStar)
    }
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
            
            HStack{
                Group {
                    Text("Avg. Rating:")
                        .font(.title2)
                        .bold()
                    Text(avgRating)
                        .font(.title)
                        .fontWeight(.black)
                        .foregroundStyle(.snack)
                }
                .lineLimit(1)
                .minimumScaleFactor(0.4)
                Spacer()
                Group {
                    PhotosPicker(selection: $selectedPhoto, matching: .images, preferredItemEncoding: .automatic) {
                        Image(systemName: "photo")
                        Text("Photo")
                            .font(.caption)
                    }
                    .onChange(of: selectedPhoto) { _, newValue in
                        //convert the image to UIImage
                        Task{
                            do {
                                if let data = try await newValue?.loadTransferable(type: Data.self) {
                                    if let uiImage = UIImage(data: data) {
                                        uiImageSelected = uiImage
                                        print("Successfully saved image")
                                        buttonPressed = .photo
                                        if spot.id == nil {
                                            showSaveAlert.toggle()
                                        } else {
                                            showPhotoSheet.toggle()
                                        }
                                    }
                                }
                            } catch {
                                print("Error saving image: \(error.localizedDescription)")
                            }
                        }
                    }
                    
                    Button {
                        buttonPressed = .review
                        if spot.id == nil {
                            showSaveAlert.toggle()
                        } else {
                            showReviewSheet.toggle()
                        }
                    } label: {
                        Image(systemName: "star.fill")
                        Text("Rate")
                    }
                }
                .font(Font.caption)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .buttonStyle(.borderedProminent)
                .bold()
                .tint(.snack)
            }
            .padding(.horizontal)
            
            List{
                Section {
                    ForEach(reviews) { review in
                        NavigationLink {
                            ReviewView(spot: spot, review: review)
                        } label: {
                            SpotReviewRowView(review: review)
                        }
                    }
                }
            }
            .listStyle(.plain)
            
            Spacer()
        }
        .onAppear {
            if !previewRunning && spot.id != nil {
                $reviews.path = "spots/\(spot.id ?? "")/reviews"
                print("reviews.path = \($reviews.path)")
            } else { //spot.id starts out as nil
                showingAsSheet = true
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
            if showingAsSheet{//new spot show cancel
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
        }
        .sheet(isPresented: $showPlaceLookupSheet) {
            PlaceLookupView(spot: $spot)
        }
        .sheet(isPresented: $showReviewSheet) {
            NavigationStack{
                ReviewView(spot: spot, review: Review() ) //use Review() for new sheet
            }
        }
        .sheet(isPresented: $showPhotoSheet) {
            NavigationStack{
                PhotoView(uiImage: uiImageSelected, spot: spot)
            }
        }
        
        .alert("Require Save before Rating", isPresented: $showSaveAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Save", role: .none) {
                Task{
                    let success = await spotVM.saveSpot(spot: spot)
                    spot = spotVM.spot
                    if success {
                        //if we didnt update the path after saving spot, we wouldnt be able to show new reviews added
                        $reviews.path = "spots/\(spot.id ?? "")/reviews" //reset the path using newly created id
                        //TODO: Add photos
                        //$photos.path = "spots/\(spot.id ?? "")/photos"
                        
                        switch buttonPressed {
                        case .review:
                            showReviewSheet.toggle()
                        case .photo:
                            showPhotoSheet.toggle()
                        }
                        
                    } else {
                        print("ERROR saving spot!")
                    }
                }
            }
        } message: {
            Text("Please save your spot before rating")
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
