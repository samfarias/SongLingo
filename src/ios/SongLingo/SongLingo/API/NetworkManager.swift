import Foundation

// MARK: - Response Models

// Jaci's model for the Word Cards / FastMCP
struct PronunciationResponse: Codable {
    let word: String
    let phonetic: String
    let audio: String
}

// Austin's placeholder model for the Home Screen
struct HomeDataResponse: Codable {
    // can expand this to match whatever your Django /api/home/ returns later
    let message: String?
}

struct DjangoError: Codable {
    let detail: String?
    let username: [String]?
    let password: [String]?
    let non_field_errors: [String]?
}

enum APIError: LocalizedError {
    case serverMessage(String)

    var errorDescription: String? {
        switch self {
        case .serverMessage(let message): return message
        }
    }
}

// MARK: - Network Manager

class NetworkManager {
    
    // the one Instance so the entire app shares one manager
    static let shared = NetworkManager()
    
    // Our Live DigitalOcean Server is ACTIVE
    private let baseURL = "http://68.183.31.175/api"
    
    // Localhost is COMMENTED OUT (Use this only when testing the backend on your Mac)
//     private let baseURL = "http://localhost:8000/api"
    
    // Prevents anyone else from creating another instance
    private init() {}
    
    //-----logging in
    // Template
    struct LoginResponse: Codable {
        let user_id: Int
        let access: String
        let refresh: String
    }

    // the lil engine
    func login(username: String, password: String) async throws -> LoginResponse {
        guard let url = URL(string: "\(baseURL)/login/") else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "username": username,
            "password": password
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if !(200...299).contains(httpResponse.statusCode) {
            var errorMessage = "Login failed. Please check your information."

            if let decoded = try? JSONDecoder().decode(DjangoError.self, from: data) {
                if let detail = decoded.detail {
                    errorMessage = detail
                } else if let general = decoded.non_field_errors?.first {
                    errorMessage = general
                } else if let userErr = decoded.username?.first {
                    errorMessage = userErr
                }
            }

            throw APIError.serverMessage(errorMessage)
        }

        let decodedResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                
        UserDefaults.standard.set(decodedResponse.access, forKey: "jwt_access_token")
                
        UserDefaults.standard.set(String(decodedResponse.user_id), forKey: "user_id")
                
        return decodedResponse
    }
    
    func register(username: String, password: String) async throws -> LoginResponse {
            guard let url = URL(string: "\(baseURL)/register/") else { throw URLError(.badURL) }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: String] = [
                "username": username,
                "password": password
            ]
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)

            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }

            if !(200...299).contains(httpResponse.statusCode) {
                var errorMessage = "Registration failed. Please try again."

                if let decoded = try? JSONDecoder().decode(DjangoError.self, from: data) {
                    if let userErr = decoded.username?.first {
                        errorMessage = userErr
                    } else if let passErr = decoded.password?.first {
                        errorMessage = passErr
                    }
                }

                throw APIError.serverMessage(errorMessage)
            }

            let decodedResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
            UserDefaults.standard.set(decodedResponse.access, forKey: "jwt_access_token")
            UserDefaults.standard.set(String(decodedResponse.user_id), forKey: "user_id")
            
            return decodedResponse
        }
    
    func logout() async {
        guard let url = URL(string: "\(baseURL)/logout/") else { return }
        let request = createAuthenticatedRequest(url: url, method: "POST")
        try? await URLSession.shared.data(for: request)
    }

    // MARK: - Authentication Helper (The Bridge)
    
    /// Automatically attaches the JWT "VIP Wristband" to outgoing requests
    private func createAuthenticatedRequest(url: URL, method: String = "GET") -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Pull the token from the iPhone's secure storage
        if let token = UserDefaults.standard.string(forKey: "jwt_access_token") {
            // Inject it into the HTTP Header for Django to verify
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    // MARK: - API Calls
    
    func updateProfile(proficiency: String, language: String, genres: [String]) async throws {
        guard let url = URL(string: "\(baseURL)/update-profile/") else { throw URLError(.badURL) }
        
        guard let savedToken = UserDefaults.standard.string(forKey: "jwt_access_token") else {
            print("DEBUG: No token found in UserDefaults")
            throw URLError(.userAuthenticationRequired)
        }
        
        let body: [String: Any] = [
            "proficiency_level": proficiency,
            "target_language": language,
            "genres": genres
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("Bearer \(savedToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("DEBUG: Update Profile Status: \(httpResponse.statusCode)")
            if httpResponse.statusCode != 200 {
                let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown error"
                print("DEBUG: Server error message: \(errorMsg)")
            }
        }
    }
    
    /// Jaci's Word Card FastMCP Fetcher
    func fetchPronunciation(for word: String) async throws -> PronunciationResponse {
        guard let safeWord = word.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "\(baseURL)/pronunciation/\(safeWord)/") else {
            throw URLError(.badURL)
        }
        
        // build the request using your Auth Helper
        let request = createAuthenticatedRequest(url: url)
        
        // make the call
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // check for a 200 OK from Django
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            print("Server error while fetching pronunciation for \(word).")
            throw URLError(.badServerResponse)
        }
        
        // decode the JSON into Jaci's Struct
        return try JSONDecoder().decode(PronunciationResponse.self, from: data)
    }
    
    // MARK: - Austin's Migrated Request Methods
    
    func fetchMySongsData() async throws -> MySongsData {
        guard let url = URL(string: "\(baseURL)/songs-listened/") else {
            throw URLError(.badURL)
        }
        
        // uses our JWT Auth Helper
        let request = createAuthenticatedRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(MySongsData.self, from: data)
    }
    
    func fetchHomeScreenData() async throws -> HomeScreenData {
        guard let url = URL(string: "\(baseURL)/home/") else {
            throw URLError(.badURL)
        }
        
        let request = createAuthenticatedRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            let rawError = String(data: data, encoding: .utf8) ?? "No error body"
            print("--- DASHBOARD REJECTION: \(httpResponse.statusCode) ---")
            print(rawError)
            throw URLError(.badServerResponse)
        }
        
        do {
            return try JSONDecoder().decode(HomeScreenData.self, from: data)
        } catch let decodingError as DecodingError {
            print("--- HOME SCREEN DECODING ERROR ---")
            switch decodingError {
            case .keyNotFound(let key, let context):
                print("Missing key: '\(key.stringValue)' in \(context.codingPath.map(\.stringValue))")
            case .typeMismatch(let type, let context):
                print("Type mismatch: expected \(type) at \(context.codingPath.map(\.stringValue))")
            case .valueNotFound(let type, let context):
                print("Null value: expected \(type) at \(context.codingPath.map(\.stringValue))")
            case .dataCorrupted(let context):
                print("Data corrupted at \(context.codingPath.map(\.stringValue)): \(context.debugDescription)")
            @unknown default:
                print("Unknown decoding error: \(decodingError)")
            }
            print("Raw JSON: \(String(data: data, encoding: .utf8) ?? "unreadable")")
            throw decodingError
        }
    }
    
    func fetchWordBankScreenData() async throws -> WordBankData {
        guard let url = URL(string: "\(baseURL)/words-learned/") else {
            throw URLError(.badURL)
        }
        
        let request = createAuthenticatedRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(WordBankData.self, from: data)
    }
    
    func fetchUserActivityScreenData() async throws -> UserActivityData {
        guard let url = URL(string: "\(baseURL)/user-activity/") else {
            throw URLError(.badURL)
        }
        
        let request = createAuthenticatedRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(UserActivityData.self, from: data)
    }
    
    func fetchWordCardExerciseData() async throws -> WordCardExerciseData {
        guard let url = URL(string: "\(baseURL)/word-card-exercise/") else {
            throw URLError(.badURL)
        }
        
        let request = createAuthenticatedRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(WordCardExerciseData.self, from: data)
    }
    
    func fetchCompleteTheLyricExerciseData() async throws -> LyricChallengeData {
        guard let url = URL(string: "\(baseURL)/complete-the-lyric-exercise/") else {
            throw URLError(.badURL)
        }
        
        let request = createAuthenticatedRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(LyricChallengeData.self, from: data)
    }
    
    func fetchPlaylistCollectionData() async throws -> PlaylistCollectionData {
        guard let url = URL(string: "\(baseURL)/playlist-collection/") else {
            throw URLError(.badURL)
        }
        
        let request = createAuthenticatedRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(PlaylistCollectionData.self, from: data)
    }
    
    func fetchLyricMatchExerciseData() async throws -> LyricMatchingData {
        guard let url = URL(string: "\(baseURL)/lyric-match-exercise/") else {
            throw URLError(.badURL)
        }
        
        let request = createAuthenticatedRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(LyricMatchingData.self, from: data)
    }
    
    func fetchSinglePlaylistData(playlistId: Int) async throws -> SinglePlaylistData {
        guard let url = URL(string: "\(baseURL)/playlist/?playlist_id=\(playlistId)") else {
            throw URLError(.badURL)
        }
        
        let request = createAuthenticatedRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(SinglePlaylistData.self, from: data)
    }
    
    func generateWeeklyPlaylist() async throws -> SinglePlaylistData {
            // Points directly to the secure, ID-free URL we just built
            guard let url = URL(string: "\(baseURL)/playlists/generate/") else {
                throw URLError(.badURL)
            }
            
            // Uses the Auth helper to securely pass the JWT token and sets it as a POST request
            let request = createAuthenticatedRequest(url: url, method: "POST")
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                let rawError = String(data: data, encoding: .utf8) ?? "Unknown error"
                print("--- GENERATOR REJECTION: \(httpResponse.statusCode) ---")
                print(rawError)
                throw URLError(.badServerResponse)
            }
            
            // Decodes the returned playlist into Austin's existing SinglePlaylistData model
            return try JSONDecoder().decode(SinglePlaylistData.self, from: data)
        }
    
    func updateUserWordNumPracticesCompleted(word_text: String) async throws {
        guard let url = URL(string: "\(baseURL)/word-practices-completed/?word_text=\(word_text)") else { throw URLError(.badURL) }
        
        var request = createAuthenticatedRequest(url: url)
        request.httpMethod = "PUT"
                
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("DEBUG: Update Profile Status: \(httpResponse.statusCode)")
            if httpResponse.statusCode != 200 {
                let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown error"
                print("DEBUG: Server error message: \(errorMsg)")
            }
        }
    }
    
    func updateUserSongProgress(song_id: Int, request_type: String, playlist_id: Int) async throws {
        if song_id < 0 {return}
        
        var urlString: String = ""
        if request_type == "lyric_challenge" {
            urlString = "\(baseURL)/user-song-progress/?song_id=\(song_id)&request_type=lyric_challenge"
        } else if request_type == "song_listen" {
            if playlist_id < 0 { // this song didn't come from a playlist, none to update
                urlString = "\(baseURL)/user-song-progress/?song_id=\(song_id)&request_type=song_listen"
            }
            else {
                urlString = "\(baseURL)/user-song-progress/?song_id=\(song_id)&request_type=song_listen&playlist_id=\(playlist_id)"
            }
        }
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = createAuthenticatedRequest(url: url)
        request.httpMethod = "PUT"
                
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("DEBUG: Update Profile Status: \(httpResponse.statusCode)")
            if httpResponse.statusCode != 200 {
                let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown error"
                print("DEBUG: Server error message: \(errorMsg)")
            }
        }
    }
    
    func generateNewPlaylist() async throws -> Playlist {
        guard let url = URL(string: "\(baseURL)/playlists/generate/") else { throw URLError(.badURL) }
        
        var request = createAuthenticatedRequest(url: url)
        request.httpMethod = "POST"
                
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("DEBUG: Update Profile Status: \(httpResponse.statusCode)")
            if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 {
                let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown error"
                print("DEBUG: Server error message: \(errorMsg)")
            }
        }
        
        let decodedResponse = try JSONDecoder().decode(PlaylistResponse.self, from: data)
        return decodedResponse.playlist
    }

    // MARK: - Spotify Playlist Creation (on user's Spotify account)

    func generateSpotifyDrop() async throws {
        guard let url = URL(string: "\(baseURL)/generate-drop/") else {
            throw URLError(.badURL)
        }

        let request = createAuthenticatedRequest(url: url, method: "POST")
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("DEBUG: Spotify drop error: \(errorMsg)")
            throw URLError(.badServerResponse)
        }

        print("DEBUG: Spotify playlist created on user account")
    }

    func syncPlaylistsToSpotify() async throws {
        guard let url = URL(string: "\(baseURL)/sync-playlists-to-spotify/") else {
            throw URLError(.badURL)
        }

        let request = createAuthenticatedRequest(url: url, method: "POST")
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("DEBUG: Sync playlists to Spotify error: \(errorMsg)")
            throw URLError(.badServerResponse)
        }

        print("DEBUG: Synced existing playlists to user's Spotify account")
    }

    // MARK: - Spotify OAuth

    func fetchSpotifyAuthURL() async throws -> URL {
        guard let url = URL(string: "\(baseURL)/spotify/get-auth-url/") else {
            throw URLError(.badURL)
        }

        let request = createAuthenticatedRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let authUrlString = json["auth_url"] as? String,
              let authUrl = URL(string: authUrlString) else {
            throw URLError(.cannotParseResponse)
        }

        return authUrl
    }

    func sendSpotifyCode(_ code: String) async throws {
        guard let url = URL(string: "\(baseURL)/spotify/callback/") else {
            throw URLError(.badURL)
        }

        var request = createAuthenticatedRequest(url: url, method: "POST")
        let body = ["code": code]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
}
