//
//  WordBank.swift
//  SongLingo
//
//  Created by Jaci on 3/26/26.
//

import SwiftUI

struct WordBank: View {
    @State private var userWords: [UserWordEntry] = []
    @State private var masteryLvlCounts = [0, 0, 0, 0]
    
    var body: some View {
        NavigationStack {
            ZStack {
                ZStack {
                    LinearGradient(
                        colors: [
                            Color(red: 0.150, green: 0.155, blue: 0.425),
                            Color(red: 0.275, green: 0.295, blue: 0.650),
                            Color(red: 0.230, green: 0.230, blue: 0.560)


                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                    
                    GeometryReader { geometry in
                        ZStack {
                            ForEach(0..<150, id: \.self) { _ in
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
                                Color.indigo.opacity(0.35),
                                    .clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 200
                        )
                        .frame(width: 400, height: 400)
                        .offset(x: -105, y: -30)
                        
                        Spacer(minLength: 0.2)
                        
                        RadialGradient(
                            colors: [
                                Color.indigo.opacity(0.25),
                                    .clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 200
                        )
                        .frame(width: 400, height: 400)
                        .offset(x: 95, y: -10)
                    }
                }
                
                if userWords.isEmpty {

                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 48))
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text("Your Word Bank is Empty")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text("Words you practice during song exercises will appear here automatically.")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                } else {
                    ScrollView {
                        HStack (spacing: 5) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Constants.yellow.opacity(0.8))
                                    .shadow(
                                        color: .black.opacity(0.25), radius: 3, x: 1, y: 1
                                    )
                                
                                HStack {
                                    Text("New🐣\n(\(masteryLvlCounts[0]))")
                                        .foregroundColor(.black)
                                        .font(.system(size: 10))
                                }
                                .padding(.horizontal)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical)
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Constants.lavender.opacity(0.8))
                                    .shadow(
                                        color: .black.opacity(0.25), radius: 3, x: 1, y: 1
                                    )
                                
                                HStack {
                                    Text("Learning✍️\n(\(masteryLvlCounts[1]))")
                                        .foregroundColor(.black)
                                        .font(.system(size: 10))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical)
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Constants.blue.opacity(0.8))
                                    .shadow(
                                        color: .black.opacity(0.25), radius: 3, x: 1, y: 1
                                    )
                                
                                HStack {
                                    Text("Familiar🧠\n(\(masteryLvlCounts[2]))")
                                        .foregroundColor(.black)
                                        .font(.system(size: 10))
                                }
                                .padding(.horizontal)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical)
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Constants.green.opacity(0.8))
                                    .shadow(
                                        color: .black.opacity(0.25), radius: 3, x: 1, y: 1
                                    )
                                
                                HStack {
                                    Text("Mastered🔥\n(\(masteryLvlCounts[3]))")
                                        .foregroundColor(.black)
                                        .font(.system(size: 10))
                                }
                                .padding(.vertical, 10)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical)
                        }
                        .padding(.horizontal)
                        .padding(.top, 30)
                        
                        Divider()
                            .overlay(Color.white)
                        
                        ForEach(userWords) { entry in
                            WordRow(entry: entry)
                            Divider()
                                .overlay(Color.white)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Word Bank")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            .task {
                do {
                    let wordBankData = try await NetworkManager.shared.fetchWordBankScreenData()
                    self.userWords = wordBankData.userWordData
                    self.masteryLvlCounts = [0, 0, 0, 0]
                    for wordEntry in self.userWords {
                        let total = wordEntry.numListens + wordEntry.numPracticesCompleted
                        masteryLvlCounts[calculateMasteryLvl(numActivitiesCompleted: total)] += 1
                    }
                } catch {
                    print("WordBank Request failed: \(error)")
                }
            }
        }
    }
}

struct WordRow: View {
    let entry: UserWordEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(entry.word.wordText.capitalized)
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.9))
                
                Text("(\(entry.word.translation ?? ""))")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.horizontal)
            
            Spacer()
            
            VStack(alignment: .trailing) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(getMasteryLvlFillColor(entry))
                        .frame(width: 100, height: 25)
                        .shadow(
                            color: .black.opacity(0.3), radius: 4, x: 3, y: 3
                        )

                    Text("\(Constants.wordsMasteryLvlToMessage[calculateMasteryLvl(numActivitiesCompleted: entry.numListens + entry.numPracticesCompleted)] ?? "Lvl")")
                        .lineLimit(1)
                        .foregroundColor(.black)
                        .font(.system(size: 12))
                }
                
                Label("\(entry.numListens) Listens", systemImage: "headphones.over.ear")
                    .foregroundColor(.white.opacity(0.9))
                Label("\(entry.numPracticesCompleted) Practices", systemImage: "square.and.pencil")
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 10)
    }
}

private func getMasteryLvlFillColor(_ wordEntry: UserWordEntry) -> LinearGradient {
    let masteryLvl = calculateMasteryLvl(numActivitiesCompleted: wordEntry.numListens + wordEntry.numPracticesCompleted)
    let color: LinearGradient = Constants.masteryLvlToFillColor[masteryLvl] ?? Constants.green
    return color
    
}


#Preview {
    WordBank()
}
