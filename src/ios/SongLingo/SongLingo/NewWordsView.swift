//
//  NewWordsView.swift
//  SongLingo
//
//  Created by Derek Huang on 5/11/26.
//

import SwiftUI

private struct MockWord: Identifiable, Equatable {
    let id = UUID()
    let term: String
    let pronunciation: String
    let breakdown: [String]
}

struct NewWordsView: View {
    @Environment(\.dismiss) private var dismiss

    // Mock data
    private let words: [MockWord] = [
        MockWord(term: "Bailar", pronunciation: "[sound-icon] bah-ee-LAR", breakdown: [
            "bai → like \"bye\" but a bit softer",
            "LAR → with a light, quick tapped \"r\" (not a strong English \"r\")"
        ]),
        MockWord(term: "Comer", pronunciation: "[sound-icon] koh-MAIR", breakdown: [
            "co → like \"co\" in \"cocoa\"",
            "mer → like \"mare\" with a soft \"r\""
        ]),
        MockWord(term: "Hablar", pronunciation: "[sound-icon] ahb-LAR", breakdown: [
            "ha → silent \"h\"",
            "blar → quick \"bl\" and tapped \"r\""
        ])
    ]

    @State private var currentIndex: Int = 0
    @State private var knownCount: Int = 0
    @State private var finished: Bool = false

    private var totalCount: Int { words.count }
    private var remainingCount: Int { max(totalCount - knownCount, 0) }
    private var progress: Double { totalCount == 0 ? 0 : Double(knownCount) / Double(totalCount) }

    var body: some View {
        NavigationStack {
            Group {
                if finished {
                    finishView
                } else {
                    contentView
                }
            }
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

    private var contentView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("\(knownCount) known")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                Spacer()
                Text("\(remainingCount) to review")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
            }

            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .foregroundColor(.white.opacity(0.8))

            let word = words[currentIndex]
            VStack(spacing: 12) {
                Text(word.term)
                    .font(.largeTitle.weight(.semibold))
                    .foregroundColor(.white.opacity(0.9))

                HStack(spacing: 8) {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundStyle(.blue)
                    Text(word.pronunciation)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                }

                Divider()
                    .foregroundColor(.white.opacity(0.9))

                VStack(alignment: .leading, spacing: 8) {
                    Text("Breakdown :")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                    ForEach(word.breakdown, id: \.self) { item in
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                                .foregroundColor(.white.opacity(0.9))
                            Text(item)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .padding(.top, 40)

            Button(action: handleGotIt) {
                Text("Got it!")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.green.opacity(0.8))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .accessibilityIdentifier("gotItButton")
            .padding(.top, 30)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(24)
    }

    private var finishView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)
            Text("All finished!")
                .font(.largeTitle.weight(.semibold))
            Text("You've reviewed \(totalCount) words.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Button {
                dismiss()
            } label: {
                Text("Back to Dashboard")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .padding(24)
    }

    private func handleGotIt() {
        if knownCount < totalCount { knownCount += 1 }

        if currentIndex + 1 < totalCount {
            currentIndex += 1
        } else {
            finished = true
        }
    }
}

#Preview {
    NewWordsView()
}
