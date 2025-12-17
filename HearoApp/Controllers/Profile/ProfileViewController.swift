//
//  ProfileViewController.swift
//  HearoApp
//
//  Created by Zhasmin Suleimenova on 12.12.2025.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    @IBOutlet weak var songsCountLabel: UILabel!
    @IBOutlet weak var playlistsCountLabel: UILabel!
    @IBOutlet weak var artistsCountLabel: UILabel!
    var playlistsCount: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserData()
    }
   
    private func setupUI() {
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
    }
    
    private func loadUserData() {
        usernameLabel.text = "Zhasmin"
        emailLabel.text = "zhasmin@gmail.com"
        phoneLabel.text = "8 777 990 85 51"
        
        let likedCount = LikedSongsManager.shared.getLikedSongs().count
        songsCountLabel.text = "\(likedCount)"
        
        let playlistsCount = PlaylistManager.shared.getPlaylists().count
        playlistsCountLabel.text = "\(playlistsCount)"
        let artistsCount = FollowedArtistsManager.shared.getFollowedArtists().count
        artistsCountLabel.text = "\(artistsCount)"
        
        
    }
}
