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
        "Mood", "Pop", "Country & Folk",
        "Rock", "Jazz & Blues", "Reggaeton"
    ]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @State private var selectedGenres: Set<String> = []
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.984, green: 0.443, blue: 0.522),
                        Color(red: 0.576, green: 0.200, blue: 0.918),
                        Color(red: 0.231, green: 0.027, blue: 0.392)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    VStack(spacing: 6) {
                        Text("♪ SongLingo")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Learn languages through the music you love")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.95))
                    }
                    VStack(spacing: 20) {
                        VStack(spacing: 6) {
                            Text("What music do you enjoy?")
                                .font(.system(size: 18, weight: .bold))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 260)
                            
                            Text("Pick your favorite genres to get started")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
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
                                         
                                        Image(genre)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 60)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .aspectRatio(1.4, contentMode: .fit)
                                    .padding(10)
                                    .background(selectedGenres.contains(genre) ? Color.blue.opacity(0.12) : Color.white)
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
                            .background(Color(red: 0.486, green: 0.227, blue: 0.929))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            
                            NavigationLink(destination: ContentView()) {
                                Text("Continue")
                            }
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(red: 0.486, green: 0.227, blue: 0.929))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .opacity(selectedGenres.isEmpty ? 0.5 : 1.0)
                            .disabled(selectedGenres.isEmpty)
                        }
                    }
                    .padding(25)
                    .background(Color.white)
                    .cornerRadius(25)
                    .padding(.horizontal, 30)
                    
                    Spacer()
                }
            }
            
        }
    }
}

#Preview {
    GenreSelectionView(selectedLanguage: "Spanish", selectedProficiency: "Beginner")
}
