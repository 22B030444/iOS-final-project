//
//  DownloadsManager.swift
//  HearoApp
//
//  Created by Zhasmin Suleimenova on 16.12.2025.
//

import Foundation

class DownloadsManager {
    
    static let shared = DownloadsManager()
    private init() {
        createDownloadsDirectory()
    }
    
    private let key = "downloadedTracks"

    private var downloadsDirectory: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent("Downloads")
    }
    
    private func createDownloadsDirectory() {
        if !FileManager.default.fileExists(atPath: downloadsDirectory.path) {
            try? FileManager.default.createDirectory(at: downloadsDirectory, withIntermediateDirectories: true)
        }
    }

    func localFileURL(for track: Track) -> URL? {
        guard let trackId = track.trackId else { return nil }
        return downloadsDirectory.appendingPathComponent("\(trackId).m4a")
    }
    
    func isFileDownloaded(_ track: Track) -> Bool {
        guard let localURL = localFileURL(for: track) else { return false }
        return FileManager.default.fileExists(atPath: localURL.path)
    }
  
    func downloadTrack(_ track: Track, completion: @escaping (Bool) -> Void) {
        guard let previewUrlString = track.previewUrl,
              let previewURL = URL(string: previewUrlString),
              let localURL = localFileURL(for: track) else {
            completion(false)
            return
        }

        if isFileDownloaded(track) {
            addTrackMetadata(track)
            completion(true)
            return
        }
   
        URLSession.shared.downloadTask(with: previewURL) { [weak self] tempURL, response, error in
            guard let self = self,
                  let tempURL = tempURL,
                  error == nil else {
                DispatchQueue.main.async { completion(false) }
                return
            }
            
            do {
                if FileManager.default.fileExists(atPath: localURL.path) {
                    try FileManager.default.removeItem(at: localURL)
                }
                try FileManager.default.copyItem(at: tempURL, to: localURL)
                
                self.addTrackMetadata(track)
                
                DispatchQueue.main.async { completion(true) }
            } catch {
                print("Download error: \(error)")
                DispatchQueue.main.async { completion(false) }
            }
        }.resume()
    }

    func removeTrack(_ track: Track) {
        if let localURL = localFileURL(for: track) {
            try? FileManager.default.removeItem(at: localURL)
        }
    
        removeTrackMetadata(track)
    }
    
    func getDownloadedTracks() -> [DownloadedTrack] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let tracks = try? JSONDecoder().decode([DownloadedTrack].self, from: data) else {
            return []
        }
        return tracks.filter { isFileDownloaded($0.track) }
            .sorted { $0.downloadedAt > $1.downloadedAt }
    }
    
    private func addTrackMetadata(_ track: Track) {
        var downloads = getAllMetadata()
        if !downloads.contains(where: { $0.track.trackId == track.trackId }) {
            let downloadedTrack = DownloadedTrack(track: track)
            downloads.insert(downloadedTrack, at: 0)
            saveMetadata(downloads)
        }
    }
    
    private func removeTrackMetadata(_ track: Track) {
        var downloads = getAllMetadata()
        downloads.removeAll { $0.track.trackId == track.trackId }
        saveMetadata(downloads)
    }
    
    private func getAllMetadata() -> [DownloadedTrack] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let tracks = try? JSONDecoder().decode([DownloadedTrack].self, from: data) else {
            return []
        }
        return tracks
    }
    
    func isDownloaded(_ track: Track) -> Bool {
        return isFileDownloaded(track)
    }
    
    func toggleDownload(_ track: Track, completion: @escaping (Bool) -> Void) {
        if isDownloaded(track) {
            removeTrack(track)
            completion(false)
        } else {
            downloadTrack(track) { success in
                completion(success)
            }
        }
    }
    
    private func saveMetadata(_ tracks: [DownloadedTrack]) {
        if let data = try? JSONEncoder().encode(tracks) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
