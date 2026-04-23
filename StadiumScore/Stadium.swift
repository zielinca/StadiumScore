//
//  Stadium.swift
//  StadiumScore
//
//  Created by Carter Zielinski on 4/22/26.
//

import Foundation

struct Stadium: Codable, Identifiable {
    //    let id = UUID().uuidString
    var id: String {
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
    //TODO: maybe add, city, state
    
    enum CodingKeys: String, CodingKey {
        case team
        case stadium
        case latitude
        case longitude
        case capacity
        case opened
        case logo
        case stadiumImage
        //TODO: maybe add, city, state
    }
}
