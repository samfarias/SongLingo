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
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 24) {
            
            VStack(alignment: .leading, spacing: 6) {
                
                Text("What do you hear?")
                    .font(.largeTitle.bold())
                
                Text("Listen carefully and rebuild the lyric.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.92),
                            Color.black.opacity(0.78)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
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
                    .foregroundStyle(.secondary)
                
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
                .background(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.black.opacity(0.05))
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
                    .foregroundStyle(.secondary)
                
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
                // TODO: Submit logic
            } label: {
                
                Text("Submit")
                    .font(.headline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .background(Color.black)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .disabled(sentence.isEmpty)
            .opacity(sentence.isEmpty ? 0.5 : 1)
        }
        .padding(20)
        .padding(.top, 12)
        .background(
            Color(UIColor.systemGroupedBackground)
        )
        .navigationTitle("Lyric Match")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.spring(duration: 0.3), value: sentence)
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
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.white)
            .overlay(
                Capsule()
                    .stroke(Color.black.opacity(0.06))
            )
            .shadow(
                color: .black.opacity(0.04),
                radius: 4,
                y: 2
            )
            .clipShape(Capsule())
    }
}

#Preview {
    
    NavigationStack {
        LyricMatchView()
    }
}
