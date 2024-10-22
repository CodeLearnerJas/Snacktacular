//
//  PhotoView.swift
//  Snacktacular
//
//  Created by GuitarLearnerJas on 22/10/2024.
//

import SwiftUI

struct PhotoView: View {
    var uiImage: UIImage
    var spot: Spot
    @State private var photo = Photo()
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var spotVM : SpotViewModel
    
    var body: some View {
        NavigationStack {
            VStack{
                Spacer()
                
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                
                Spacer()
                
                TextField("Description", text: $photo.description)
                    .textFieldStyle(.roundedBorder)
                
                Text("by: \(photo.reviewer) on: \(photo.postedOn.formatted(date: .numeric, time: .omitted))")
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .automatic) {
                    Button("Save") {
                        Task{
                            //action save
                            let success = await spotVM.saveImage(spot: spot, photo: photo, image: uiImage)
                            if success{
                                dismiss()
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack{
        PhotoView(uiImage: UIImage(named: "pizza") ?? UIImage(), spot: Spot())
            .environmentObject(SpotViewModel())
    }
}
