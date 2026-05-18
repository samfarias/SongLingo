//
//  Models.swift
//
//
//  Created by Austin Robertson on 4/30/26.
//

import Foundation

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
    let joinDate: String?

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case proficiencyLevel = "proficiency_level"
        case userLevel = "user_level"
        case targetLanguage = "target_language"
        case joinDate = "join_date"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName) ?? ""
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName) ?? ""
        proficiencyLevel = try container.decode(String.self, forKey: .proficiencyLevel)
        userLevel = try container.decode(Int.self, forKey: .userLevel)
        targetLanguage = try container.decode(Int.self, forKey: .targetLanguage)
        joinDate = try container.decodeIfPresent(String.self, forKey: .joinDate)
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
    
    var allSuggestedPlaylists: [Playlist] {
        recentlyPlayed + newPlaylist
    }

    enum CodingKeys: String, CodingKey {
        case recentlyPlayed = "recently_played"
        case newPlaylist = "new_playlist"
    }
}

struct Playlist: Codable, Identifiable {
    let id: Int
    let playlistName: String
    let language: Int
    let genre: Int?
    let lastDatePlayed: String? // Optional because it can be null
    let createdDate: String
    let proficiencyLevel: String

    enum CodingKeys: String, CodingKey {
        case id
        case playlistName = "playlist_name"
        case language, genre
        case lastDatePlayed = "last_date_played"
        case createdDate = "created_date"
        case proficiencyLevel = "proficiency_level"
    }
}


// MARK: - MySongs View models
struct MySongsData: Codable {
    let userSongData: [UserSongEntry]

    enum CodingKeys: String, CodingKey {
        case userSongData = "user_song_data"
    }
}

struct UserSongEntry: Codable, Identifiable {
    // This allows SwiftUI to distinguish between different song rows
    var id: String { song.title + song.artist }
    
    let song: SongDetails
    let numListens: Int?
    let numLyricChallengesCompleted: Int?
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

// MARK: - LearnedWords View models

struct WordBankData: Codable {
    let userWordData: [UserWordEntry]

    enum CodingKeys: String, CodingKey {
        case userWordData = "user_word_data"
    }
}

struct UserWordEntry: Codable, Identifiable {
    // Computed property to satisfy Identifiable
    // Since word_text should be unique in a vocabulary list, it makes a good ID
    var id: String { word.wordText }
    
    let word: WordDetails
    let numListens: Int
    let numPracticesCompleted: Int
    let masteryLvl: Int

    enum CodingKeys: String, CodingKey {
        case word
        case numListens = "num_listens"
        case numPracticesCompleted = "num_practices_completed"
        case masteryLvl = "mastery_lvl"
    }
}

struct WordDetails: Codable {
    let wordText: String
    let translation: String?

    enum CodingKeys: String, CodingKey {
        case wordText = "word_text"
        case translation
    }
}

// MARK: - UserActivity View models

struct UserActivityData: Codable {
    let streakInfo: StreakInfo
    let daysActive: [ActiveDate]
    
    // Computed property for easy access
    var activeDatesSet: Set<String> {
        var dateSet: Set<String> = []
        for date in daysActive {
            dateSet.insert(date.date)
        }
        return dateSet
    }

    enum CodingKeys: String, CodingKey {
        case streakInfo = "streak_info"
        case daysActive = "days_active"
    }
}

struct StreakInfo: Codable {
    let userProfile: Int
    let currentStreak: Int
    let longestStreak: Int

    enum CodingKeys: String, CodingKey {
        case userProfile = "user_profile"
        case currentStreak = "current_streak"
        case longestStreak = "longest_streak"
    }
}

struct ActiveDate: Codable, Identifiable, Hashable {
    // Using the date string as the ID for SwiftUI list rendering
    var id: String { date }
    let date: String

    enum CodingKeys: String, CodingKey {
        case date
    }
}


// MARK: - Word Card Exercise Models
struct WordCardExerciseData: Codable {
    let practiceWords: [PracticeWord]
    let wordDistractors: [[String]]

    enum CodingKeys: String, CodingKey {
        case practiceWords = "practice_words"
        case wordDistractors = "word_distractors"
    }
}

struct PracticeWord: Codable {
    let wordText: String
    let translation: String?
    let pronunciation: String?
    let definition: String

    enum CodingKeys: String, CodingKey {
        case wordText = "word_text"
        case translation, pronunciation, definition
    }
}

// MARK: - Complete the Lyric Exercise Models
struct LyricChallengeData: Codable {
    let songId: Int
    let lyric: String
    let missingWord: String
    let distractorWords: [String]
    let songTitle: String
    let songArtist: String
    
    var buttonOptions: [String] {
        (distractorWords + [missingWord]).shuffled()
    }
    
    enum CodingKeys: String, CodingKey {
        case songId = "song_id"
        case lyric
        case missingWord = "missing_word"
        case distractorWords = "distractor_words"
        case songTitle = "song_title"
        case songArtist = "song_artist"
    }
}

// MARK: - Playlist Collection View models

struct PlaylistCollectionData: Codable {
    let playlistCollections: PlaylistCollections

    enum CodingKeys: String, CodingKey {
        case playlistCollections = "playlist_collections"
    }
}

struct PlaylistCollections: Codable {
    let recentlyPlayed: [Playlist]
    let newPlaylists: [Playlist]
    let itsBeenAWhile: [Playlist]

    enum CodingKeys: String, CodingKey {
        case recentlyPlayed = "recently_played"
        case newPlaylists = "new_playlists"
        case itsBeenAWhile = "its_been_a_while"
    }
}

// MARK: - Lyric Matching Exercise Models

struct LyricMatchingData: Codable {
    let lineToDisplay: String
    let lineToMatch: String
    let songTitle: String
    let songArtist: String
    let audioBase64: String

    enum CodingKeys: String, CodingKey {
        case lineToDisplay = "line_to_display"
        case lineToMatch = "line_to_match"
        case songTitle = "song_title"
        case songArtist = "song_artist"
        case audioBase64 = "audio_base64"
    }
}

// MARK: - SinglePlaylist View models

struct SinglePlaylistData: Codable {
    let playlistInfo: DetailedPlaylistInfo
    let playlistSongs: [PlaylistSongEntry]

    enum CodingKeys: String, CodingKey {
        case playlistInfo = "playlist_info"
        case playlistSongs = "playlist_songs"
    }
}

struct DetailedPlaylistInfo: Codable {
    let id: Int
    let playlistName: String
    let description: String
    let lastDatePlayed: String?
    let numDaysListened: Int
    let numSongListens: Int
    let createdDate: String
    let proficiencyLevel: String
    let userProfile: Int
    let language: Int
    let genre: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case playlistName = "playlist_name"
        case description
        case lastDatePlayed = "last_date_played"
        case numDaysListened = "num_days_listened"
        case numSongListens = "num_song_listens"
        case createdDate = "created_date"
        case proficiencyLevel = "proficiency_level"
        case userProfile = "user_profile"
        case language, genre
    }
}

struct PlaylistSongEntry: Codable, Identifiable {
    // Unique ID for SwiftUI rendering
    var id: String { song.title + song.artist }
    
    let song: DetailedSong
}

struct DetailedSong: Codable {
    let title: String
    let artist: String
    let proficiencyLevel: String
    let genre: Int

    enum CodingKeys: String, CodingKey {
        case title, artist, genre
        case proficiencyLevel = "proficiency_level"
    }
}
