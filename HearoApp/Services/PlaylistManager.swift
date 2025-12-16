//
//  PlaylistManager.swift
//  HearoApp
//
//  Created by Zhasmin Suleimenova on 13.12.2025.
//

import Foundation

class PlaylistManager {
    
    static let shared = PlaylistManager()
    private init() {}
    
    private let key = "playlists"
    
    func getPlaylists() -> [Playlist] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let playlists = try? JSONDecoder().decode([Playlist].self, from: data) else {
            return []
        }
        return playlists
    }
    
    func createPlaylist(name: String) -> Playlist {
        var playlists = getPlaylists()
        let newPlaylist = Playlist(name: name)
        playlists.insert(newPlaylist, at: 0)
        savePlaylists(playlists)
        return newPlaylist
    }

    func deletePlaylist(_ playlist: Playlist) {
        var playlists = getPlaylists()
        playlists.removeAll { $0.id == playlist.id }
        savePlaylists(playlists)
    }

    func addTrack(_ track: Track, to playlistId: String) {
        var playlists = getPlaylists()
        if let index = playlists.firstIndex(where: { $0.id == playlistId }) {
            if !playlists[index].tracks.contains(where: { $0.trackId == track.trackId }) {
                playlists[index].tracks.append(track)
                savePlaylists(playlists)
            }
        }
    }
 
    func removeTrack(_ track: Track, from playlistId: String) {
        var playlists = getPlaylists()
        if let index = playlists.firstIndex(where: { $0.id == playlistId }) {
            playlists[index].tracks.removeAll { $0.trackId == track.trackId }
            savePlaylists(playlists)
        }
    }
  
    func renamePlaylist(id: String, newName: String) {
        var playlists = getPlaylists()
        if let index = playlists.firstIndex(where: { $0.id == id }) {
            playlists[index].name = newName
            savePlaylists(playlists)
        }
    }

    func getPlaylist(by id: String) -> Playlist? {
        return getPlaylists().first { $0.id == id }
    }
    
    private func savePlaylists(_ playlists: [Playlist]) {
        if let data = try? JSONEncoder().encode(playlists) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
