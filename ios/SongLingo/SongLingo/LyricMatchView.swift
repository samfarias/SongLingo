//
//  LyricMatchView.swift
//  SongLingo
//
//  Created by Derek Huang on 5/11/26.
//

import SwiftUI

struct LyricMatchView: View {
    
    @State private var lyricMatchData: LyricMatchingData?
    @State private var correctWords: [String] = []
    @State private var wordBank: [String] = []
    @State private var sentence: [String] = []
    @State private var isPlaying: Bool = false
    
    // STATE MANAGERS FOR TRACKING AND PROGRESSION (Matching FinishLyrics)
    @State private var isLoading = true
    @State private var questionCount: Int = 0
    @State private var correctAnswers: Int = 0
    @State private var startTime: Date = Date()
    @State private var totalTime: TimeInterval = 0
    @State private var navigateToLyricResults = false
    @State private var isSubmissionEvaluated = false
    @State private var isCorrectAnswer = false
    
    let maxQuestions = 6
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("What do you hear?")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                    
                    Text("Question \(min(questionCount + 1, maxQuestions)) of \(maxQuestions)")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                }
                
                if isLoading {
                    Spacer()
                    HStack {
                        Spacer()
                        ProgressView("Loading Audio Exercise...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    Spacer()
                } else {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .frame(height: 160)
                        .overlay {
                            VStack(spacing: 16) {
                                Button {
                                    isPlaying.toggle()
                                    if isPlaying {
                                        isPlaying = false
                                    } else if let b64 = lyricMatchData?.audioBase64 {
                                        let clean = b64.trimmingCharacters(in: .whitespacesAndNewlines)
                                        AudioPlayerManager.shared.playBase64Audio(clean)
                                        isPlaying = true
                                    }
                                } label: {
                                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                        .font(.system(size: 26, weight: .bold))
                                        .foregroundStyle(.white)
                                        .frame(width: 64, height: 64)
                                        .background(Circle().fill(Color.white.opacity(0.14)))
                                        .overlay(Circle().stroke(Color.white.opacity(0.12)))
                                }
                                .buttonStyle(.plain)
                                .disabled(isSubmissionEvaluated) // Block actions while progressing
                                
                                Text("Play Audio")
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(.white.opacity(0.85))
                            }
                        }
                        .shadow(color: .black.opacity(0.12), radius: 16, y: 8)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("YOUR ANSWER")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.6))
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: 12) {
                            ForEach(sentence, id: \.self) { word in
                                WordCapsule(word: word, isCorrect: isSubmissionEvaluated ? isCorrectAnswer : nil)
                                    .onTapGesture {
                                        if !isSubmissionEvaluated { removeWord(word) }
                                    }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 70, alignment: .topLeading)
                        .background(.white.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(isSubmissionEvaluated ? (isCorrectAnswer ? Color.green : Color.red) : Color.white.opacity(0.1), lineWidth: 2)
                        )
                        .shadow(color: .black.opacity(0.03), radius: 10, y: 4)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("WORD BANK")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.6))
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: 12) {
                            ForEach(wordBank, id: \.self) { word in
                                WordCapsule(word: word)
                                    .onTapGesture {
                                        if !isSubmissionEvaluated { addWord(word) }
                                    }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        handleSubmitAnswer()
                    } label: {
                        Text(isSubmissionEvaluated ? (isCorrectAnswer ? "Correct!" : "Incorrect") : "Submit")
                            .font(.headline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .background(isSubmissionEvaluated ? (isCorrectAnswer ? Color.green : Color.red) : Color.white)
                    .foregroundStyle(isSubmissionEvaluated ? .white : .black)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .disabled(sentence.isEmpty || isSubmissionEvaluated)
                    .opacity((sentence.isEmpty || isSubmissionEvaluated) ? 0.5 : 1)
                }
            }
            .padding(20)
            .padding(.top, 12)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.050, green: 0.120, blue: 0.150),
                        Color(red: 0.110, green: 0.440, blue: 0.450),
                        Color(red: 0.376, green: 0.450, blue: 0.450)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationBarTitleDisplayMode(.inline)
            .animation(.spring(duration: 0.3), value: sentence)
            // PROGRAMMATIC ROUTING OUT TO RESULTS
            .navigationDestination(isPresented: $navigateToLyricResults) {
                FinishLyricsResults(
                    totalTime: totalTime,
                    correctAnswers: correctAnswers,
                    totalQuestions: questionCount
                )
            }
            .onAppear {
                startTime = Date()
                loadGameRound()
            }
        }
    }
}

// MARK: - Game Control Logic Extensions
extension LyricMatchView {
    
    func loadGameRound() {
        isLoading = true
        isSubmissionEvaluated = false
        sentence = []
        
        Task {
            do {
                let data = try await NetworkManager.shared.fetchLyricMatchExerciseData()
                await MainActor.run {
                    self.lyricMatchData = data
                    self.correctWords = data.lineToMatch.components(separatedBy: " ")
                    self.wordBank = self.correctWords.shuffled()
                    self.isLoading = false
                }
            } catch {
                print("Request failed: \(error)")
                await MainActor.run { self.isLoading = false }
            }
        }
    }
    
    func handleSubmitAnswer() {
        isCorrectAnswer = (sentence == correctWords)
        isSubmissionEvaluated = true
        
        if isCorrectAnswer {
            correctAnswers += 1
            
            if let sId = lyricMatchData?.songId {
                Task {
                    do {
                        try await NetworkManager.shared.updateUserSongProgress(song_id: sId, request_type: "lyric_challenge", playlist_id: -1)
                    } catch {
                        print("Error syncing profile progress: \(error)")
                    }
                }
            }
        }
        
        // Progression delay window
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            questionCount += 1
            if questionCount < maxQuestions {
                loadGameRound()
            } else {
                totalTime = Date().timeIntervalSince(startTime)
                self.navigateToLyricResults = true
            }
        }
    }
    
    func addWord(_ word: String) {
        guard let index = wordBank.firstIndex(of: word) else { return }
        sentence.append(word)
        wordBank.remove(at: index)
    }
    
    func removeWord(_ word: String) {
        guard let index = sentence.firstIndex(of: word) else { return }
        wordBank.append(word)
        sentence.remove(at: index)
    }
}

// MARK: - Component Layout Customization
struct WordCapsule: View {
    let word: String
    var isCorrect: Bool? = nil // Optional coloring hooks for feedback states
    
    var body: some View {
        Text(word)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                Group {
                    if let status = isCorrect {
                        status ? Color.green.opacity(0.4) : Color.red.opacity(0.4)
                    } else {
                        Color.white.opacity(0.12)
                    }
                }
            )
            .overlay(
                Capsule()
                    .stroke(
                        isCorrect != nil ? (isCorrect! ? Color.green : Color.red) : Color.white.opacity(0.15),
                        lineWidth: 1
                    )
            )
            .clipShape(Capsule())
    }
}


#Preview {
    
    NavigationStack {
        LyricMatchView()
    }
}
