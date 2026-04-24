//
//  DetailView.swift
//  StadiumScore
//
//  Created by Carter Zielinski on 4/22/26.
//

import SwiftUI
import PhotosUI

struct DetailView: View {
    let stadium: Stadium
    let onSave: () -> Void // TODO: AI added
    @State private var hasVisited = false
    @Environment(\.dismiss) private var dismiss
    
    // Slider Ratings
    @State private var locationRating: Double = 0
    @State private var foodRating: Double = 0
    @State private var atmosphereRating: Double = 0
    @State private var amenityRating: Double = 0
    @State private var prepostRating: Double = 0
    @State private var accessibilityRating: Double = 0
    @State private var uniqueRating: Double = 0
    
    // Additional Information Variables
    @State private var notes: String = ""
    @State private var price: Double = 0.0
    @State private var lastVisited: Int = Calendar.current.component(.year, from: Date())
    @State private var visitedMultipleTimes: Bool = false
    
    @State private var originalRatingsLoaded = false
    
    // Overall Rating Variable (if user hasVisited)
    var overallRating: Double? {
        guard hasVisited else { return nil }
        
        return (locationRating + foodRating + atmosphereRating + amenityRating + prepostRating + uniqueRating + accessibilityRating) / 5.0
    }
    
    // Photo Variables
    @State private var photos: [Photo] = []
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var photoPickerPresented = false
    
    var body: some View {
        ScrollView {
            VStack {
                // MARK: Stadium Image
                AsyncImage(url: URL(string: stadium.stadiumImage)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 220)
                        .clipped()
                        .cornerRadius(16)
                        .padding(.horizontal)
                } placeholder: {
                    ProgressView()
                        .frame(height: 220)
                        .tint(.red)
                }
                
                // MARK: Stadium Name
                Text(stadium.stadium)
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 8)
                
                // MARK: Subheader
                Text("Home of the")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                // MARK: Team Section (Logo & Team Name)
                HStack{
                    VStack {
                        AsyncImage(url: URL(string: stadium.logo)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                        } placeholder: {
                            ProgressView()
                                .frame(width: 100, height: 100)
                                .tint(.red)
                        }
                        Text(stadium.team)
                            .font(.title2)
                            .bold()
                            .padding(.bottom, 8)
                    }
                }
                
                // MARK: Stadium Info Section
                VStack(spacing: 6) {
                    Text("Opened: \(String(stadium.opened))")
                    Text("Capacity: \(stadium.capacity)")
                    Text("\(stadium.latitude), \(stadium.longitude)")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                
                Divider()
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                // MARK: Toggle (Yes/No) Attendance Section
                HStack (spacing: 4) {
                    Text("Have you attended \n\(stadium.stadium)?")
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                    
                    Picker("", selection: $hasVisited) {
                        Text("No").tag(false)
                        Text("Yes").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 120)
                }
                .padding(.horizontal, 25)
                .padding(.vertical, 8)
                
                // MARK: Ratings IF hasVisited == true
                if hasVisited {
                    Divider()
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                    
                    Text("Your Ratings")
                        .font(.title)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    
                    // MARK: Ratings!
                    VStack(spacing: 16) {
                        ratingRow(title: "Atmosphere (0–10)", value: $atmosphereRating)
                        ratingRow(title: "Stadium Amenities (0–10)", value: $amenityRating)
                        ratingRow(title: "Overall Uniqueness (0–10)", value: $uniqueRating)
                        ratingRow(title: "Surrounding Area (0–5)", value: $locationRating, maxValue: 5)
                        ratingRow(title: "Food / Drink (0–5)", value: $foodRating, maxValue: 5)
                        ratingRow(title: "Pregame / Postgame Activities (0–5)", value: $prepostRating, maxValue: 5)
                        ratingRow(title: "Accessibility (0–5)", value: $accessibilityRating, maxValue: 5)
                    }
                    .padding(.horizontal)
                }
                
                // MARK: Overall Rating
                if hasVisited, let rating = overallRating {
                    VStack(spacing: 6) {
                        Text("Overall Rating")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(String(format: "%.1f", rating))
                            .font(.system(size: 48, weight: .bold))
                    }
                    
                    Divider()
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                    
                    // MARK: Additional Info IF hasVisited == true
                    Text("Additional Info")
                        .font(.title)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    
                    VStack(spacing: 20) {
                        
                        HStack {
                            Text("Your Experience")
                                .font(.headline)
                            
                            Spacer()
                            
                            TextField("Your thoughts...", text: $notes, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                                .lineLimit(3)
                        }
                        
                        HStack {
                            Text("Estimated Cost of Experience")
                                .font(.headline)
                            
                            Spacer()
                            
                            TextField("", value: $price, format: .currency(code: "USD"))
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                                .frame(width: 100)
                        }
                        HStack {
                            Text("Attended Multiple Games?")
                                .font(.headline)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                            
                            Spacer()
                            
                            Picker("", selection: $visitedMultipleTimes) {
                                Text("No").tag(false)
                                Text("Yes").tag(true)
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 120)
                        }
                        
                        HStack {
                            if visitedMultipleTimes{
                                Text("Most Recent Year Visited")
                                    .font(.headline)
                            } else {
                                Text("Year Visited")
                                    .font(.headline)
                            }
                            
                            Spacer()
                            
                            Picker("Year", selection: $lastVisited) {
                                ForEach((stadium.opened...Calendar.current.component(.year, from: Date())).reversed(), id: \.self) { year in
                                    Text(String(year)).tag(year)
                                }
                            }
                            .pickerStyle(.automatic)
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                    
                    // MARK: Photos Section
                    HStack {
                        Spacer()
                        
                        Button {
                            photoPickerPresented.toggle()
                        } label: {
                            Image(systemName: "camera.fill")
                            Text("Photos")
                        }
                        .buttonStyle(.glassProminent)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    ForEach(photos) { photo in
                        VStack(alignment: .trailing, spacing: 6) {
                            
                            AsyncImage(url: URL(string: photo.imageURLString)) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(12)
                            } placeholder: {
                                ProgressView()
                                    .tint(.red)
                            }
                            .frame(maxWidth: .infinity)
                            
                            Button(role: .destructive) {
                                Task {
                                    await PhotoViewModel.deletePhoto(stadiumId: stadium.id, photo: photo)
                                    
                                    PhotoViewModel.loadPhotos(stadiumId: stadium.id) { photos in
                                        DispatchQueue.main.async {
                                            self.photos = photos
                                        }
                                    }
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                                    .font(.caption)
                            }
                            .padding(.bottom, 8)
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    cancelChanges()
                    dismiss()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    saveChanges()
                    dismiss()
                }
            }
        }
        .navigationBarBackButtonHidden()
        .task {
            loadRatings()
            PhotoViewModel.loadPhotos(stadiumId: stadium.id) { photos in
                self.photos = photos
            }
        }
        .photosPicker(isPresented: $photoPickerPresented, selection: $selectedPhoto)
        .onChange(of: selectedPhoto) { _, newItem in
            Task {
                guard let newItem else { return }
                
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    self.photoData = data
                    
                    let photo = Photo()
                    
                    await PhotoViewModel.saveImage(
                        stadiumId: stadium.id,
                        photo: photo,
                        data: data
                    )
                    
                    PhotoViewModel.loadPhotos(stadiumId: stadium.id) { photos in
                        DispatchQueue.main.async {
                            self.photos = photos
                        }
                    }
                }
            }
        }
    }
    
    
    // TODO: need AI explanation; binding varaible, ViewBuilding Function (DRY)
    @ViewBuilder
    func ratingRow(title: String, value: Binding<Double>, maxValue: Double = 10) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Text(String(format: "%.1f", value.wrappedValue))
                    .foregroundColor(.secondary)
            }
            Slider(value: value, in: 0...maxValue, step: 0.1)
        }
    }
    
    //TODO: need to be able to explain what this is doing
    func loadRatings() {
        StadiumRatingStore.load(stadiumId: stadium.id) { data in
            locationRating = data["location"] as? Double ?? 0
            foodRating = data["food"] as? Double ?? 0
            atmosphereRating = data["atmosphere"]  as? Double ?? 0
            amenityRating = data["amenities"] as? Double ?? 0
            accessibilityRating = data["accessibility"] as? Double ?? 0
            prepostRating = data["prepost"] as? Double ?? 0
            uniqueRating = data["unique"] as? Double ?? 0
            hasVisited = data["hasVisited"] as? Bool ?? false
            notes = data["notes"] as? String ?? ""
            price = data["price"] as? Double ?? 0.0
            lastVisited = data["lastVisited"] as? Int ?? Calendar.current.component(.year, from: Date())
            visitedMultipleTimes  = data["visitedMultipleTimes"] as? Bool ?? false
        }
    }
    
    //TODO: need to be able to explain what this is doing
    func saveChanges() {
        if !hasVisited {
            locationRating = 0
            foodRating = 0
            atmosphereRating = 0
            amenityRating = 0
            accessibilityRating = 0
            prepostRating = 0
            uniqueRating = 0
            notes = ""
            price = 0.0
            lastVisited = Calendar.current.component(.year, from: Date())
            visitedMultipleTimes = false
            
            // delete photos when untoggling hasVisited
            Task {
                await PhotoViewModel.deleteAllPhotos(stadiumId: stadium.id)
                DispatchQueue.main.async {
                    self.photos = []
                }
            }
        }
        
        StadiumRatingStore.save(
            stadiumId: stadium.id,
            hasVisited: hasVisited,
            location: locationRating,
            food: foodRating,
            atmosphere: atmosphereRating,
            amenities: amenityRating,
            accessibility: accessibilityRating,
            prepost: prepostRating,
            unique: uniqueRating,
            notes: notes,
            price: price,
            lastVisited: lastVisited,
            visitedMultipleTimes: visitedMultipleTimes
        )
        onSave()
    }
    
    func cancelChanges() { // TODO: understand the purpose of this
        loadRatings()
    }
}

#Preview {
    DetailView(stadium: Stadium(team: "Atlanta Braves", stadium: "Truist Park", latitude: 33.8907, longitude: -84.4677, capacity: 41084, opened: 2017, logo: "https://dejpknyizje2n.cloudfront.net/media/carstickers/versions/atlanta-braves-mlb-logo-sticker-u3c2e-120b-x418.png", stadiumImage: "https://img.mlbstatic.com/mlb-images/image/private/t_16x9/t_w2208/mlb/vploiziye2gmvm1l9n0j.jpg"), onSave: {})
    //TODO: AI added the onSave: {}, why needed?
}
