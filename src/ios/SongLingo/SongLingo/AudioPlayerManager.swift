//
//  AudioPlayerManager.swift
//  SongLingo
//
//  Created by Sam on 5/6/26.
//

import Foundation
import AVFoundation

class AudioPlayerManager: NSObject, AVSpeechSynthesizerDelegate {

    static let shared = AudioPlayerManager()

    private var audioPlayer: AVAudioPlayer?
    private var urlPlayer: AVPlayer?
    private let speechSynthesizer = AVSpeechSynthesizer()

    private override init() {
        super.init()
        speechSynthesizer.delegate = self
    }

    func speakWord(_ word: String, language: String = "es-MX") {
        speechSynthesizer.stopSpeaking(at: .immediate)

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error: \(error.localizedDescription)")
        }

        let utterance = AVSpeechUtterance(string: word)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = 0.4
        utterance.pitchMultiplier = 1.0
        speechSynthesizer.speak(utterance)
    }
    
    func playFromURL(_ url: URL) {
        stopPlayback()

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error: \(error.localizedDescription)")
        }

        let playerItem = AVPlayerItem(url: url)
        urlPlayer = AVPlayer(playerItem: playerItem)
        urlPlayer?.play()
    }

    func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        urlPlayer?.pause()
        urlPlayer = nil
    }

    func playBase64Audio(_ base64String: String) {
        
        // Trap 1: Clean the string. Sometimes AI APIs send "data:audio/mp3;base64,GkXf..."
        let cleanString = base64String.components(separatedBy: ",").last ?? base64String
        
        // Trap 2: Decode the raw string into an actual Data object
        guard let audioData = Data(base64Encoded: cleanString, options: .ignoreUnknownCharacters) else {
            print("❌ Audio Error: Could not decode Base64 string.")
            return
        }
        
        do {
            // Trap 3: The "Silent Switch" Override
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
