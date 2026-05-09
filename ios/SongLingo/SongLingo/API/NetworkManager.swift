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

// MARK: - Network Manager

class NetworkManager {
    
    // the one Instance so the entire app shares one manager
    static let shared = NetworkManager()
    
    // Our Live DigitalOcean Server is ACTIVE
//    private let baseURL = "http://68.183.31.175:8000/api"
    
    // Localhost is COMMENTED OUT (Use this only when testing the backend on your Mac)
     private let baseURL = "http://localhost:8000/api"
    
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
    func login(email: String, password: String) async throws -> LoginResponse {
        // Uses already-defined baseURL
        guard let url = URL(string: "\(baseURL)/login/") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let decodedResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
        
        // Save the JWT token so other requests work :)
        UserDefaults.standard.set(decodedResponse.access, forKey: "jwt_access_token")
        
        //return try JSONDecoder().decode(LoginResponse.self, from: data)
        
        return decodedResponse
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
    
    /// Jaci's Word Card FastMCP Fetcher
    func fetchPronunciation(for word: String) async throws -> PronunciationResponse {
        // Safely encode the URL in case the word has spaces or weird characters
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
    
    /// Austin's Home Screen Data Fetcher
    func fetchHomeScreenData(userId: String) async throws -> HomeDataResponse {
        guard let url = URL(string: "\(baseURL)/home/?user_id=\(userId)") else {
            throw URLError(.badURL)
        }
        
        // build the request using your Auth Helper
        let request = createAuthenticatedRequest(url: url)
        
        // make the call
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // check for a 200 OK from Django
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            print("Server error while fetching home data.")
            throw URLError(.badServerResponse)
        }
        
        // decode the JSON
        return try JSONDecoder().decode(HomeDataResponse.self, from: data)
    }
    
    // MARK: - Austin's Migrated Request Methods
    
    func fetchMySongsData(userId: String) async throws -> MySongsData {
        guard let url = URL(string: "\(baseURL)/songs-listened?user_id=\(userId)") else {
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
    
    func fetchHomeScreenData(userId: String) async throws -> HomeScreenData {
        guard let url = URL(string: "\(baseURL)/home?user_id=\(userId)") else {
            throw URLError(.badURL)
        }
        
        let request = createAuthenticatedRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(HomeScreenData.self, from: data)
    }
    
    func fetchWordBankScreenData(userId: String) async throws -> WordBankData {
        guard let url = URL(string: "\(baseURL)/words-learned?user_id=\(userId)") else {
            throw URLError(.badURL)
        }
        
        let request = createAuthenticatedRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(WordBankData.self, from: data)
    }
    
    func fetchUserActivityScreenData(userId: String) async throws -> UserActivityData {
        guard let url = URL(string: "\(baseURL)/user-activity?user_id=\(userId)") else {
            throw URLError(.badURL)
        }
        
        let request = createAuthenticatedRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(UserActivityData.self, from: data)
    }
    
    func fetchWordCardExerciseData(userId: String) async throws -> WordCardExerciseData {
        guard let url = URL(string: "\(baseURL)/word-card-exercise?user_id=\(userId)") else {
            throw URLError(.badURL)
        }
        
        let request = createAuthenticatedRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(WordCardExerciseData.self, from: data)
    }
}
