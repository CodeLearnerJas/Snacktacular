//
//  SpotDetailPhotosScrollView.swift
//  Snacktacular
//
//  Created by GuitarLearnerJas on 23/10/2024.
//

import SwiftUI

struct SpotDetailPhotosScrollView: View {

    var photos: [Photo]
    var spot: Spot
    @State private var showLargeImage: Bool = false
    @State private var uiImage = UIImage()
    @State var selectedPhoto = Photo()
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack (spacing: 3){
                ForEach(photos) { photo in
                    let imageURL = URL(string: photo.imageURLString) ?? URL(string: "")
                    
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .frame(width: 80, height: 80)
                            .scaledToFill()
                            .clipped()
                            .onTapGesture {
                                //convert swiftUIimage to UIImage
                                let render = ImageRenderer(content: image)
                                selectedPhoto = photo
                                uiImage = render.uiImage ?? UIImage()
                                showLargeImage.toggle()
                            }
                    } placeholder: {
                        ProgressView()
                            .frame(width: 80, height: 80)
                    }
                    
                }
            }
        }
        .frame(height: 80)
        .padding(.horizontal, 4)
        .sheet(isPresented: $showLargeImage) {
            PhotoView(uiImage: uiImage, spot: spot, photo: $selectedPhoto)
        }
    }
}

#Preview {
    SpotDetailPhotosScrollView(photos: [Photo(imageURLString: "https://firebasestorage.googleapis.com:443/v0/b/snacktacular-6501a.appspot.com/o/JVPLOyJa2fvuAZK2SIvs%2F7806999D-5543-4AA9-9B4B-ACBBE770D850.jpeg?alt=media&token=4e413197-0c5e-4296-8d7e-0de2689e91d7")], spot: Spot(id: "JVPLOyJa2fvuAZK2SIvs"))
}
