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
    static let languageIdToName: [Int: String] = [1: "Spanish", 2: "German", 3: "French", 4: "Japanese", 5: "Greek"]
    
    static let songsMasteryLvlToMessage: [Int: String] = [0: "New🎵", 1: "Experimenting🤔", 2: "Fan🧑‍🎤", 3: "Your Jam🔥"]
    static let wordsMasteryLvlToMessage: [Int: String] = [0: "New🐣", 1: "Learning✍️", 2: "Familiar🧠", 3: "Mastered🔥"]
    static let masteryLvlToFillColor: [Int: LinearGradient] = [0: yellow, 1: lavender, 2: blue, 3: green]
    
    static let genreIdToName: [Int: String] = [
            1: "Indie-Alternative",
            2: "Tropical",
            3: "Pop",
            4: "Rock",
            5: "Reggaeton-Urbano",
            6: "Regional-Mexican"
        ]
    
    // -- MARK: ELEMENT COLORS
    static let blue: LinearGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.64, green: 0.75, blue: 0.95),
            Color(red: 0.50, green: 0.62, blue: 0.88)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let lavender: LinearGradient = LinearGradient(
        gradient: Gradient(
            colors: [
                Color(red: 0.75, green: 0.15, blue: 0.55),
                Color(red: 0.78, green: 0.22, blue: 0.78),
                Color(red: 0.75, green: 0.15, blue: 0.55)
            ]),
            startPoint: .leading,
            endPoint: .trailing
    )
    
    static let sunburst: LinearGradient = LinearGradient(
        gradient: Gradient(
            colors: [
                Color(red: 0.90, green: 0.05, blue: 0.35),
                Color(red: 0.88, green: 0.35, blue: 0.25),
                Color(red: 0.90, green: 0.15, blue: 0.35)
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
    
    static let gold: LinearGradient = LinearGradient(
        colors: [
            Color(red: 1.00, green: 0.93, blue: 0.65),
            Color(red: 0.90, green: 0.78, blue: 0.50)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let green: LinearGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.55, green: 0.85, blue: 0.65),
            Color(red: 0.35, green: 0.70, blue: 0.50)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let yellow: LinearGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 1.00, green: 0.94, blue: 0.65),
            Color(red: 0.98, green: 0.85, blue: 0.45)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let red: LinearGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.96, green: 0.67, blue: 0.67),
            Color(red: 0.90, green: 0.50, blue: 0.54),
            Color(red: 0.80, green: 0.38, blue: 0.42)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // -- MARK: BACKGROUND GRADIENTS
    static let coastal_mist: LinearGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 1.00, green: 0.88, blue: 0.85),
            Color(red: 0.90, green: 0.92, blue: 0.95),
            Color(red: 0.82, green: 0.95, blue: 0.92)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let amber_tide: LinearGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 1.00, green: 0.94, blue: 0.85),
            Color(red: 0.93, green: 0.91, blue: 0.93),
            Color(red: 0.82, green: 0.85, blue: 0.98)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let sunset_horizon: LinearGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 1.00, green: 0.85, blue: 0.85),
            Color(red: 0.94, green: 0.88, blue: 0.92),
            Color(red: 0.85, green: 0.80, blue: 0.95)
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let arctic_dawn: LinearGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.85, green: 0.97, blue: 0.93),
            Color(red: 0.90, green: 0.92, blue: 0.96),
            Color(red: 0.82, green: 0.82, blue: 0.97) 
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let butterfly: LinearGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.150, green: 0.250, blue: 0.650),
            Color(red: 0.700, green: 0.225, blue: 0.520),
            Color(red: 0.850, green: 0.455, blue: 0.250),
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let twilight_synth: LinearGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.450, green: 0.380, blue: 0.650),
            Color(red: 0.300, green: 0.500, blue: 0.700),
            Color(red: 0.250, green: 0.550, blue: 0.450)
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
}
