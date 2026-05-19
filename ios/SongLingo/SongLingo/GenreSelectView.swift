//
//  GenreSelectView.swift
//  SongLingo
//
//  Created by Derek Huang on 4/21/26.
//

import SwiftUI

struct GenreSelectionView: View {
    var selectedLanguage: String
    var selectedProficiency: String
    
    let genres = [
            "Pop", "Reggaeton-Urbano", "Regional-Mexican",
            "Indie-Alternative", "Tropical", "Rock"
        ]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @State private var selectedGenres: Set<String> = []
    
    // state variable to trigger the navigation to the Home screen
    @State private var navigateToHome = false
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.030, green: 0.050, blue: 0.120),
                        Color(red: 0.275, green: 0.095, blue: 0.250),
                        Color(red: 0.110, green: 0.165, blue: 0.325)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                GeometryReader { geometry in
                    ZStack {
                        ForEach(0..<150, id: \.self) { i in
                            Circle()
                                .fill(.white)
                                .frame(width: CGFloat.random(in: 1.5...3), height: CGFloat.random(in: 1.5...3))
                                .opacity(Double.random(in: 0.1...0.9))
                                .position(
                                    x: CGFloat.random(in: 0...geometry.size.width),
                                    y: CGFloat.random(in: 0...geometry.size.height)
                                )
                        }
                        
                        ForEach(0..<10, id: \.self) { i in
                            Image(systemName: i % 2 == 0 ? "sparkles" : "star.fill")
                                .foregroundColor(.gray)
                                .font(.system(size: CGFloat.random(in: 10...15)))
                                .opacity(Double.random(in: 0.5...0.7))
                                .shadow(color: .white.opacity(0.3), radius: 3)
                                .position(
                                    x: CGFloat.random(in: 0...geometry.size.width),
                                    y: CGFloat.random(in: 0...geometry.size.height)
                                )
                        }
                    }
                }
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    VStack(spacing: 6) {
                        Text("♪ SongLingo")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Learn languages through the music you love")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    VStack(spacing: 20) {
                        VStack(spacing: 6) {
                            Text("What music do you enjoy?")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 260)
                            
                            Text("Pick your favorite genres to get started")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(genres, id: \.self) { genre in
                                                    
                                Button {
                                    if selectedGenres.contains(genre) {
                                        selectedGenres.remove(genre)
                                    } else {
                                        selectedGenres.insert(genre)
                                    }
                                } label: {
                                                        
                                    VStack(spacing: 8) {
                                         
                                        Image(genre.replacingOccurrences(of: "/", with: "-"))
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 60)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .aspectRatio(1.4, contentMode: .fit)
                                    .padding(10)
                                    .background(selectedGenres.contains(genre) ? Color.blue.opacity(0.12) : Color.white.opacity(0.55))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(
                                                selectedGenres.contains(genre)
                                                ? Color(red: 0.486, green: 0.227, blue: 0.929)
                                                : Color.gray.opacity(0.35),
                                                lineWidth: selectedGenres.contains(genre) ? 2 : 1
                                            )
                                    )
                                    .cornerRadius(14)
                                }
                            }
                        }
                        
                        HStack(spacing: 16) {
                            Button("Back") {
                                dismiss()
                            }
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(LinearGradient(
                                colors: [
                                    Color(red: 0.250, green: 0.150, blue: 0.920),
                                    Color(red: 0.655, green: 0.195, blue: 0.950),
                                    Color(red: 0.985, green: 0.165, blue: 0.555)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            
                            // swapped NavigationLink for a Button to trigger the API Call
                            Button(action: {
                                Task {
                                    do {
                                        // convert the Set of genres into an Array of Strings
                                        let genresArray = Array(selectedGenres)
                                        
                                        // 2. Fire the PATCH request to the backend
                                        try await NetworkManager.shared.updateProfile(
                                            proficiency: selectedProficiency,
                                            language: "Spanish",
                                            genres: genresArray
                                        )
                                        
                                        // 3. Success! Slide to the home screen
                                        navigateToHome = true
                                    } catch {
                                        print("Failed to save profile: \(error)")
                                    }
                                }
                            }) {
                                Text("Continue")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(LinearGradient(
                                        colors: [
                                            Color(red: 0.250, green: 0.150, blue: 0.920),
                                            Color(red: 0.655, green: 0.195, blue: 0.950),
                                            Color(red: 0.985, green: 0.165, blue: 0.555)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            .opacity(selectedGenres.isEmpty ? 0.5 : 1.0)
                            .disabled(selectedGenres.isEmpty)
                        }
                    }
                    .padding(25)
                    .background(Color.white.opacity(0.09))
                    .cornerRadius(25)
                    .padding(.horizontal, 30)
                    
                    Spacer()
                }
            }
            .navigationBarBackButtonHidden()
            .navigationDestination(isPresented: $navigateToHome) {
                ContentView()
            }
        }
    }
}

#Preview {
    GenreSelectionView(selectedLanguage: "Spanish", selectedProficiency: "Beginner")
}
