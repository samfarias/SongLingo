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
                                color: .black.opacity(0.25), radius: 3, x: 2, y: 2
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
                                color: .black.opacity(0.25), radius: 3, x: 2, y: 2
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
                                color: .black.opacity(0.25), radius: 3, x: 2, y: 2
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
                                color: .black.opacity(0.25), radius: 3, x: 2, y: 2
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
                    let wordBankData = try await fetchWordBankScreenData(userId: "1")
                    self.userWords = wordBankData.userWordData
                    for wordEntry in self.userWords {
                        masteryLvlCounts[calculateMasteryLvl(numActivitiesCompleted: wordEntry.numListens + wordEntry.numPracticesCompleted)
                        ] += 1
                    }
                } catch {
                    print("Request failed: \(error)")
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
                
                Text("(\(entry.word.translation))")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            
            Spacer()
            
            VStack(alignment: .trailing) {
                // Mastery Badge
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Constants.masteryLvlToFillColor[calculateMasteryLvl(numActivitiesCompleted: entry.numListens + entry.numPracticesCompleted)] ?? Constants.green)
                        .frame(width: 100, height: 25)
                        .shadow(
                            color: .black.opacity(0.3), radius: 4, x: 5, y: 5
                        )

                    // Map the Int mastery level back to text
                    Text("\(Constants.wordsMasteryLvlToMessage[calculateMasteryLvl(numActivitiesCompleted: entry.numListens + entry.numPracticesCompleted)] ?? "Lvl")")
                        .lineLimit(1)
                        .foregroundColor(.black)
                        .font(.system(size: 12))
                }
                
                Label("\(entry.numListens) Listens", systemImage: "headphones.over.ear")
                    .font(.system(size: 12))
                    .foregroundColor(.black)
                
                Label("\(entry.numPracticesCompleted) Practices", systemImage: "square.and.pencil")
                    .font(.system(size: 12))
                    .foregroundColor(.black)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 10)
    }
}


#Preview {
    WordBank()
}
