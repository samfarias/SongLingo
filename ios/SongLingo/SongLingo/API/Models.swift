//
//  Models.swift
//  
//
//  Created by Austin Robertson on 4/30/26.
//

import Foundation

// MARK: - MySongs View models
struct MySongsData: Codable {
    let userSongData: [UserSongEntry]

    enum CodingKeys: String, CodingKey {
        case userSongData = "user_song_data"
    }
}

struct UserSongEntry: Codable {
    let song: SongDetails
    let numListens: Int
    let numLyricChallengesCompleted: Int
    let masteryLvl: Int

    enum CodingKeys: String, CodingKey {
        case song
        case numListens = "num_listens"
        case numLyricChallengesCompleted = "num_lyric_challenges_completed"
        case masteryLvl = "mastery_lvl"
    }
}

struct SongDetails: Codable {
    let title: String
    let artist: String

    enum CodingKeys: String, CodingKey {
        case title
        case artist
    }
}

// MARK: - HomeScreen View models
struct HomeScreenData: Codable {
    let userInfo: UserInfo
    let userProgress: UserProgress
    let suggestedPlaylists: SuggestedPlaylists

    enum CodingKeys: String, CodingKey {
        case userInfo = "user_info"
        case userProgress = "user_progress"
        case suggestedPlaylists = "suggested_playlists"
    }
}

struct UserInfo: Codable {
    let id: Int
    let firstName: String
    let lastName: String
    let proficiencyLevel: String
    let userLevel: Int
    let targetLanguage: Int

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case proficiencyLevel = "proficiency_level"
        case userLevel = "user_level"
        case targetLanguage = "target_language"
    }
}

struct UserProgress: Codable {
    let numWordsLearned: Int
    let numSongsCompleted: Int
    let currentStreak: Int

    enum CodingKeys: String, CodingKey {
        case numWordsLearned = "num_words_learned"
        case numSongsCompleted = "num_songs_completed"
        case currentStreak = "current_streak"
    }
}

struct SuggestedPlaylists: Codable {
    let recentlyPlayed: [Playlist]
    let newPlaylist: [Playlist]

    enum CodingKeys: String, CodingKey {
        case recentlyPlayed = "recently_played"
        case newPlaylist = "new_playlist"
    }
}

struct Playlist: Codable {
    let playlistName: String
    let language: Int
    let genre: Int
    let lastDatePlayed: String? // Optional because it can be null
    let createdDate: String
    let proficiencyLevel: String

    enum CodingKeys: String, CodingKey {
        case playlistName = "playlist_name"
        case language, genre
        case lastDatePlayed = "last_date_played"
        case createdDate = "created_date"
        case proficiencyLevel = "proficiency_level"
    }
}
