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
        case 0..<3:
            return "Good try! Keep Practicing!"
        case 3..<8:
            return "Nice work! You're learning!"
        default:
            return "Amazing!"
        }
    }

    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 20) {
                Text(performanceMessage)
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding()
                
                Text("Time Spent: \(String(format: "%.2f", totalTime)) seconds")
                Text("Correct Answers: \(correctAnswers) / \(totalQuestions)")
                Text("")
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, lineWidth: 4)
                )
            .background(Color.blue.opacity(0.5))
            .cornerRadius(10)
            .padding(.horizontal, 20)

            
            HStack(spacing: 20) {
                NavigationLink(destination: PracticeGameOptions()) {
                    ZStack {
                        Rectangle()
                            .fill(Color.blue.opacity(0.5))
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
                            .fill(Color.blue.opacity(0.5))
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
            .padding(.top, 30)
            
            Spacer()
        }
    }
}

#Preview {
    FinishLyricsResults(totalTime: 45.67, correctAnswers: 7, totalQuestions: 10)
}
