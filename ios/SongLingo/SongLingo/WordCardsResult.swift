//
//  WordCardsResult.swift
//  SongLingo
//
//  Created by Jaci on 5/5/26.
//

import SwiftUI

struct WordCardsResult: View {
    let wordCardsCorrect: Int
    let totalWordCards: Int
    let totalTime: TimeInterval

    var body: some View {
        VStack {
            ZStack {
                PixelHeart()
                    .fill(Color.red)
                    .frame(width: 420, height: 420)
                    .shadow(radius: 4)

                // Mask the text with the heart shape
                VStack(spacing: 10) {
                    Text("Game Over!")
                        .font(.largeTitle)
                        .bold()
                    Text("Correct: \(wordCardsCorrect) / \(totalWordCards)")
                    Text(String(format: "Total Time: %.1f seconds", totalTime))
                }
                .padding(.bottom, 40)
                .frame(width: 250, height: 300) // Match the frame of the heart
            }
            .padding(.top, 30)
            
            HStack(spacing: 20) {
                NavigationLink(destination: PracticeGameOptions()) {
                    ZStack {
                        Rectangle()
                            .fill(Color.red.opacity(0.5))
                            .frame(width: 100, height: 60)
                            .overlay(
                                Rectangle()
                                    .stroke(Color.black, lineWidth: 4)
                            )
                            .cornerRadius(5)

                        Image(systemName: "arrow.uturn.backward")
                            .foregroundColor(.black)
                    }
                }

                NavigationLink(destination: Dashboard()) {
                    ZStack {
                        Rectangle()
                            .fill(Color.red.opacity(0.5))
                            .frame(width: 100, height: 60)
                            .overlay(
                                Rectangle()
                                    .stroke(Color.black, lineWidth: 4)
                            )
                            .cornerRadius(5)

                        Image(systemName: "house.fill")
                            .foregroundColor(.black)
                    }
                }
            }
            .padding(.top, 20)
        }
    }
}

// Preview for testing
#Preview {
    WordCardsResult(wordCardsCorrect: 10, totalWordCards: 40, totalTime: 14.3)
}
