//
//  StadiumMapView.swift
//  StadiumScore
//
//  Created by Carter Zielinski on 4/23/26.
//

import SwiftUI
import MapKit

struct StadiumMapView: View {
    let stadiums: [Stadium]
    let stadiumRatings: [String: Double] // TODO: AI explain what this is, and why it is needed

    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 39.5, longitude: -98.35),
            span: MKCoordinateSpan(latitudeDelta: 60, longitudeDelta: 60)
        )
    )

    var body: some View {
        Map(position: $position) {

            ForEach(stadiums) { stadium in
                
                let isVisited = stadiumRatings[stadium.id] != nil
                
                // Annotates Stadium Name, (as you zoom in on closing if multiple stadiums close to each other)
                Annotation(stadium.stadium, coordinate: CLLocationCoordinate2D(
                    latitude: stadium.latitude,
                    longitude: stadium.longitude
                )) {
                    NavigationLink {
                        DetailView(stadium: stadium, onSave: {})
                    } label: {
                        Text("📍")
                            .font(.title)
                            .opacity(isVisited ? 1.0 : 0.5)
                    }
                }
            }
        }
        .navigationTitle("Stadiums Map")
    }
}

#Preview {
    let sampleStadiums = [
        Stadium(
            team: "Atlanta Braves",
            stadium: "Truist Park",
            latitude: 33.8907,
            longitude: -84.4677,
            capacity: 41084,
            opened: 2017,
            logo: "",
            stadiumImage: ""
        ),
        Stadium(
            team: "New York Yankees",
            stadium: "Yankee Stadium",
            latitude: 40.8296,
            longitude: -73.9262,
            capacity: 47309,
            opened: 2009,
            logo: "",
            stadiumImage: ""
        )
    ]
    
        // mock "visited" data
        // Braves = visited
        // Yankees not included = not visited
        let mockRatings: [String: Double] = [
            sampleStadiums[0].id: 8.5
        ]

    NavigationStack {
        StadiumMapView(stadiums: sampleStadiums, stadiumRatings: mockRatings)
    }
}
