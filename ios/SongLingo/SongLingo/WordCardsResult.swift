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
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.050, green: 0.120, blue: 0.150),
                    Color(red: 0.110, green: 0.440, blue: 0.450),
                    Color(red: 0.376, green: 0.450, blue: 0.450)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                ZStack {
                    PixelHeart()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 420, height: 420)
                        .shadow(radius: 4)
                        .overlay(
                            PixelHeart()
                                .stroke(Color.white.opacity(0.8), lineWidth: 2)
                            )

                    VStack(spacing: 10) {
                        Text("Game Over!")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                            .bold()
                        Text("Correct: \(wordCardsCorrect) / \(totalWordCards)")
                            .foregroundColor(.white)
                        Text(String(format: "Total Time: %.1f seconds", totalTime))
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 40)
                    .frame(width: 250, height: 300)
                }
                .padding(.top, 30)
                
                HStack(spacing: 20) {
                    NavigationLink(destination: PracticeGameOptions()) {
                        ZStack {
                            Rectangle()
                                .fill(Color.white.opacity(0.15))
                                .frame(width: 100, height: 60)
                                .overlay(
                                    Rectangle()
                                        .stroke(Color.white, lineWidth: 4)
                                )
                                .cornerRadius(5)

                            Image(systemName: "arrow.uturn.backward")
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }

                    NavigationLink(destination: Dashboard()) {
                        ZStack {
                            Rectangle()
                                .fill(Color.white.opacity(0.15))
                                .frame(width: 100, height: 60)
                                .overlay(
                                    Rectangle()
                                        .stroke(Color.white, lineWidth: 4)
                                )
                                .cornerRadius(5)

                            Image(systemName: "house.fill")
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                }
                .padding(.top, 20)
                
            }
        }
    }
}

// Preview for testing
#Preview {
    WordCardsResult(wordCardsCorrect: 10, totalWordCards: 40, totalTime: 14.3)
}
