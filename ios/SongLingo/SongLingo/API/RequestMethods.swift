//
//  RequestMethods.swift
//  
//
//  Created by Austin Robertson on 4/30/26.
//

import Foundation

// MARK: - MySongs data Request
func fetchMySongsData(userId: String) async throws -> MySongsData {
    guard let url = URL(string: "http://localhost:8000/api/songs-listened?user_id=\(userId)") else {
        throw URLError(.badURL)
    }
    
    // Perform the request
    let (data, response) = try await URLSession.shared.data(from: url)
    
    // Check for a valid HTTP response
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        throw URLError(.badServerResponse)
    }
    
    // Decode the JSON data
    return try JSONDecoder().decode(MySongsData.self, from: data)
}

// MARK: - HomeScreen data Request
func fetchHomeScreenData(userId: String) async throws -> HomeScreenData {
    guard let url = URL(string: "http://localhost:8000/api/home?user_id=\(userId)") else {
        throw URLError(.badURL)
    }
    
    // Perform the request
    let (data, response) = try await URLSession.shared.data(from: url)
    
    // Check for a valid HTTP response
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        throw URLError(.badServerResponse)
    }
    
    // Decode the JSON data
    return try JSONDecoder().decode(HomeScreenData.self, from: data)
}

// MARK: - WordBankScreen data Request
func fetchWordBankScreenData(userId: String) async throws -> WordBankData {
    guard let url = URL(string: "http://localhost:8000/api/words-learned?user_id=\(userId)") else {
        throw URLError(.badURL)
    }
    
    // Perform the request
    let (data, response) = try await URLSession.shared.data(from: url)
    
    // Check for a valid HTTP response
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        throw URLError(.badServerResponse)
    }
    
    // Decode the JSON data
    return try JSONDecoder().decode(WordBankData.self, from: data)
}

// MARK: - UserActivityScreen data Request
func fetchUserActivityScreenData(userId: String) async throws -> UserActivityData {
    guard let url = URL(string: "http://localhost:8000/api/user-activity?user_id=\(userId)") else {
        throw URLError(.badURL)
    }
    
    // Perform the request
    let (data, response) = try await URLSession.shared.data(from: url)
    
    // Check for a valid HTTP response
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        throw URLError(.badServerResponse)
    }
    
    // Decode the JSON data
    return try JSONDecoder().decode(UserActivityData.self, from: data)
}
