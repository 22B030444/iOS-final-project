//
//  FollowedArtistsManager.swift
//  HearoApp
//
//  Created by Zhasmin Suleimenova on 15.12.2025.
//

import Foundation

struct Artist: Codable {
    let name: String
    let imageUrl: String?
    
    init(name: String, imageUrl: String? = nil) {
        self.name = name
        self.imageUrl = imageUrl
    }
}

class FollowedArtistsManager {
    
    static let shared = FollowedArtistsManager()
    private init() {}
    
    private let key = "followedArtists"

    func getFollowedArtists() -> [Artist] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let artists = try? JSONDecoder().decode([Artist].self, from: data) else {
            return []
        }
        return artists
    }
    
    func followArtist(_ artist: Artist) {
        var artists = getFollowedArtists()
        if !artists.contains(where: { $0.name.lowercased() == artist.name.lowercased() }) {
            artists.insert(artist, at: 0)
            saveArtists(artists)
        }
    }

    func unfollowArtist(_ artist: Artist) {
        var artists = getFollowedArtists()
        artists.removeAll { $0.name.lowercased() == artist.name.lowercased() }
        saveArtists(artists)
    }
    
    func isFollowing(_ artistName: String) -> Bool {
        let artists = getFollowedArtists()
        return artists.contains { $0.name.lowercased() == artistName.lowercased() }
    }
    
    func toggleFollow(name: String, imageUrl: String?) -> Bool {
        if isFollowing(name) {
            unfollowArtist(Artist(name: name, imageUrl: imageUrl))
            return false
        } else {
            followArtist(Artist(name: name, imageUrl: imageUrl))
            return true
        }
    }
    
    private func saveArtists(_ artists: [Artist]) {
        if let data = try? JSONEncoder().encode(artists) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
