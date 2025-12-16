//
//  TrackTableViewCell.swift
//  HearoApp
//
//  Created by Zhasmin Suleimenova on 10.12.2025.
//

import UIKit

class TrackTableViewCell: UITableViewCell {
    
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        selectionStyle = .none
        
        artworkImageView.layer.cornerRadius = 8
        artworkImageView.clipsToBounds = true
        artworkImageView.contentMode = .scaleAspectFill
    }
    
    func configure(with track: Track) {
        trackNameLabel.text = track.trackName ?? "Unknown"
        artistNameLabel.text = track.artistName ?? "Unknown Artist"
        
        artworkImageView.image = UIImage(systemName: "music.note")
        artworkImageView.tintColor = .gray
        
        if let urlString = track.artworkUrl100,
           let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.artworkImageView.image = image
                    }
                }
            }.resume()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
