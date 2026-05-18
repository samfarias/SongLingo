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
    @State private var showingResultAlert = false
    @State private var isCorrectAnswer = false
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 24) {
            
            VStack(alignment: .leading, spacing: 6) {
                
                Text("What do you hear?")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                
                Text("Listen carefully and rebuild the lyric.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
            }
            
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
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.14))
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.12))
                                )
                        }
                        .buttonStyle(.plain)
                        
                        Text("Play Audio")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.85))
                    }
                }
                .shadow(
                    color: .black.opacity(0.12),
                    radius: 16,
                    y: 8
                )
            
            VStack(alignment: .leading, spacing: 12) {
                
                Text("YOUR ANSWER")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.6))
                
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 70))],
                    spacing: 12
                ) {
                    
                    ForEach(sentence, id: \.self) { word in
                        
                        WordCapsule(word: word)
                            .onTapGesture {
                                removeWord(word)
                            }
                    }
                }
                .padding()
                .frame(
                    maxWidth: .infinity,
                    minHeight: 70,
                    alignment: .topLeading
                )
                .background(.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1))
                )
                .shadow(
                    color: .black.opacity(0.03),
                    radius: 10,
                    y: 4
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 20)
                )
            }
            
            VStack(alignment: .leading, spacing: 12) {
                
                Text("WORD BANK")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.6))
                
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 70))],
                    spacing: 12
                ) {
                    
                    ForEach(wordBank, id: \.self) { word in
                        
                        WordCapsule(word: word)
                            .onTapGesture {
                                addWord(word)
                            }
                    }
                }
            }
            
            Spacer()
            
            Button {
                isCorrectAnswer = (sentence == correctWords)
                showingResultAlert = true
            } label: {
                Text("Submit")
                    .font(.headline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .background(.white)
            .foregroundStyle(.black)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .disabled(sentence.isEmpty)
            .opacity(sentence.isEmpty ? 0.5 : 1)
        }
        .padding(20)
        .padding(.top, 12)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.050, green: 0.120, blue: 0.150),
                    Color(red: 0.110, green: 0.440, blue: 0.450),
                    Color(red: 0.376, green: 0.450, blue: 0.450)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationTitle("Lyric Match")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.spring(duration: 0.3), value: sentence)
        .alert(isPresented: $showingResultAlert){
            Alert(title: Text(isCorrectAnswer ? "Well done!" : "Try again!"), message: Text(isCorrectAnswer ? "You've matched the lyrics correctly!" : "Keep practicing!"), dismissButton: .default(Text("OK")))
        }
        .task {
            do {
                self.lyricMatchData = try await NetworkManager.shared.fetchLyricMatchExerciseData()
                if let data = self.lyricMatchData {
                    correctWords = data.lineToMatch.components(separatedBy: " ")
                    wordBank = correctWords.shuffled()
                }
            } catch {
                print("Request failed: \(error)")
            }
        }
    }
}

extension LyricMatchView {
    
    func addWord(_ word: String) {
        
        guard let index = wordBank.firstIndex(of: word) else {
            return
        }
        
        sentence.append(word)
        wordBank.remove(at: index)
    }
    
    func removeWord(_ word: String) {
        
        guard let index = sentence.firstIndex(of: word) else {
            return
        }
        
        wordBank.append(word)
        sentence.remove(at: index)
    }
}

struct WordCapsule: View {
    
    let word: String
    
    var body: some View {
        
        Text(word)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.white.opacity(0.12))
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.15))
            )
            .clipShape(Capsule())
    }
}

#Preview {
    
    NavigationStack {
        LyricMatchView()
    }
}
