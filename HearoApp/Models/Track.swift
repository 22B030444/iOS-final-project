//
//  Track.swift
//  HearoApp
//
//  Created by Zhasmin Suleimenova on 09.12.2025.
//

import Foundation

struct iTunesResponse: Codable {
    let resultCount: Int
    let results: [Track]
}

struct Track: Codable {
    let trackId: Int?
    let trackName: String?
    let artistName: String?
    let collectionName: String?
    let artworkUrl100: String?
    let previewUrl: String?
    let trackTimeMillis: Int?
    
    var artworkUrl600: String? {
        return artworkUrl100?.replacingOccurrences(of: "100x100", with: "600x600")
    }
}
