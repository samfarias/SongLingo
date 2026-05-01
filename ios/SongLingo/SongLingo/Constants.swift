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
    
    static let masteryLvlToMessage: [Int: String] = [0: "New🎵", 1: "Experimenting🤔", 2: "Fan🧑‍🎤", 3: "Your Jam🔥"]
    static let masteryLvlToFillColor: [Int: Color] = [0: Color.yellow.opacity(0.5), 1: Color.purple.opacity(0.4), 2: Color.blue.opacity(0.4), 3: Color.green.opacity(0.6)]
}
