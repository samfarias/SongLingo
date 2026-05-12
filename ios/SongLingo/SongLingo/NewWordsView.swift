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
        }
    }

    private var contentView: some View {
        VStack(spacing: 16) {
            // Top bar: known on left, remaining on right, with progress bar under
            HStack {
                Text("\(knownCount) known")
                    .font(.subheadline)
                Spacer()
                Text("\(remainingCount) to review")
                    .font(.subheadline)
            }

            ProgressView(value: progress)
                .progressViewStyle(.linear)

            // Card with word details
            let word = words[currentIndex]
            VStack(spacing: 12) {
                Text(word.term)
                    .font(.largeTitle.weight(.semibold))

                // Sound icon + pronunciation (mock)
                HStack(spacing: 8) {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundStyle(.blue)
                    Text(word.pronunciation)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Breakdown :")
                        .font(.headline)
                    ForEach(word.breakdown, id: \.self) { item in
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                            Text(item)
                                .multilineTextAlignment(.leading)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .padding(.top, 40)

            Button(action: handleGotIt) {
                Text("Got it!")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.green)
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
                // Navigate back to dashboard
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
        // Increment known and advance to next word
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
