//
//  TrackTableViewCell.swift
//  HearoApp
//
//  Created by Zhasmin Suleimenova on 10.12.2025.
//

import UIKit
import Kingfisher

class TrackTableViewCell: UITableViewCell {
    
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        artworkImageView.layer.cornerRadius = 8
        artworkImageView.clipsToBounds = true
        artworkImageView.contentMode = .scaleAspectFill
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        artworkImageView.kf.cancelDownloadTask()
        artworkImageView.image = nil
    }
    
    func configure(with track: Track) {
        trackNameLabel.text = track.trackName ?? "Unknown"
        artistNameLabel.text = track.artistName ?? "Unknown Artist"
        let placeholder = UIImage(systemName: "music.note")
        
        if let urlString = track.artworkUrl100,
            let url = URL(string: urlString) {
            artworkImageView.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: "music.note"),
                options: [
                    .transition(.fade(0.3)),
                    .cacheOriginalImage
                ]
            )
        } else {
            artworkImageView.image = placeholder
            artworkImageView.tintColor = .gray
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
