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
        // Only show the big spinner for the very first load
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
                    
                    optionColors = Dictionary(uniqueKeysWithValues: currentLyric.options.map { ($0, Color.blue.opacity(0.3)) })
                    
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
        } else {
            optionColors[selected] = Color.red
            optionColors[currentLyric.correctOption] = Color.green
        }
        
        // Wait about a second so they see if they were right/wrong
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
