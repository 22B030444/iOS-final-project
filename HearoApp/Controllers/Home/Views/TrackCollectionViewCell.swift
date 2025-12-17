//
//  TrackCollectionViewCell.swift
//  HearoApp
//
//  Created by Zhasmin Suleimenova on 09.12.2025.
//

import UIKit
import Kingfisher

class TrackCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        artworkImageView.layer.cornerRadius = 8
        artworkImageView.clipsToBounds = true
    }
    
    func configure(with track: Track) {
        trackNameLabel.text = track.trackName ?? "Unknown"
        artistNameLabel.text = track.artistName ?? "Unknown Artist"
        
        if let urlString = track.artworkUrl600,
           let url = URL(string: urlString) {
            loadImage(from: url)
        }
    }
    
    private func loadImage(from url: URL) {
        artworkImageView.kf.setImage(
            with: url,
            placeholder: UIImage(systemName: "music.note"),
            options: [
                .transition(.fade(0.3)),
                .cacheOriginalImage
            ]
        )
    }
}
