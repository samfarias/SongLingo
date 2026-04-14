//
//  Login.swift
//  SongLingo
//
//  Created by Derek Huang on 3/30/26.
//

import SwiftUI

struct LanguageSelectionView: View {
    @State private var selectedLanguage: Int? = nil

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    let languages = [
        (name: "Spanish", image: "Spain"),
        (name: "Greek", image: "Greece"),
        (name: "Japanese", image: "Japan"),
        (name: "French", image: "France")
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.984, green: 0.443, blue: 0.522),
                    Color(red: 0.576, green: 0.200, blue: 0.918),
                    Color(red: 0.231, green: 0.027, blue: 0.392)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 22) {
                Spacer()

                VStack(spacing: 6) {
                    Text("♪ SongLingo")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)

                    Text("Learn languages through the music you love")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.95))
                }

                VStack(spacing: 18) {
                    VStack(spacing: 6) {
                        Text("Which language do you want to learn?")
                            .font(.system(size: 18, weight: .bold))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 260)

                        Text("Choose your target language")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }

                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(0..<languages.count, id: \.self) { index in
                            Button {
                                selectedLanguage = index
                            } label: {
                                VStack(spacing: 8) {
                                    Image(languages[index].image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 58, height: 40)

                                    Text(languages[index].name)
                                        .font(.system(size: 13))
                                        .foregroundColor(.black)
                                }
                                .frame(width: 130, height: 92)
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(
                                            selectedLanguage == index
                                            ? Color(red: 0.486, green: 0.227, blue: 0.929)
                                            : Color.gray.opacity(0.35),
                                            lineWidth: selectedLanguage == index ? 2 : 1
                                        )
                                )
                                .cornerRadius(14)
                            }
                        }
                    }

                    Button("Continue") {
                        print("Continue tapped")
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .frame(width: 240, height: 44)
                    .background(Color(red: 0.486, green: 0.227, blue: 0.929))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.18), radius: 4, x: 0, y: 3)
                    .padding(.top, 6)
                }
                .padding(.vertical, 26)
                .padding(.horizontal, 22)
                .background(Color.white.opacity(0.95))
                .cornerRadius(28)
                .padding(.horizontal, 34)

                Spacer()
            }
            .padding(.vertical, 30)
        }
    }
}

#Preview {
    LanguageSelectionView()
}
