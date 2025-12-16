//
//  SavedAlbumsManager.swift
//  HearoApp
//
//  Created by Zhasmin Suleimenova on 16.12.2025.
//

import Foundation

class SavedAlbumsManager {
    
    static let shared = SavedAlbumsManager()
    private init() {}
    
    private let key = "savedAlbums"
    
    func getSavedAlbums() -> [Album] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let albums = try? JSONDecoder().decode([Album].self, from: data) else {
            return []
        }
        return albums
    }
    
    func saveAlbum(_ album: Album) {
        var albums = getSavedAlbums()
        if !albums.contains(where: { $0.collectionId == album.collectionId }) {
            albums.insert(album, at: 0)
            saveAlbums(albums)
        }
    }
    
    func removeAlbum(_ album: Album) {
        var albums = getSavedAlbums()
        albums.removeAll { $0.collectionId == album.collectionId }
        saveAlbums(albums)
    }
    
    func isSaved(_ album: Album) -> Bool {
        let albums = getSavedAlbums()
        return albums.contains { $0.collectionId == album.collectionId }
    }
    
    func isSavedById(_ collectionId: Int) -> Bool {
        let albums = getSavedAlbums()
        return albums.contains { $0.collectionId == collectionId }
    }
    
    func toggleSave(_ album: Album) -> Bool {
        if isSaved(album) {
            removeAlbum(album)
            return false
        } else {
            saveAlbum(album)
            return true
        }
    }
    
    private func saveAlbums(_ albums: [Album]) {
        if let data = try? JSONEncoder().encode(albums) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
