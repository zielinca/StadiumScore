//
//  Stadium.swift
//  StadiumScore
//
//  Created by Carter Zielinski on 4/22/26.
//

import Foundation

struct Stadium: Codable, Identifiable {
    var id: String { // MARK: AI Video Explanation
        stadium.replacingOccurrences(of: " ", with: "_")
    }
    var team: String
    var stadium: String
    var latitude: Double
    var longitude: Double
    var capacity: Int
    var opened: Int
    var logo: String
    var stadiumImage: String
    
    enum CodingKeys: String, CodingKey {
        case team
        case stadium
        case latitude
        case longitude
        case capacity
        case opened
        case logo
        case stadiumImage
    }
}
