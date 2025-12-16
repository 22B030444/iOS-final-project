//
//  Album.swift
//  HearoApp
//
//  Created by Zhasmin Suleimenova on 16.12.2025.
//

//
//  Album.swift
//  HearoApp
//

import Foundation

struct Album: Codable {
    let collectionId: Int?
    let collectionName: String?
    let artistName: String?
    let artworkUrl100: String?
    let trackCount: Int?
    let releaseDate: String?
    let primaryGenreName: String?
    
    var artworkUrl600: String? {
        return artworkUrl100?.replacingOccurrences(of: "100x100", with: "600x600")
    }
}

struct iTunesAlbumResponse: Codable {
    let resultCount: Int
    let results: [Album]
}
