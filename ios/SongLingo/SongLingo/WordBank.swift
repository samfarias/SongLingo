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
            ScrollView {
                HStack (spacing: 5) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Constants.yellow)
                            .shadow(
                                color: .black.opacity(0.25), radius: 3, x: 1, y: 1
                            )
                        
                        HStack {
                            Text("New🐣 (\(masteryLvlCounts[0]))")
                                .lineLimit(1)
                                .foregroundColor(.black)
                                .font(.system(size: 12))
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Constants.lavender)
                            .shadow(
                                color: .black.opacity(0.25), radius: 3, x: 1, y: 1
                            )
                        
                        HStack {
                            Text("Learning✍️ (\(masteryLvlCounts[1]))")
                                .lineLimit(1)
                                .foregroundColor(.black)
                                .font(.system(size: 12))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Constants.blue)
                            .shadow(
                                color: .black.opacity(0.25), radius: 3, x: 1, y: 1
                            )
                        
                        HStack {
                            Text("Familiar🧠 (\(masteryLvlCounts[2]))")
                                .lineLimit(1)
                                .foregroundColor(.black)
                                .font(.system(size: 12))
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Constants.green)
                            .shadow(
                                color: .black.opacity(0.25), radius: 3, x: 1, y: 1
                            )
                        
                        HStack {
                            Text("Mastered🔥 (\(masteryLvlCounts[3]))")
                                .lineLimit(1)
                                .foregroundColor(.black)
                                .font(.system(size: 12))
                        }
                        .padding(.vertical, 10)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                }
                .padding(.horizontal)
                
                Divider()
                    .overlay(Color.black)
                
                // Dynamic List of Songs
                ForEach(userWords) { entry in
                    WordRow(entry: entry)
                    Divider().overlay(Color.black)
                }
                
            }
            .navigationTitle("Word Bank")
            .background(Constants.amber_tide)
            .task {
                do {
                    // FIX: Removed the unused userID line here
                    let wordBankData = try await NetworkManager.shared.fetchWordBankScreenData()
                    self.userWords = wordBankData.userWordData
                    self.masteryLvlCounts = [0, 0, 0, 0] //rsets count so dnot double up if view reloads
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
                Text(entry.word.wordText)
                    .font(.title2)
                    .foregroundColor(.black)
                
                Text("(\(entry.word.translation ?? ""))")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            
            Spacer()
            
            VStack(alignment: .trailing) {
                // Mastery Badge
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(getMasteryLvlFillColor(entry))
                        .frame(width: 100, height: 25)
                        .shadow(
                            color: .black.opacity(0.3), radius: 4, x: 3, y: 3
                        )

                    // Map the Int mastery level back to text
                    Text("\(Constants.wordsMasteryLvlToMessage[calculateMasteryLvl(numActivitiesCompleted: entry.numListens + entry.numPracticesCompleted)] ?? "Lvl")")
                        .lineLimit(1)
                        .foregroundColor(.black)
                        .font(.system(size: 12))
                }
                
                Label("\(entry.numListens) Listens", systemImage: "headphones.over.ear")
                Label("\(entry.numPracticesCompleted) Practices", systemImage: "square.and.pencil")
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
