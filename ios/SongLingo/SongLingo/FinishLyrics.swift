//
//  FinishLyrics.swift
//  SongLingo
//
//  Created by Jaci on 5/5/26.
//

import SwiftUI

struct FinishLyrics: View {
    @State private var lyricChallengeData: LyricChallengeData?
    
    struct Lyric {
        let text: String
        let options: [String]
        let correctOption: String
    }

    // Dummy data
    @State private var lyrics: [Lyric] = [
        Lyric(text: "Don't stop ___", options: ["believing", "crying", "running", "flying"], correctOption: "believing"),
    ]
    @State private var currentLyric: Lyric = Lyric(text: "", options: [], correctOption: "")
    @State private var optionColors: [String: Color] = [:]
    @State private var questionCount: Int = 0
    @State private var correctAnswers: Int = 0
    @State private var startTime: Date = Date()
    @State private var totalTime: TimeInterval = 0
    @State private var navigateToLyricResults = false

    let maxQuestions = 10

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Fill in the NAME's lyrics")
                    .font(.title)
                    .bold()
                    .padding()

                Text(currentLyric.text)
                    .font(.title2)
                    .italic()
                    .bold()
                    .padding(.top, 20)
                    .padding(.bottom, 50)

                ForEach(currentLyric.options, id: \.self) { option in
                    Button(action: {
                        handleAnswer(selected: option)
                    }) {
                        Text(option)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(optionColors[option] ?? Color.blue.opacity(0.3))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationDestination(isPresented: $navigateToLyricResults) {
                FinishLyricsResults(
                    totalTime: totalTime,
                    correctAnswers: correctAnswers,
                    totalQuestions: questionCount
                )
            }
            .padding()
            .onAppear {
                startTime = Date()
                loadNewLyric()
            }
            .task {
                            do {
                                self.lyricChallengeData = try await NetworkManager.shared.fetchCompleteTheLyricExerciseData()
                            } catch {
                                print("Request failed: \(error)")
                            }
                        }
        }
    }

    func handleAnswer(selected: String) {
        if selected == currentLyric.correctOption {
            correctAnswers += 1
            optionColors[selected] = Color.green
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                loadNewLyric()
            }
        } else {
            optionColors[selected] = Color.red
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                loadNewLyric()
            }
        }
    }

    func loadNewLyric() {
        if questionCount >= maxQuestions {
            totalTime = Date().timeIntervalSince(startTime)
            self.navigateToLyricResults = true
            return
        }

        guard !lyrics.isEmpty else { return }

        var newLyric: Lyric
        repeat {
            newLyric = lyrics.randomElement()!
        } while newLyric.text == currentLyric.text && lyrics.count > 1

        currentLyric = newLyric
        optionColors = Dictionary(uniqueKeysWithValues: currentLyric.options.map { ($0, Color.blue.opacity(0.3)) })
        questionCount += 1
    }
}

#Preview {
    FinishLyrics()
}
