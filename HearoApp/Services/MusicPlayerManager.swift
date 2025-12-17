//
//  MusicPlayerManager.swift
//  HearoApp
//
//  Created by Zhasmin Suleimenova on 17.12.2025.
//

import Foundation
import AVFoundation

class MusicPlayerManager {
    
    static let shared = MusicPlayerManager()
    private init() {
        setupAudioSession()
    }
    
    var player: AVPlayer?
    var currentTrack: Track?
    var tracks: [Track] = []
    var currentIndex: Int = 0
    var isPlaying = false
    
    var onTrackChanged: ((Track) -> Void)?
    var onPlayStateChanged: ((Bool) -> Void)?
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
    }
    
    func play(track: Track, tracks: [Track], index: Int) {
        self.currentTrack = track
        self.tracks = tracks
        self.currentIndex = index
      
        let url: URL?
        if let localURL = DownloadsManager.shared.localFileURL(for: track),
           DownloadsManager.shared.isFileDownloaded(track) {
            url = localURL
        } else if let urlString = track.previewUrl {
            url = URL(string: urlString) 
        } else {
            url = nil
        }
        
        guard let playURL = url else { return }
        
        player?.pause()
        player = AVPlayer(url: playURL)
        player?.play()
        isPlaying = true
        
        PlayHistoryManager.shared.addTrack(track)
        
        NotificationCenter.default.post(name: .miniPlayerTrackChanged, object: track)
        NotificationCenter.default.post(name: .miniPlayerStateChanged, object: isPlaying)
    }
    
    func togglePlayPause() {
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
        isPlaying.toggle()
        
        onPlayStateChanged?(isPlaying)
        NotificationCenter.default.post(name: .miniPlayerStateChanged, object: isPlaying)
    }
    
    func playNext() {
        guard !tracks.isEmpty else { return }
        
        currentIndex += 1
        if currentIndex >= tracks.count {
            currentIndex = 0
        }
        
        let track = tracks[currentIndex]
        play(track: track, tracks: tracks, index: currentIndex)
    }
    
    func playPrevious() {
        guard !tracks.isEmpty else { return }
        
        currentIndex -= 1
        if currentIndex < 0 {
            currentIndex = tracks.count - 1
        }
        
        let track = tracks[currentIndex]
        play(track: track, tracks: tracks, index: currentIndex)
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let miniPlayerTrackChanged = Notification.Name("miniPlayerTrackChanged")
    static let miniPlayerStateChanged = Notification.Name("miniPlayerStateChanged")
}
