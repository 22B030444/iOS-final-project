//
//  PlaylistCell.swift
//  HearoApp
//
//  Created by Zhasmin Suleimenova on 13.12.2025.
//
import UIKit

class PlaylistCell: UITableViewCell {
    
    @IBOutlet weak var playlistImageView: UIImageView!
    @IBOutlet weak var playlistNameLabel: UILabel!
    @IBOutlet weak var tracksCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        UIView.animate(withDuration: 0.1) {
            self.alpha = highlighted ? 0.6 : 1.0
            self.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
        }
    }
    
    func configure(with playlist: Playlist) {
        playlistNameLabel.text = playlist.name
        tracksCountLabel.text = "\(playlist.tracks.count) songs"
    }
}
