//
//  MainTabBarController.swift
//  HearoApp
//
//  Created by Zhasmin Suleimenova on 17.12.2025.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    let miniPlayerView = MiniPlayerView()
    private let miniPlayerHeight: CGFloat = 64
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMiniPlayer()
        setupNotifications()
    }
    
    private func setupMiniPlayer() {
        miniPlayerView.translatesAutoresizingMaskIntoConstraints = false
        miniPlayerView.isHidden = true
        miniPlayerView.delegate = self
        view.addSubview(miniPlayerView)
        
        NSLayoutConstraint.activate([
            miniPlayerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            miniPlayerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            miniPlayerView.bottomAnchor.constraint(equalTo: tabBar.topAnchor, constant: -8),
            miniPlayerView.heightAnchor.constraint(equalToConstant: miniPlayerHeight)
        ])
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(trackChanged(_:)),
            name: .miniPlayerTrackChanged,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playStateChanged(_:)),
            name: .miniPlayerStateChanged,
            object: nil
        )
    }
    
    @objc private func trackChanged(_ notification: Notification) {
        guard let track = notification.object as? Track else { return }
        miniPlayerView.isHidden = false
        miniPlayerView.configure(track: track, isPlaying: MusicPlayerManager.shared.isPlaying)
        updateTabBarInsets()
    }
    
    @objc private func playStateChanged(_ notification: Notification) {
        guard let isPlaying = notification.object as? Bool else { return }
        miniPlayerView.updatePlayPauseButton(isPlaying: isPlaying)
    }
    
    private func updateTabBarInsets() {
        for child in children {
            if let nav = child as? UINavigationController {
                nav.additionalSafeAreaInsets.bottom = miniPlayerHeight + 8
            }
        }
    }
    
    func showMiniPlayer(track: Track, isPlaying: Bool) {
        miniPlayerView.isHidden = false
        miniPlayerView.configure(track: track, isPlaying: isPlaying)
        updateTabBarInsets()
    }
    
    func hideMiniPlayer() {
        miniPlayerView.isHidden = true
        for child in children {
            if let nav = child as? UINavigationController {
                nav.additionalSafeAreaInsets.bottom = 0
            }
        }
    }
}

// MARK: - MiniPlayerDelegate
extension MainTabBarController: MiniPlayerDelegate {
    
    func miniPlayerTapped() {
        guard let track = MusicPlayerManager.shared.currentTrack else { return }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let playerVC = storyboard.instantiateViewController(withIdentifier: "PlayerViewController") as? PlayerViewController {
            playerVC.track = track
            playerVC.tracks = MusicPlayerManager.shared.tracks
            playerVC.currentIndex = MusicPlayerManager.shared.currentIndex
            playerVC.modalPresentationStyle = .fullScreen
            present(playerVC, animated: true)
        }
    }
    
    func miniPlayerPlayPauseTapped() {
        MusicPlayerManager.shared.togglePlayPause()
    }
    
    func miniPlayerNextTapped() {
        MusicPlayerManager.shared.playNext()
    }
}
