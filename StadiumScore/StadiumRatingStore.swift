//
//  StadiumRatingStore.swift
//  StadiumScore
//
//  Created by Carter Zielinski on 4/22/26.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct StadiumRatingStore {
    
    static let db = Firestore.firestore()
    
    // MARK: SAVE
    static func save(
        stadiumId: String,
        hasVisited: Bool,
        location: Double,
        food: Double,
        atmosphere: Double,
        amenities: Double,
        accessibility: Double,
        prepost: Double,
        unique: Double,
        notes: String,
        price: Double,
        lastVisited: Int,
        visitedMultipleTimes: Bool
    ) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ No logged in user")
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(userId)
            .collection("ratings")
            .document(stadiumId)
            .setData([
                "hasVisited": hasVisited,
                "location": location,
                "food": food,
                "atmosphere": atmosphere,
                "amenities": amenities,
                "accessibility": accessibility,
                "prepost": prepost,
                "unique": unique,
                "notes": notes,
                "price": price,
                "lastVisited": lastVisited,
                "visitedMultipleTimes": visitedMultipleTimes
            ], merge: true)
        
        print("✅ Saved rating for stadium:", stadiumId)
    }
    
    // MARK: LOAD
    static func load(
        stadiumId: String,
        completion: @escaping ([String: Any]) -> Void  // ← Any, not Double
    ) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ No logged in user")
            return
        }
        
        db.collection("users")
            .document(userId)
            .collection("ratings")
            .document(stadiumId)
            .getDocument { snapshot, error in
                
                guard let data = snapshot?.data(), error == nil else {
                    completion([:])
                    return
                }
                
                var result: [String: Any] = [:]  // ← Any
                
                result["hasVisited"] = data["hasVisited"] as? Bool ?? false  // ← add this
                result["location"]   = data["location"]   as? Double ?? 0
                result["food"]       = data["food"]        as? Double ?? 0
                result["atmosphere"] = data["atmosphere"]  as? Double ?? 0
                result["amenities"]       = data["amenities"]        as? Double ?? 0
                result["accessibility"]       = data["accessibility"]        as? Double ?? 0
                result["prepost"]    = data["prepost"]     as? Double ?? 0
                result["unique"]     = data["unique"]      as? Double ?? 0
                result["notes"]               = data["notes"]               as? String ?? ""
                result["price"]               = data["price"]               as? Double ?? 0.0
                result["lastVisited"]         = data["lastVisited"]         as? Int    ?? Calendar.current.component(.year, from: Date())
                result["visitedMultipleTimes"] = data["visitedMultipleTimes"] as? Bool ?? false
                
                completion(result)
            }
    }
}
