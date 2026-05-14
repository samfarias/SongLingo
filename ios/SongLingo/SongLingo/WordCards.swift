//
//  WordCards.swift
//  SongLingo
//
//  Created by Jaci on 4/20/26.
//

import SwiftUI

struct WordCards: View {
    @State private var wordCardExerciseData: WordCardExerciseData?
    
    // distractors[i] is the list of distractors for the word at practiceWords[i]
    @State private var practiceWords: [PracticeWord] = []
    @State private var distractors: [[String]] = []
    @State private var wordCardIdx = 0
    
    @State private var progress: Double = 1.0
    @State private var remainingTime: TimeInterval = 60
    @State private var timer: Timer? = nil
    
    @State private var currWord: String = ""
    @State private var currOptions: [String] = []
    @State private var correctOptionIndex: Int = 0
    
    @State private var navigateToResults = false
    @State private var isLoading = true
    
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
                        .stroke(lineWidth: 6)
                        .opacity(0.08)
                        .foregroundColor(.gray)
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .trim(from: 0.0, to: progress)
                        .stroke(style: StrokeStyle(lineWidth: 7, lineCap: .round, lineJoin: .round))
                        .rotationEffect(.degrees(270))
                        .foregroundColor(Color.white.opacity(0.45))
                        .frame(width: 60, height: 45)
                }
                .padding()
                
                VStack(alignment: .center) {
                    if isLoading {
                        ProgressView("Fetching words...")
                            .padding(.top, 100)
                            .foregroundColor(.white)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Define each word before time runs out!")
                            .padding(.top, 110)
                            .foregroundColor(.white)
                            .bold()
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.15))
                            .frame(height: 150)
                            .shadow(color: .black.opacity(0.2), radius: 4)
                        
                        VStack (alignment: .center) {
                            HStack {
                                Spacer()
                            }
                            
                            Text(currWord)
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .bold()
                                .lineLimit(1)
                            
                            Text(currentPronunciation?.phonetic ?? "")
                                .foregroundColor(.white.opacity(0.8))
                                .italic()
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 70)
                    .padding(.horizontal)
                    
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(0..<currOptions.count, id: \.self) { index in
                            Button(action: {
                                ifCorrectAnswer(index: index)
                            }) {
                                Text(currOptions[index])
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 80)
                                    .background(Color.white.opacity(0.15))
                                    .cornerRadius(15)
                                    .shadow(radius: 2)
                            }
                        }
                    }
                    .padding(.horizontal)
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
            .task {
                await fetchData()
            }
            .onDisappear {
                timer?.invalidate()
            }
        }
    }
    
    func fetchData() async {
        do {
            // FIX: Removed userID and updated the NetworkManager call
            let data = try await NetworkManager.shared.fetchWordCardExerciseData()
            
            await MainActor.run {
                self.wordCardExerciseData = data
                self.practiceWords = data.practiceWords
                self.distractors = data.wordDistractors
                self.isLoading = false
                
                setupCurrentWord()
                
                startTime = Date()
                startTimer()
            }
        } catch {
            print(" Backend Request failed: \(error)")
        }
    }
    
    func setupCurrentWord() {
        guard wordCardIdx < practiceWords.count else {
            endGame()
            return
        }
        
        let wordObj = practiceWords[wordCardIdx]
        let wordDistractors = distractors[wordCardIdx]
        
        self.currWord = wordObj.wordText
        
        var options = wordDistractors
        options.append(wordObj.definition)
        options.shuffle()
        
        self.currOptions = options
        
        if let correctIdx = options.firstIndex(of: wordObj.definition) {
            self.correctOptionIndex = correctIdx
        }
        
        Task {
            do {
                let pronunciationData = try await NetworkManager.shared.fetchPronunciation(for: currWord)
                await MainActor.run {
                    self.currentPronunciation = pronunciationData
                    AudioPlayerManager.shared.playBase64Audio(pronunciationData.audio)
                }
            } catch {
                print("Pronunciation fetch failed: \(error)")
            }
        }
    }
    
    func ifCorrectAnswer (index: Int) {
        totalCardsAnswered += 1
        if index == correctOptionIndex {
            correctCards += 1
            addTime(seconds: 3)
            wordCardIdx += 1
            setupCurrentWord()
        } else {
            subtractTime(seconds: 5)
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
                endGame()
            }
        }
    }
    
    func endGame() {
        timer?.invalidate()
        endTime = Date()
        navigateToResults = true
    }
    
    func addTime(seconds: Double) {
        remainingTime = min(remainingTime + seconds, totalDuration)
        updateProgress()
    }
    
    func subtractTime(seconds: Double) {
        remainingTime = max(remainingTime - seconds, 0)
        updateProgress()
    }
    
    func updateProgress() {
        progress = remainingTime / totalDuration
    }
}

#Preview {
    WordCards()
}
