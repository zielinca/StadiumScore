//
//  StadiumListView.swift
//  StadiumScore
//
//  Created by Carter Zielinski on 4/22/26.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

//TODO: need to fix launchscreen
//TODO: add a toolbar to open a map view (?) see Sutt's app

struct StadiumListView: View {
    @State private var stadiumViewModel = StadiumViewModel()
    @State private var stadiumRatings: [String: Double] = [:] // TODO: used AI here, is this a dictionary?
    @Environment(\.dismiss) private var dismiss
    var visitedStadiums: [Stadium] {
        stadiumViewModel.stadiumsArray
            .filter { stadiumRatings[$0.id] != nil }
            .sorted {
                (stadiumRatings[$0.id] ?? 0) > (stadiumRatings[$1.id] ?? 0)
            }
    }
    
    var notVisitedStadiums: [Stadium] {
        stadiumViewModel.stadiumsArray
            .filter { stadiumRatings[$0.id] == nil }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    if !visitedStadiums.isEmpty {
                        Section("Visited (\(visitedStadiums.count))") {
                            ForEach(visitedStadiums) { stadium in
                                let rank = rankForStadium(stadium, in: visitedStadiums)
                                
                                NavigationLink {
                                    DetailView(stadium: stadium, onSave: loadVisitedStadiums)
                                } label: {
                                    stadiumRow(stadium: stadium, rank: rank)
                                }
                            }
                        }
                    }
                    
                    Section("Not Visited (\(notVisitedStadiums.count))") {
                        ForEach(notVisitedStadiums) { stadium in
                            NavigationLink {
                                DetailView(stadium: stadium, onSave: loadVisitedStadiums) // TODO: AI added the onSave
                            } label: {
                                stadiumRow(stadium: stadium)
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .navigationTitle("MLB Stadiums")
                .navigationSubtitle("As of 2026 Season")
                if stadiumViewModel.isLoading {
                    ProgressView()
                        .tint(.red)
                        .scaleEffect(4)
                }
            }
            .toolbar{
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Sign Out") {
                        do {
                            try Auth.auth().signOut()
                            print("🪵➡️ Log out successful!")
                            dismiss()
                        } catch {
                            print("😡 ERROR: Could not sign out!")
                        }
                    }
                }
            }
        }
        .task {
            await stadiumViewModel.getData()
            loadVisitedStadiums()
        }
        .onAppear {
            loadVisitedStadiums() // TODO: check if needed / treatment
        }
    }
    
    func loadVisitedStadiums() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore() // TODO: explain by AI!
            .collection("users")
            .document(userId)
            .collection("ratings")
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents, error == nil else {return}
                
                var tempRatings: [String: Double] = [:] // TODO: ai explain!
                
                for doc in docs { // TODO: ai explain!
                    let data = doc.data()
                    let hasVisited = data["hasVisited"] as? Bool ?? false
                    
                    if hasVisited {
                        let atmosphere = data["atmosphere"] as? Double ?? 0
                        let amenities = data["amenities"] as? Double ?? 0
                        let unique = data["unique"] as? Double ?? 0
                        let location = data["location"] as? Double ?? 0
                        let food = data["food"] as? Double ?? 0
                        let prepost = data["prepost"] as? Double ?? 0
                        let accessibility = data["accessibility"] as? Double ?? 0

                        let total =
                            atmosphere +
                            amenities +
                            unique +
                            location +
                            food +
                            prepost +
                            accessibility

                        let avg = total / 5.0

                        tempRatings[doc.documentID] = avg
                    }
                }
                
                DispatchQueue.main.async {
                    self.stadiumRatings = tempRatings
                }
            }
    }
    
    func rankForStadium(_ stadium: Stadium, in sorted: [Stadium]) -> Int { // TODO: need to understand what is happening here! AI logic!
        guard let currentRating = stadiumRatings[stadium.id] else { return 0 }
        
        // Count how many stadiums have a strictly higher rating
        let higherCount = sorted.filter {
            (stadiumRatings[$0.id] ?? 0) > currentRating
        }.count
        
        return higherCount + 1
    }
    
    @ViewBuilder // TODO: used AI, check if @ViewBuilder needed, explain how I learned this / what it taught
    func stadiumRow(stadium: Stadium, rank: Int? = nil) -> some View {
        HStack {
            AsyncImage(url: URL(string: stadium.logo)) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
            } placeholder: {
                ProgressView()
                    .frame(width: 40, height: 40)
            }
            Text(stadium.stadium)
                .font(.title2)
            
            Spacer()
            
            HStack(spacing: 8){
                if let rank = rank {
                    Text(rankText(rank: rank, stadium: stadium))
                        .font(.headline)
                        .frame(width: 30, alignment: .center)
                }
                
                if let rating = stadiumRatings[stadium.id] {
                    Text(String(format: "%.1f", rating))
                        .foregroundColor(.secondary)
                        .frame(width: 40, alignment: .trailing)
                }
            }
        }
        .minimumScaleFactor(0.5)
        .multilineTextAlignment(.leading)
    }
    
    func rankText(rank: Int, stadium: Stadium) -> String { // TODO: changed this to have tie logic, make sure it functions properly and makes sense!
        let currentRating = stadiumRatings[stadium.id] ?? 0
        
        // Count how many have SAME rating
        let tieCount = stadiumRatings.values.filter { $0 == currentRating }.count
        
        if tieCount > 1 {
            switch rank {
            case 1: return "🥇"
            case 2: return "🥈"
            case 3: return "🥉"
            default: return "T\(rank)"
            }
        } else {
            switch rank {
            case 1: return "🥇"
            case 2: return "🥈"
            case 3: return "🥉"
            default: return "\(rank)"
            }
        }
    }
}

#Preview {
    StadiumListView()
}
