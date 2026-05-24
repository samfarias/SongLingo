//
//  WordCards.swift
//  SongLingo
//
//  Created by Jaci on 4/20/26.
//

import SwiftUI

struct WordCards: View {
    @State private var wordCardExerciseData: WordCardExerciseData?
    
    @State private var practiceWords: [PracticeWord] = []
    @State private var distractors: [[String]] = []
    @State private var wordCardIdx = 0
    
    @State private var progress: Double = 1.0
    @State private var remainingTime: TimeInterval = 60
    @State private var timer: Timer? = nil
    
    @State private var currWord: String = ""
    @State private var currOptions: [String] = []
    @State private var correctOptionIndex: Int = 0
    
    @State private var selectedOptionIndex: Int? = nil
    @State private var isCheckingAnswer = false
    
    @State private var navigateToResults = false
    @State private var isLoading = true
    
    @State private var totalCardsAnswered = 0
    @State private var correctCards = 0
    @State private var startTime: Date? = nil
    @State private var endTime: Date? = nil
    @State private var currentPhonetic: String = ""

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
                            .padding(.horizontal)
                            .foregroundColor(.white)
                            .font(.title2)
                            .bold()
                            .lineLimit(2)
                    }
                    
                    Spacer()
                            .frame(maxHeight: 60)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.15))
                            .frame(height: 150)
                            .shadow(color: .black.opacity(0.2), radius: 4)
                        
                        VStack(alignment: .center, spacing: 8) {
                            Text(currWord.capitalized)
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .bold()
                                .lineLimit(1)

                            if !currentPhonetic.isEmpty {
                                Text(currentPhonetic)
                                    .foregroundColor(.white.opacity(0.7))
                                    .italic()
                                    .lineLimit(1)
                            }

                            Button {
                                AudioPlayerManager.shared.speakWord(currWord)
                            } label: {
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.title2)
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(8)
                                    .background(Color.white.opacity(0.15))
                                    .clipShape(Circle())
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 70)
                    .padding(.horizontal)
                    
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(0..<currOptions.count, id: \.self) { index in
                            Button(action: {
                                checkAnswer(index: index)
                            }) {
                                Text(currOptions[index].capitalized)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 80)
                                    .background(Group {
                                        if isCheckingAnswer && index == correctOptionIndex {
                                            Color.green
                                        } else if isCheckingAnswer && index == selectedOptionIndex {
                                            Color.red
                                        } else {
                                            Color.white.opacity(0.15)
                                        }
                                    })
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
            .background (
                ZStack {
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
                                Color.blue.opacity(0.2),
                                    .clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 200
                        )
                        .frame(width: 400, height: 400)
                        .offset(x: 200, y: -10)
                    }
                }
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
        let backendPhonetic = (wordObj.pronunciation ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        self.currentPhonetic = backendPhonetic.isEmpty ? spanishToEnglishPhonetic(wordObj.wordText) : backendPhonetic

        var options = wordDistractors
        options.append(wordObj.translation ?? "N/A")
        options.shuffle()

        self.currOptions = options

        if let correctIdx = options.firstIndex(of: wordObj.translation ?? "N/A") {
            self.correctOptionIndex = correctIdx
        }

        AudioPlayerManager.shared.speakWord(currWord)
    }
    
    func checkAnswer(index: Int) {
        totalCardsAnswered += 1
        selectedOptionIndex = index
        isCheckingAnswer = true
        
        if index == correctOptionIndex {
            correctCards += 1
            
            Task {
                do {
                    try await NetworkManager.shared.updateUserWordNumPracticesCompleted(word_text: currWord)
                } catch {
                    print("Error updating UserWord num practices completed \(error)")
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isCheckingAnswer = false
            selectedOptionIndex = nil
            
            wordCardIdx += 1
            setupCurrentWord()
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
    
    func updateProgress() {
        progress = remainingTime / totalDuration
    }
}

#Preview {
    WordCards()
}
