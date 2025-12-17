//
//  MiniPlayerView.swift
//  HearoApp
//
//  Created by Zhasmin Suleimenova on 17.12.2025.
//

import UIKit
import Kingfisher

protocol MiniPlayerDelegate: AnyObject {
    func miniPlayerTapped()
    func miniPlayerPlayPauseTapped()
    func miniPlayerNextTapped()
}

class MiniPlayerView: UIView {
    
    weak var delegate: MiniPlayerDelegate?
    
    private var artworkImageView: UIImageView!
    private var trackNameLabel: UILabel!
    private var artistNameLabel: UILabel!
    private var playPauseButton: UIButton!
    private var nextButton: UIButton!
    
    private var isPlaying = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromXib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadFromXib()
    }
    
    private func loadFromXib() {
        guard let view = Bundle.main.loadNibNamed("MiniPlayerView", owner: nil)?.first as? UIView else { return }
        
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
   
        artworkImageView = view.viewWithTag(100) as? UIImageView
        trackNameLabel = view.viewWithTag(101) as? UILabel
        artistNameLabel = view.viewWithTag(102) as? UILabel
        playPauseButton = view.viewWithTag(103) as? UIButton
        nextButton = view.viewWithTag(104) as? UIButton
        
        layer.cornerRadius = 12
        clipsToBounds = true
        
        artworkImageView.layer.cornerRadius = 6
        artworkImageView.clipsToBounds = true
   
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        addGestureRecognizer(tapGesture)

        playPauseButton.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
    }
    
    func configure(track: Track, isPlaying: Bool) {
        self.isPlaying = isPlaying
        
        trackNameLabel.text = track.trackName ?? "Unknown"
        artistNameLabel.text = track.artistName ?? "Unknown Artist"
        
        let imageName = isPlaying ? "pause.fill" : "play.fill"
        playPauseButton.setImage(UIImage(systemName: imageName), for: .normal)
        
        let placeholder = UIImage(systemName: "music.note")
        
        if let urlString = track.artworkUrl100,
            let url = URL(string: urlString) {
            artworkImageView.kf.setImage(
                with: url,
                placeholder: placeholder,
                options: [.transition(.fade(0.2))]
            )
        } else {
            artworkImageView.image = placeholder
            artworkImageView.tintColor = .gray
        }
    }
    
    func updatePlayPauseButton(isPlaying: Bool) {
        self.isPlaying = isPlaying
        let imageName = isPlaying ? "pause.fill" : "play.fill"
        playPauseButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @objc private func viewTapped() {
        delegate?.miniPlayerTapped()
    }
    
    @objc private func playPauseTapped() {
        delegate?.miniPlayerPlayPauseTapped()
    }
    
    @objc private func nextTapped() {
        delegate?.miniPlayerNextTapped()
    }
}
