//
//  FinishLyrics.swift
//  SongLingo
//
//  Created by Jaci on 5/5/26.
//

import SwiftUI

struct FinishLyrics: View {
    @State private var lyricChallengeData: LyricChallengeData?
    @State private var songTitle: String = "Title"
    @State private var songArtist: String = "Artist"
    @State private var songId: Int = -1
    
    struct Lyric {
        let id = UUID()
        let text: String
        let options: [String]
        let correctOption: String
    }
    
    @State private var isLoading = true
    @State private var currentLyric: Lyric = Lyric(text: "", options: [], correctOption: "")
    @State private var optionColors: [String: Color] = [:]
    @State private var questionCount: Int = 0
    @State private var correctAnswers: Int = 0
    @State private var startTime: Date = Date()
    @State private var totalTime: TimeInterval = 0
    @State private var navigateToLyricResults = false

    let maxQuestions = 6

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.050, green: 0.120, blue: 0.150),
                        Color(red: 0.110, green: 0.440, blue: 0.450),
                        Color(red: 0.376, green: 0.450, blue: 0.450)],
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
                
                VStack {
                    RadialGradient(
                        colors: [
                            Color.blue.opacity(0.15),
                                .clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 200
                    )
                    .frame(width: 400, height: 400)
                    .offset(x: -100, y: 10)
                    
                    Spacer(minLength: 0.2)
                    
                    RadialGradient(
                        colors: [
                            Color.blue.opacity(0.15),
                                .clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 200
                    )
                    .frame(width: 400, height: 400)
                    .offset(x: 150, y: -10)
                }
                
                VStack(spacing: 20) {
                    if isLoading {
                        if questionCount == 0 {
                            ProgressView("Loading Lyrics...")
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .foregroundColor(.white)
                        }
                    } else if currentLyric.text.isEmpty {
                        VStack {
                            Text("No songs found!")
                                .foregroundColor(.white)
                            Button("Retry") {
                                loadGameData()
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(12)
                        }
                    } else {
                        Text("Fill in the lyrics from '\(self.songTitle)' by \(self.songArtist):")
                            .font(.title)
                            .foregroundColor(.white)
                            .bold()
                            .padding()
                        
                        Spacer()
                            .frame(maxHeight: 40)
                        
                        Text(currentLyric.text)
                            .font(.title2)
                            .italic()
                            .bold()
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.top, 20)
                            .padding(.bottom, 50)

                        ForEach(currentLyric.options, id: \.self) { option in
                            Button(action: {
                                handleAnswer(selected: option)
                            }) {
                                Text(option)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(optionColors[option] ?? Color.white.opacity(0.15))
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            .disabled(optionColors.values.contains(Color.green))
                        }
                    }
                }
                .padding()
            }
            .navigationDestination(isPresented: $navigateToLyricResults) {
                FinishLyricsResults(
                    totalTime: totalTime,
                    correctAnswers: correctAnswers,
                    totalQuestions: questionCount
                )
            }
            .onAppear {
                startTime = Date()
                loadGameData()
            }
        }
    }

    func loadGameData() {
        isLoading = true
        
        Task {
            do {
                let challenge = try await NetworkManager.shared.fetchCompleteTheLyricExerciseData()
                
                await MainActor.run {
                    self.currentLyric = Lyric(
                        text: challenge.lyric,
                        options: challenge.buttonOptions,
                        correctOption: challenge.missingWord
                    )
                                        
                    self.songTitle = challenge.songTitle
                    self.songArtist = challenge.songArtist
                    self.songId = challenge.songId
                    
                    optionColors = Dictionary(uniqueKeysWithValues: currentLyric.options.map { ($0, Color.white.opacity(0.3)) })
                    
                    self.isLoading = false
                }
            } catch {
                print("Connection Error: \(error)")
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
    
    func handleAnswer(selected: String) {
        questionCount += 1
        
        if selected == currentLyric.correctOption {
            correctAnswers += 1
            optionColors[selected] = Color.green
            
            Task {
                do {
                    try await NetworkManager.shared.updateUserWordNumPracticesCompleted(word_text: currentLyric.correctOption)
                } catch {
                    print("Error updating UserWord num practices completed \(error)")
                }
            }
            Task {
                do {
                    try await NetworkManager.shared.updateUserSongProgress(song_id: self.songId, request_type: "lyric_challenge", playlist_id: -1)
                } catch {
                    print("Error updating user song progress \(error)")
                }
            }
        } else {
            optionColors[selected] = Color.red
            optionColors[currentLyric.correctOption] = Color.green
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    if questionCount < maxQuestions {
                        loadGameData()
                    } else {
                        totalTime = Date().timeIntervalSince(startTime)
                        self.navigateToLyricResults = true
                    }
                }
    }
}

#Preview {
    FinishLyrics()
}
