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
