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
    
    // APP COLORS
    static let blue: LinearGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.64, green: 0.75, blue: 0.95), // Light Cornflower
            Color(red: 0.50, green: 0.62, blue: 0.88)  // Medium Cornflower
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let lavender: LinearGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.80, green: 0.75, blue: 0.95), // Light Airy Lavender
            Color(red: 0.68, green: 0.62, blue: 0.88)  // Medium Dusty Lavender
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let sunburst: LinearGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 1.00, green: 0.78, blue: 0.45), // Softened Mango
            Color(red: 0.98, green: 0.55, blue: 0.45)  // Gentle Coral
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let orange: LinearGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 1.00, green: 0.78, blue: 0.45), // Softened Mango
            Color(red: 0.98, green: 0.55, blue: 0.45)  // Gentle Coral
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let mint: LinearGradient = LinearGradient(
        colors: [
            Color(red: 0.70, green: 0.90, blue: 0.82),
            Color(red: 0.55, green: 0.80, blue: 0.70)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let red: LinearGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.96, green: 0.67, blue: 0.67), // The Middle Petal
            Color(red: 0.90, green: 0.50, blue: 0.54), // The Middle Coral
            Color(red: 0.80, green: 0.38, blue: 0.42)  // The Middle Rosewood
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
