//
//  FinishLyricsResults.swift
//  SongLingo
//
//  Created by Jaci on 5/5/26.
//

import SwiftUI

struct FinishLyricsResults: View {
    
    let totalTime: TimeInterval
    let correctAnswers: Int
    let totalQuestions: Int

    var performanceMessage: String {
        switch correctAnswers {
        case 0..<2:
            return "Good try! Keep Practicing!"
        case 2..<5:
            return "Nice work! You're learning!"
        default:
            return "Amazing!"
        }
    }

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
                Spacer()
                
                VStack(spacing: 20) {
                    Text(performanceMessage)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Text("Time Spent: \(String(format: "%.2f", totalTime)) seconds")
                        .foregroundColor(.white)
                    Text("Correct Answers: \(correctAnswers) / \(totalQuestions)")
                        .foregroundColor(.white)
                    Text("")
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white, lineWidth: 4)
                    )
                .background(Color.white.opacity(0.15))
                .cornerRadius(10)
                .padding(.horizontal, 20)

                
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
                .padding(.top, 30)
                
                Spacer()
            }
        }
    }
}

#Preview {
    FinishLyricsResults(totalTime: 45.67, correctAnswers: 6, totalQuestions: 6)
}
