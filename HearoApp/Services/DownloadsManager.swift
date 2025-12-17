//
//  DownloadsManager.swift
//  HearoApp
//
//  Created by Zhasmin Suleimenova on 16.12.2025.
//

import Foundation

class DownloadsManager {
    
    static let shared = DownloadsManager()
    private init() {}
    
    private let key = "downloadedTracks"
    
    func getDownloadedTracks() -> [DownloadedTrack] {
        guard let data = UserDefaults.standard.data(forKey: key),
            let tracks = try? JSONDecoder().decode([DownloadedTrack].self, from: data) else {
            return []
        }
        return tracks.sorted { $0.downloadedAt > $1.downloadedAt }
    }
    
    func addTrack(_ track: Track) {
        var downloads = getDownloadedTracks()
        if !downloads.contains(where: { $0.track.trackId == track.trackId }) {
            let downloadedTrack = DownloadedTrack(track: track)
            downloads.insert(downloadedTrack, at: 0)
            saveTracks(downloads)
        }
    }
    
    func removeTrack(_ track: Track) {
        var downloads = getDownloadedTracks()
        downloads.removeAll { $0.track.trackId == track.trackId }
        saveTracks(downloads)
    }
    
    func isDownloaded(_ track: Track) -> Bool {
        let downloads = getDownloadedTracks()
        return downloads.contains { $0.track.trackId == track.trackId }
    }
    
    func toggleDownload(_ track: Track) -> Bool {
        if isDownloaded(track) {
            removeTrack(track)
            return false
        } else {
            addTrack(track)
            return true
        }
    }
    
    private func saveTracks(_ tracks: [DownloadedTrack]) {
        if let data = try? JSONEncoder().encode(tracks) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
