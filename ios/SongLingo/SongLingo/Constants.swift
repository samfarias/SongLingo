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
    static let masteryLvlToFillColor: [Int: LinearGradient] = [0: yellow, 1: lavender, 2: blue, 3: green]
    
    static let genreIdToName: [Int: String] = [1: "Indie", 2: "Alternative", 3: "Pop", 4: "EDM", 5: "Indie/Folk", 6: "Folk", 7: "Pop/Folk", 8: "Metal", 9: "Electronic", 10: "Pop/Soundtrack", 11: "Indie/Alternative"]
    
    // -- MARK: ELEMENT COLORS
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
    
    static let mint: LinearGradient = LinearGradient(
        colors: [
            Color(red: 0.70, green: 0.90, blue: 0.82),
            Color(red: 0.55, green: 0.80, blue: 0.70)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let green: LinearGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.55, green: 0.85, blue: 0.65), // Lush Amazonite
            Color(red: 0.35, green: 0.70, blue: 0.50)  // Deep Jade
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let yellow: LinearGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 1.00, green: 0.94, blue: 0.65), // Buttery Silk
            Color(red: 0.98, green: 0.85, blue: 0.45)  // Softened Amber
        ]),
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
    
    // -- MARK: BACKGROUND GRADIENTS
    static let coastal_mist: LinearGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 1.00, green: 0.88, blue: 0.85), // Peach Fuzz
            Color(red: 0.90, green: 0.92, blue: 0.95), // Silver Mist
            Color(red: 0.82, green: 0.95, blue: 0.92)  // Seafoam Glow
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let amber_tide: LinearGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 1.00, green: 0.94, blue: 0.85), // Pale Amber
            Color(red: 0.93, green: 0.91, blue: 0.93), // Sandstone Mist
            Color(red: 0.82, green: 0.85, blue: 0.98)  // Periwinkle Glow
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let sunset_horizon: LinearGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 1.00, green: 0.85, blue: 0.85), // Soft Coral/Peach
            Color(red: 0.94, green: 0.88, blue: 0.92), // Dusty Rose Bridge
            Color(red: 0.85, green: 0.80, blue: 0.95)  // Soft Lilac/Purple
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let arctic_dawn: LinearGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.85, green: 0.97, blue: 0.93), // Mint (Lifted)
            Color(red: 0.90, green: 0.92, blue: 0.96), // Frozen Silver Bridge
            Color(red: 0.82, green: 0.82, blue: 0.97)  // Periwinkle (Lifted)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
