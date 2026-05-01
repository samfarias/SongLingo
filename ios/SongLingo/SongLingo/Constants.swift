//
//  Constants.swift
//  SongLingo
//
//  Created by Jaci on 3/10/26.
//

import Foundation
import SwiftUI

struct Constants
{
    //Navigation bar titles.
    static let homeString = "Home"
    static let playlistString = "My Playlists"
    static let profileString = "Profile"
    
    //Navigation bar icons.
    static let homeIcon = "house"
    static let playlistIcon = "music.note"
    static let profileIcon = "person.crop.circle"
    
    // Language id -> Language name
    static let languageIdToName: [Int: String] = [0: "Language Name", 3: "German", 4: "Spanish", 5: "English"]
    
    static let songsMasteryLvlToMessage: [Int: String] = [0: "New🎵", 1: "Experimenting🤔", 2: "Fan🧑‍🎤", 3: "Your Jam🔥"]
    static let wordsMasteryLvlToMessage: [Int: String] = [0: "New🐣", 1: "Learning✍️", 2: "Familiar🧠", 3: "Mastered🔥"]
    static let masteryLvlToFillColor: [Int: Color] = [0: Color.yellow.opacity(0.5), 1: Color.purple.opacity(0.4), 2: Color.blue.opacity(0.4), 3: Color.green.opacity(0.6)]
    
    static let genreIdToName: [Int: String] = [1: "Indie", 2: "Alternative", 3: "Pop", 4: "EDM", 5: "Indie/Folk", 6: "Folk", 7: "Pop/Folk", 8: "Metal", 9: "Electronic", 10: "Pop/Soundtrack", 11: "Indie/Alternative"]
}
