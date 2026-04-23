//
//  StadiumViewModel.swift
//  StadiumScore
//
//  Created by Carter Zielinski on 4/22/26.
//

import Foundation
@Observable
@MainActor

class StadiumViewModel {
    private struct Returned: Codable {
        var count: Int
//        var next: String? TODO: check if this is needed
        var results: [Stadium]
    }
    
    var urlString: String { // TODO: AI suggestion, allows me to make changes to the JSON, and then Xcode won't used cached data
        "https://zielinca.github.io/mlb-stadium-api/stadium.json?cacheBust=\(Date().timeIntervalSince1970)"
    }
    var count = 0
    var stadiumsArray: [Stadium] = []
    var isLoading = false
    
    func getData() async {
        print("🕸️ We are accessing the url \(urlString)")
        isLoading = true
        
        // Create a URL
        guard let url = URL(string: urlString) else {
            print("😡 ERROR: Could not create a URL from \(urlString)")
            isLoading = false
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
                        
            // Try to decode JSON data into our own data structures
            guard let returned = try? JSONDecoder().decode(Returned.self, from: data) else {
                print("😡 ERROR: Could not decode returned JSON data")
                isLoading = false
                return
            }
            Task { @MainActor in // Forces update to be in main thread
                self.count = returned.count
                self.stadiumsArray = self.stadiumsArray + returned.results
                isLoading = false
                print("😎 JSON Decoded! urlString: \(urlString), stadiums.count: \(stadiumsArray.count)")
            }
        } catch {
            print("😡 ERROR: Could not get data from \(urlString)")
            isLoading = false
        }
    }
}
