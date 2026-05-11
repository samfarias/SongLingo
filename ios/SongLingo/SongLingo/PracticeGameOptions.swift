//
//  PracticeGameOptions.swift
//  SongLingo
//
//  Created by Jaci on 4/20/26.
//

import SwiftUI

struct PracticeGameOptions: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    //Sends to Word Cards Screen
                    NavigationLink(destination: WordCards())
                    {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.850, green: 0.550, blue: 0.650),
                                        Color(red: 0.750, green: 0.450, blue: 0.550)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .shadow(
                                    color: .black.opacity(0.25), radius: 3, x: 3, y: 3
                                )
                            VStack (alignment: .leading) {
                                Text("Word Cards")
                                    .foregroundStyle(Color.white)
                                    .bold()
                                    .font(.title2)
                                    .shadow(radius: 3, x: 3, y: 3)
                            }
                            .padding(.horizontal)
                            .padding(.vertical)
                        }
                        .padding()
                        .padding(.bottom, 30)
                        
                    }
                    
                    //Sends to Lyric Match Screen
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.400, green: 0.800, blue: 0.650),
                                    Color(red: 0.250, green: 0.650, blue: 0.550)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .shadow(
                                color: .black.opacity(0.25), radius: 3, x: 3, y: 3
                            )
                        VStack (alignment: .leading) {
                            Text("Lyric Match")
                                .foregroundStyle(Color.white)
                                .bold()
                                .font(.title2)
                                .shadow(radius: 3, x: 3, y: 3)
                        }
                        .padding(.horizontal)
                        .padding(.vertical)
                    }
                    .padding()
                    .padding(.bottom, 30)
                    
                    //Sends to Complete the Lyrics Screen
                    NavigationLink(destination: FinishLyrics())
                    {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.600, green: 0.650, blue: 0.900),
                                        Color(red: 0.450, green: 0.500, blue: 0.800)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .shadow(
                                    color: .black.opacity(0.25), radius: 3, x: 3, y: 3
                                )
                            VStack (alignment: .leading) {
                                Text("Complete the Lyrics")
                                    .foregroundStyle(Color.white)
                                    .bold()
                                    .font(.title2)
                                    .shadow(radius: 3, x: 3, y: 3)
                            }
                            .padding(.horizontal)
                            .padding(.vertical)
                        }
                        .padding()
                    }
                }
                .padding(.top, 100)
            }
            .navigationTitle("Practice New Words!")
            .background(LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.450, green: 0.380, blue: 0.650), // Soft Amethyst
                    Color(red: 0.300, green: 0.500, blue: 0.700), // Sky Blue Gray
                    Color(red: 0.250, green: 0.550, blue: 0.450)  // Muted Sage
                ]),
                startPoint: .top,
                endPoint: .bottom
            ))
        }
    }
}

#Preview {
    PracticeGameOptions()
}
