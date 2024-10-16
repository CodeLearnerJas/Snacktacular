//
//  SpotDetailView.swift
//  Snacktacular
//
//  Created by GuitarLearnerJas on 11/10/2024.
//

import SwiftUI
import MapKit

struct SpotDetailView: View {
    @State var spot: Spot
    @EnvironmentObject var spotVM: SpotViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showPlaceLookupSheet: Bool = false
    @State var returnedPlace = Place(mapItem: MKMapItem())
    
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
