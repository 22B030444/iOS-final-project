//
//  Playlist.swift
//  HearoApp
//
//  Created by Zhasmin Suleimenova on 13.12.2025.
//

import Foundation

struct Playlist: Codable {
    let id: String
    var name: String
    var tracks: [Track]
    let createdAt: Date
    
    init(name: String, tracks: [Track] = []) {
        self.id = UUID().uuidString
        self.name = name
        self.tracks = tracks
        self.createdAt = Date()
    }
}
