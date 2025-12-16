//
//  PlayHistoryManager.swift
//  HearoApp
//
//  Created by Zhasmin Suleimenova on 16.12.2025.
//

import Foundation

class PlayHistoryManager {
    
    static let shared = PlayHistoryManager()
    private init() {}
    
    private let key = "playHistory"
    private let maxHistorySize = 50
    
    func getPlayHistory() -> [PlayHistory] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let history = try? JSONDecoder().decode([PlayHistory].self, from: data) else {
            return []
        }
        return history
    }
    
    func addTrack(_ track: Track) {
        var history = getPlayHistory()
        
        // Удаляем предыдущие записи этого трека
        history.removeAll { $0.track.trackId == track.trackId }
        
        // Добавляем новую запись в начало
        let playHistory = PlayHistory(track: track)
        history.insert(playHistory, at: 0)
        
        // Ограничиваем размер истории
        if history.count > maxHistorySize {
            history = Array(history.prefix(maxHistorySize))
        }
        
        saveHistory(history)
    }
    
    func getRecentlyPlayedTracks(limit: Int = 20) -> [Track] {
        let history = getPlayHistory()
        return Array(history.prefix(limit)).map { $0.track }
    }
    
    func clearHistory() {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    func removeTrack(_ track: Track) {
        var history = getPlayHistory()
        history.removeAll { $0.track.trackId == track.trackId }
        saveHistory(history)
    }
    
    private func saveHistory(_ history: [PlayHistory]) {
        if let data = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
