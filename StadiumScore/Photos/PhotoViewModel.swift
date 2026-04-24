//
//  PhotoViewModel.swift
//  StadiumScore
//
//  Created by Carter Zielinski on 4/23/26.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

class PhotoViewModel {

    static func saveImage(stadiumId: String, photo: Photo, data: Data) async {

        let photoId = photo.id ?? UUID().uuidString

        let storage = Storage.storage().reference()
        let path = "\(stadiumId)/\(photoId)"
        let imageRef = storage.child(path)

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        do {
            _ = try await imageRef.putDataAsync(data, metadata: metadata)

            guard let url = try? await imageRef.downloadURL() else { return }

            let updatedPhoto = Photo(
                id: photoId,
                imageURLString: url.absoluteString,
                description: photo.description,
                reviewer: photo.reviewer,
                postedOn: photo.postedOn
            )

            let db = Firestore.firestore()
            guard let userId = Auth.auth().currentUser?.uid else { return }

            try db.collection("users")
                .document(userId)
                .collection("ratings")
                .document(stadiumId)
                .collection("photos")
                .document(photoId)
                .setData(from: updatedPhoto)

        } catch {
            print("❌ Photo save error: \(error)")
        }
    }

    static func loadPhotos(stadiumId: String, completion: @escaping ([Photo]) -> Void) {

        guard let userId = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("ratings")
            .document(stadiumId)
            .collection("photos")
            .getDocuments { snapshot, error in

                guard let docs = snapshot?.documents else {
                    completion([])
                    return
                }

                Task { @MainActor in
                    let photos: [Photo] = docs.compactMap { doc in
                        try? doc.data(as: Photo.self)
                    }
                    completion(photos)
                }
            }
    }
    
    static func deletePhoto(stadiumId: String, photo: Photo) async {
        guard let userId = Auth.auth().currentUser?.uid,
              let photoId = photo.id else { return }

        let db = Firestore.firestore()
        let storage = Storage.storage().reference()

        do {
            // delete from Firestore
            try await db.collection("users")
                .document(userId)
                .collection("ratings")
                .document(stadiumId)
                .collection("photos")
                .document(photoId)
                .delete()

            // delete from Storage
            let path = "\(stadiumId)/\(photoId)"
            try await storage.child(path).delete()

        } catch {
            print("❌ Delete photo error: \(error)")
        }
    }
    
    static func deleteAllPhotos(stadiumId: String) async {
        // do this when user untoggles hasVisited; resets entire Stadium DetailView
        
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        let storage = Storage.storage().reference()

        let collectionRef = db.collection("users")
            .document(userId)
            .collection("ratings")
            .document(stadiumId)
            .collection("photos")

        do {
            let snapshot = try await collectionRef.getDocuments()

            for doc in snapshot.documents {
                let photoId = doc.documentID

                // delete firestore doc
                try await collectionRef.document(photoId).delete()

                // delete storage image
                try await storage.child("\(stadiumId)/\(photoId)").delete()
            }

        } catch {
            print("❌ Delete all photos error: \(error)")
        }
    }
}
