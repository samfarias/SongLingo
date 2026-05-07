//
//  AudioPlayerManager.swift
//  SongLingo
//
//  Created by Sam on 5/6/26.
//

import Foundation
import AVFoundation

class AudioPlayerManager {
    
    // 1. The Singleton (Crucial for memory)
    static let shared = AudioPlayerManager()
    
    // 2. The Player instance must be held in memory, otherwise it dies instantly
    private var audioPlayer: AVAudioPlayer?
    
    private init() {}
    
    /// Decodes a Base64 string and plays it out loud
    func playBase64Audio(_ base64String: String) {
        
        // Trap 1: Clean the string. Sometimes AI APIs send "data:audio/mp3;base64,GkXf..."
        // We only want the gibberish after the comma.
        let cleanString = base64String.components(separatedBy: ",").last ?? base64String
        
        // Trap 2: Decode the raw string into an actual Data object
        guard let audioData = Data(base64Encoded: cleanString, options: .ignoreUnknownCharacters) else {
            print("❌ Audio Error: Could not decode Base64 string.")
            return
        }
        
        do {
            // Trap 3: The "Silent Switch" Override
            // Without this, the audio won't play if the user's phone is on vibrate!
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            // Load the data into the player and hit play
            audioPlayer = try AVAudioPlayer(data: audioData)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
        } catch {
            print("❌ Audio Playback Error: \(error.localizedDescription)")
        }
    }
}
