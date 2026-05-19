//
//  PracticeGameOptions.swift
//  SongLingo
//
//  Created by Jaci on 4/20/26.
//

import SwiftUI

struct PracticeGameOptions: View {
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .foregroundColor: UIColor(white: 1, alpha: 0.8)
        ]
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    //Sends to Word Cards Screen
                    NavigationLink(destination: WordCards())
                    {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.2))
                            VStack (alignment: .leading) {
                                Text("Word Cards")
                                    .foregroundStyle(Color.white.opacity(0.8))
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
                    NavigationLink(destination: LyricMatchView())
                    {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.2))
                                .shadow(
                                    color: .black.opacity(0.25), radius: 3, x: 3, y: 3
                                )
                            VStack (alignment: .leading) {
                                Text("Lyric Match")
                                    .foregroundStyle(Color.white.opacity(0.8))
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

                    //Sends to Complete the Lyrics Screen
                    NavigationLink(destination: FinishLyrics())
                    {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.2))
                            VStack (alignment: .leading) {
                                Text("Complete the Lyrics")
                                    .foregroundStyle(Color.white.opacity(0.8))
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
            .foregroundStyle(Color.white.opacity(0.8))
            .navigationTitle("Practice New Words!")
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
        }
    }
}

#Preview {
    PracticeGameOptions()
}
