//
//  PhotoView.swift
//  Snacktacular
//
//  Created by GuitarLearnerJas on 22/10/2024.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct PhotoView: View {
    var uiImage: UIImage
    var spot: Spot
    @Binding var photo: Photo //if use @State, the photo become Local, any change will remain inside PhotoView
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
                    .disabled(Auth.auth().currentUser?.email != photo.reviewer) //if the current user is not the one who posted, disable the description to become non-editable
                
                Text("by: \(photo.reviewer) on: \(photo.postedOn.formatted(date: .numeric, time: .omitted))")
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .padding()
            .toolbar {
                if Auth.auth().currentUser?.email == photo.reviewer {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .automatic) {
                        Button("Save") {
                            Task{
                                let success = await spotVM.saveImage(spot: spot, photo: photo, image: uiImage)
                                if success{
                                    dismiss()
                                }
                            }
                        }
                    }
                } else {
                    ToolbarItem(placement: .automatic) {
                        Button("Back") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack{
        PhotoView(uiImage: UIImage(named: "pizza") ?? UIImage(), spot: Spot(), photo: .constant(Photo()))
            .environmentObject(SpotViewModel())
    }
}
