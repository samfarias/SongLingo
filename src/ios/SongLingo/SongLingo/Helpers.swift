//
//  Helpers.swift
//  SongLingo
//
//  Created by Austin Robertson on 4/30/26.
//

import SwiftUI

func calculateMasteryLvl(numActivitiesCompleted: Int) -> Int {
    if (numActivitiesCompleted <= 5) {
        return 0;
    } else if (numActivitiesCompleted > 5 && numActivitiesCompleted <= 15) {
        return 1;
    } else if (numActivitiesCompleted > 15 && numActivitiesCompleted <= 45) {
        return 2;
    } else {
        return 3;
    }
}

func getMasteryLvlFillColor(numActivitiesCompleted: Int) -> LinearGradient {
    if (numActivitiesCompleted <= 5) {
        return Constants.yellow;
    } else if (numActivitiesCompleted > 5 && numActivitiesCompleted <= 15) {
        return Constants.lavender;
    } else if (numActivitiesCompleted > 15 && numActivitiesCompleted <= 45) {
        return Constants.blue;
    } else {
        return Constants.green;
    }
}

func spanishToEnglishPhonetic(_ word: String) -> String {
    let vowels: Set<Character> = ["a", "e", "i", "o", "u", "á", "é", "í", "ó", "ú", "ü"]
    let chars = Array(word.lowercased())
    var sounds: [String] = []
    var i = 0

    while i < chars.count {
        if i + 1 < chars.count {
            let pair = String(chars[i]) + String(chars[i + 1])
            if pair == "ch" { sounds.append("ch"); i += 2; continue }
            if pair == "ll" { sounds.append("y"); i += 2; continue }
            if pair == "rr" { sounds.append("rr"); i += 2; continue }
            if pair == "qu" && i + 2 < chars.count && (chars[i + 2] == "e" || chars[i + 2] == "i") {
                sounds.append("k"); i += 2; continue
            }
        }

        let c = chars[i]
        if vowels.contains(c) {
            switch c {
            case "a", "á": sounds.append("ah")
            case "e", "é": sounds.append("eh")
            case "i", "í": sounds.append("ee")
            case "o", "ó": sounds.append("oh")
            case "u", "ú", "ü": sounds.append("oo")
            default: break
            }
        } else {
            switch c {
            case "b", "v": sounds.append("b")
            case "c":
                if i + 1 < chars.count && (chars[i + 1] == "e" || chars[i + 1] == "i") {
                    sounds.append("s")
                } else { sounds.append("k") }
            case "d": sounds.append("d")
            case "f": sounds.append("f")
            case "g":
                if i + 1 < chars.count && (chars[i + 1] == "e" || chars[i + 1] == "i") {
                    sounds.append("h")
                } else { sounds.append("g") }
            case "h": break
            case "j": sounds.append("h")
            case "k": sounds.append("k")
            case "l": sounds.append("l")
            case "m": sounds.append("m")
            case "n": sounds.append("n")
            case "ñ": sounds.append("ny")
            case "p": sounds.append("p")
            case "r": sounds.append("r")
            case "s": sounds.append("s")
            case "t": sounds.append("t")
            case "w": sounds.append("w")
            case "x": sounds.append("ks")
            case "y":
                if i == chars.count - 1 { sounds.append("ee") }
                else { sounds.append("y") }
            case "z": sounds.append("s")
            default: sounds.append(String(c))
            }
        }
        i += 1
    }

    let vowelSounds: Set<String> = ["ah", "eh", "ee", "oh", "oo"]
    var syllables: [String] = []
    var current = ""

    for sound in sounds {
        if vowelSounds.contains(sound) {
            current += sound
            syllables.append(current)
            current = ""
        } else {
            current += sound
        }
    }
    if !current.isEmpty {
        if syllables.isEmpty {
            syllables.append(current)
        } else {
            syllables[syllables.count - 1] += current
        }
    }

    return syllables.joined(separator: "-")
}

private struct ITunesSearchResponse: Codable {
    let results: [ITunesTrack]
}

private struct ITunesTrack: Codable {
    let previewUrl: String?
}

func fetchITunesPreviewURL(title: String, artist: String) async -> URL? {
    let query = "\(title) \(artist)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    guard let url = URL(string: "https://itunes.apple.com/search?term=\(query)&media=music&limit=3") else {
        return nil
    }

    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        let result = try JSONDecoder().decode(ITunesSearchResponse.self, from: data)
        if let previewUrlString = result.results.first?.previewUrl {
            return URL(string: previewUrlString)
        }
    } catch {
        print("iTunes preview search failed: \(error)")
    }
    return nil
}

func openInSpotify(title: String, artist: String, spotifyId: String? = nil) {
    if let spotifyId = spotifyId, !spotifyId.isEmpty {
        let trackAppURL = URL(string: "spotify:track:\(spotifyId)")!
        let trackWebURL = URL(string: "https://open.spotify.com/track/\(spotifyId)")!
        if UIApplication.shared.canOpenURL(trackAppURL) {
            UIApplication.shared.open(trackAppURL)
        } else {
            UIApplication.shared.open(trackWebURL)
        }
        return
    }

    let query = "\(title) \(artist)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    let spotifyAppURL = URL(string: "spotify:search:\(query)")!
    let spotifyWebURL = URL(string: "https://open.spotify.com/search/\(query)")!

    if UIApplication.shared.canOpenURL(spotifyAppURL) {
        UIApplication.shared.open(spotifyAppURL)
    } else {
        UIApplication.shared.open(spotifyWebURL)
    }
}

func documentsDirectory() -> URL {
    let paths = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask)
    return paths[0]
}
func dataFilePath() -> URL {
    return documentsDirectory().appendingPathComponent("SongLingo.plist")
}
