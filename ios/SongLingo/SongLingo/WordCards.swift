//
//  WordCards.swift
//  SongLingo
//
//  Created by Jaci on 4/20/26.
//

import SwiftUI

struct WordCards: View {
    @State private var progress: Double = 1.0
    @State private var remainingTime: TimeInterval = 60
    @State private var timer: Timer? = nil
    
    @State private var currWord: String = "WORD"
    @State private var currOptions: [String] = ["Option 1", "Option 2", "Option 3", "Option 4"]
    @State private var correctOptionIndex: Int = 0
    
    @State private var navigateToResults = false
    
    @State private var totalCardsAnswered = 0
    @State private var correctCards = 0
    @State private var startTime: Date? = nil
    @State private var endTime: Date? = nil
    @State private var currentPronunciation: PronunciationResponse? = nil
    
    let totalDuration: TimeInterval = 60
    
    var body: some View {
        NavigationStack {
            ZStack (alignment: .topTrailing) {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 7)
                        .opacity(0.08)
                        .foregroundColor(.black)
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .trim(from: 0.0, to: progress)
                        .stroke(style: StrokeStyle(lineWidth: 7, lineCap: .round, lineJoin: .round))
                        .rotationEffect(.degrees(270))
                        .foregroundColor(Color.purple.opacity(0.5))
                        .frame(width: 60, height: 45)
                }
                .padding()
                .onAppear {
                    startTime = Date()
                    startTimer()
                }
                .onDisappear {
                    timer?.invalidate()
                }
                
                VStack(alignment: .center) {
                    Text("Define each word before time runs out!")
                        .padding(.top, 110)
                        .bold()
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.purple.opacity(0.4))
                            .frame(height: 150)
                            .shadow(color: .gray.opacity(0.8), radius: 4)
                        
                        VStack (alignment: .center) {
                            HStack {
                                Spacer()
                            }
                            Text(currWord)
                                .foregroundColor(.black)
                                .bold()
                                .lineLimit(1)
                                .padding(.horizontal, 1)
                            Text ("sounded out")
                                .foregroundColor(.black)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 70)
                    .padding(.horizontal)
                    
                    VStack (alignment: .leading) {
                        HStack {
                            Button(action: {
                                ifCorrectAnswer(index: 0)
                            }) {
                                Text(currOptions.count > 0 ? currOptions[0] : "Option 1")
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 80)
                                    .background(Color.purple.opacity(0.4))
                                    .cornerRadius(15)
                                    .shadow(radius: 4)
                            }
                                .padding()
                            
                            Button(action: {
                                ifCorrectAnswer(index: 1)
                            }) {
                                Text(currOptions.count > 0 ? currOptions[1] : "Option 2")
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 80)
                                    .background(Color.purple.opacity(0.4))
                                    .cornerRadius(15)
                                    .shadow(radius: 4)
                            }
                            .padding()
                        }
                        HStack {
                            Button(action: {
                                ifCorrectAnswer(index: 2)
                            }) {
                                Text(currOptions.count > 0 ? currOptions[2] : "Option 3")
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 80)
                                    .background(Color.purple.opacity(0.4))
                                    .cornerRadius(15)
                                    .shadow(radius: 4)
                            }
                            .padding()
                            
                            Button(action: {
                                ifCorrectAnswer(index: 3)
                            }) {
                                Text(currOptions.count > 0 ? currOptions[3] : "Option 4")
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 80)
                                    .background(Color.purple.opacity(0.4))
                                    .cornerRadius(15)
                                    .shadow(radius: 4)
                            }
                            .padding()
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .navigationDestination(isPresented: $navigateToResults) {
                WordCardsResult(
                    wordCardsCorrect: correctCards,
                    totalWordCards: totalCardsAnswered,
                    totalTime: endTime != nil && startTime != nil ? endTime!.timeIntervalSince(startTime!) : 0
                )
            }
        }
    }
    
    func startTimer() {
        remainingTime = totalDuration
        progress = 1.0
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if remainingTime > 0 {
                remainingTime -= 0.1
                updateProgress()
            } else {
                timer?.invalidate()
                remainingTime = 0
                updateProgress()
                endTime = Date()
                DispatchQueue.main.async {
                    self.navigateToResults = true
                }
            }
        }
    }
    
    func ifCorrectAnswer (index: Int) {
        totalCardsAnswered += 1
        if index == correctOptionIndex {
            correctCards += 1
            addTime(seconds: 5)
            loadNextWord()
        } else {
            subtractTime(seconds: 5)
        }
    }
    
    func addTime(seconds: Double) {
        remainingTime += seconds
        if remainingTime > totalDuration {
            remainingTime = totalDuration
        }
        updateProgress()
    }
    
    func subtractTime(seconds: Double) {
        remainingTime -= seconds
        if remainingTime < 0 {
            remainingTime = 0
        }
        updateProgress()
    }
    
    func updateProgress() {
        progress = remainingTime / totalDuration
    }
    
    func loadNextWord() {
        let newWord = "example" // Or wherever you pull the real word from
        self.currWord = newWord
        self.currOptions = ["Option A", "Option B", "Option C", "Option D"]
        self.correctOptionIndex = Int.random(in: 0..<4)
        
        Task {
            do {
                // 1. Fetch from NetworkManager
                let pronunciationData = try await NetworkManager.shared.fetchPronunciation(for: newWord)
                
                DispatchQueue.main.async {
                    self.currentPronunciation = pronunciationData
                    
                    // 2. Play using our new AudioPlayerManager
                    AudioPlayerManager.shared.playBase64Audio(pronunciationData.audio)
                }
            } catch {
                print("Failed to fetch pronunciation: \(error)")
            }
        }
    }
}

#Preview {
    WordCards()
}
