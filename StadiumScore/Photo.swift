//
//  Photo.swift
//  StadiumScore
//
//  Created by Carter Zielinski on 4/23/26.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct Photo: Identifiable, Codable {
    @DocumentID var id: String?
    var imageURLString: String = ""
    var description: String = ""
    var reviewer: String = Auth.auth().currentUser?.email ?? ""
    var postedOn: Date = Date()
    
    init(id: String? = nil, imageURLString: String = "", description: String = "", reviewer: String = (Auth.auth().currentUser?.email ?? ""), postedOn: Date = Date()) {
        self.id = id
        self.imageURLString = imageURLString
        self.description = description
        self.reviewer = reviewer
        self.postedOn = postedOn
    }
}

extension Photo {
    static var preview: Photo {
        let newPhoto = Photo(
            id: "1",
            imageURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/9/91/Pizza-3007395.jpg/330px-Pizza-3007395.jpg",
            description: "Yummy Pizza",
            reviewer: "little@caesars.com",
            postedOn: Date()
        )
        return newPhoto
    }
}
