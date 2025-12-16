//
//  LikedSongsManager.swift
//  HearoApp
//
//  Created by Zhasmin Suleimenova on 11.12.2025.
//

import Foundation

class LikedSongsManager {
    
    static let shared = LikedSongsManager()
    private init() {}
    
    private let key = "likedSongs"
    
    func getLikedSongs() -> [Track] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let tracks = try? JSONDecoder().decode([Track].self, from: data) else {
            return []
        }
        return tracks
    }
    
    func addTrack(_ track: Track) {
        var tracks = getLikedSongs()
        if !tracks.contains(where: { $0.trackId == track.trackId }) {
            tracks.insert(track, at: 0)
            saveTracks(tracks)
        }
    }
    
    func removeTrack(_ track: Track) {
        var tracks = getLikedSongs()
        tracks.removeAll { $0.trackId == track.trackId }
        saveTracks(tracks)
    }
    
    func isLiked(_ track: Track) -> Bool {
        let tracks = getLikedSongs()
        return tracks.contains { $0.trackId == track.trackId }
    }
    
    func toggleLike(_ track: Track) -> Bool {
        if isLiked(track) {
            removeTrack(track)
            return false
        } else {
            addTrack(track)
            return true
        }
    }
    
    private func saveTracks(_ tracks: [Track]) {
        if let data = try? JSONEncoder().encode(tracks) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
