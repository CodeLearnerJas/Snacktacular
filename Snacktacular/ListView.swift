//
//  ListView.swift
//  Snacktacular
//
//  Created by GuitarLearnerJas on 11/10/2024.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct ListView: View {
    @FirestoreQuery(collectionPath: "spots") var spots: [Spot]
    @Environment(\.dismiss) private var dismiss
    @State private var sheetPresented: Bool = false
    
    var body: some View {
        List(spots) { spot in
            NavigationLink {
                SpotDetailView(spot: spot)
            } label: {
                Text(spot.name)
                    .font(.title2)
            }
        }
            .listStyle(.plain)
            .navigationTitle("Snack Spots")
            .navigationBarBackButtonHidden()
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Sign Out") {
                        do {
                            try Auth.auth().signOut()
                            print("Successfully signed out.")
                            dismiss()
                        } catch {
                            print("Error signing out: \(error.localizedDescription)")
                            return
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        sheetPresented.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $sheetPresented) {
                NavigationStack{
                    SpotDetailView(spot: Spot())
                }
            }
        }
    }


#Preview {
    NavigationStack{
        ListView()
            .environmentObject(SpotViewModel())
    }
}
