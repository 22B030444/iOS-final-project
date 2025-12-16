//
//  TrackCollectionViewCell.swift
//  HearoApp
//
//  Created by Zhasmin Suleimenova on 09.12.2025.
//

import UIKit

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
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.artworkImageView.image = image
                }
            }
        }.resume()
    }
}
