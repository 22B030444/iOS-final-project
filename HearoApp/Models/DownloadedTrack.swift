//
//  DownloadedTrack.swift
//  HearoApp
//
//  Created by Zhasmin Suleimenova on 16.12.2025.
//

import Foundation

struct DownloadedTrack: Codable {
    let track: Track
    let downloadedAt: Date
    
    init(track: Track) {
        self.track = track
        self.downloadedAt = Date()
    }
}
