//
//  PlayHistory.swift
//  HearoApp
//
//  Created by Zhasmin Suleimenova on 16.12.2025.
//

import Foundation

struct PlayHistory: Codable {
    let track: Track
    let playedAt: Date
    
    init(track: Track) {
        self.track = track
        self.playedAt = Date()
    }
}
