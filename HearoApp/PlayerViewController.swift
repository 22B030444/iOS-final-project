//
//  PlayerViewController.swift
//  HearoApp
//
//  Created by Zhasmin Suleimenova on 09.12.2025.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController {
    
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!

    var track: Track?
    var tracks: [Track] = []
    var currentIndex: Int = 0
    
    private var player: AVPlayer?
    private var isPlaying = false
    private var isShuffleOn = false
    private var repeatMode: RepeatMode = .off
    private var timeObserver: Any?
    
    enum RepeatMode {
        case off, one, all
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configurePlayer()
    }
    private func removeTimeObserverIfNeeded() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
        removeTimeObserverIfNeeded()

    }
    
    private func setupUI() {
        guard let track = track else { return }
        
        trackNameLabel.text = track.trackName ?? "Unknown"
        artistNameLabel.text = track.artistName ?? "Unknown Artist"
        
        artworkImageView.layer.cornerRadius = 12
        artworkImageView.clipsToBounds = true
        
        if let urlString = track.artworkUrl600,
           let url = URL(string: urlString) {
            loadImage(from: url)
        }
        
        if let millis = track.trackTimeMillis {
            let seconds = millis / 1000
            durationLabel.text = formatTime(seconds)
        }
        currentTimeLabel.text = "0:00"
        progressSlider.value = 0
        
        updateShuffleButton()
        updateRepeatButton()
        updateLikeButton()
        updateDownloadButton()
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
    
    private func configurePlayer() {
        guard let track = track,
              let urlString = track.previewUrl,
              let url = URL(string: urlString) else { return }
        
        player?.pause()
        removeTimeObserverIfNeeded()
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
        
        player = AVPlayer(url: url)
        PlayHistoryManager.shared.addTrack(track)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(trackDidFinish),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )
        
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            let currentSeconds = Int(CMTimeGetSeconds(time))
            self?.currentTimeLabel.text = self?.formatTime(currentSeconds)
            
            if let duration = self?.player?.currentItem?.duration {
                let totalSeconds = CMTimeGetSeconds(duration)
                if totalSeconds > 0 && !totalSeconds.isNaN {
                    self?.progressSlider.value = Float(CMTimeGetSeconds(time) / totalSeconds)
                }
            }
        }
        
        player?.play()
        isPlaying = true
        playPauseButton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
    }
    
    @objc private func trackDidFinish() {
        switch repeatMode {
        case .one:
            player?.seek(to: .zero)
            player?.play()
        case .all:
            playNextTrack()
        case .off:
            if currentIndex < tracks.count - 1 {
                playNextTrack()
            } else {
                isPlaying = false
                playPauseButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
            }
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }
    
    private func updateShuffleButton() {
        shuffleButton.tintColor = isShuffleOn ? UIColor(named: "AccentPurple") : .white
    }
    
    private func updateRepeatButton() {
        switch repeatMode {
        case .off:
            repeatButton.setImage(UIImage(systemName: "repeat"), for: .normal)
            repeatButton.tintColor = .white
        case .one:
            repeatButton.setImage(UIImage(systemName: "repeat.1"), for: .normal)
            repeatButton.tintColor = UIColor(named: "AccentPurple")
        case .all:
            repeatButton.setImage(UIImage(systemName: "repeat"), for: .normal)
            repeatButton.tintColor = UIColor(named: "AccentPurple")
        }
    }
    private func updateLikeButton() {
        guard let track = track else { return }
        let isLiked = LikedSongsManager.shared.isLiked(track)
        let imageName = isLiked ? "heart.fill" : "heart"
        likeButton.setImage(UIImage(systemName: imageName), for: .normal)
        likeButton.tintColor = isLiked ? UIColor(named: "AccentPurple") : .white
    }
    private func updateDownloadButton() {
        guard let track = track else { return }
        let isDownloaded = DownloadsManager.shared.isDownloaded(track)
        let imageName = isDownloaded ? "arrow.down.circle.fill" : "arrow.down.circle"
        downloadButton.setImage(UIImage(systemName: imageName), for: .normal)
        downloadButton.tintColor = isDownloaded ? UIColor(named: "AccentPurple") : .white
        
    }

    
    private func playTrack(at index: Int) {
        guard index >= 0 && index < tracks.count else { return }
        currentIndex = index
        track = tracks[index]
        setupUI()
        configurePlayer()
    }
   
    private func playNextTrack() {
        if isShuffleOn {
            let randomIndex = Int.random(in: 0..<tracks.count)
            playTrack(at: randomIndex)
        } else {
            var nextIndex = currentIndex + 1
            if nextIndex >= tracks.count {
                nextIndex = 0
            }
            playTrack(at: nextIndex)
        }
    }
    
    private func playPreviousTrack() {
        if isShuffleOn {
            let randomIndex = Int.random(in: 0..<tracks.count)
            playTrack(at: randomIndex)
        } else {
            var prevIndex = currentIndex - 1
            if prevIndex < 0 {
                prevIndex = tracks.count - 1
            }
            playTrack(at: prevIndex)
        }
    }

    private func showPlaylistPicker(for track: Track) {
        let alert = UIAlertController(title: "Add to Playlist", message: nil, preferredStyle: .actionSheet)
        
        let playlists = PlaylistManager.shared.getPlaylists()
        for playlist in playlists {
            let action = UIAlertAction(title: playlist.name, style: .default) { _ in
                PlaylistManager.shared.addTrack(track, to: playlist.id)
                self.showAddedAlert(playlistName: playlist.name)
            }
            alert.addAction(action)
        }
        
        let createAction = UIAlertAction(title: "+ Create New Playlist", style: .default) { [weak self] _ in
            self?.showCreatePlaylistAlert(for: track)
        }
        alert.addAction(createAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }

    private func showCreatePlaylistAlert(for track: Track) {
        let alert = UIAlertController(title: "New Playlist", message: "Enter playlist name", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Playlist name"
        }
        
        let createAction = UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            if let name = alert.textFields?.first?.text, !name.isEmpty {
                let newPlaylist = PlaylistManager.shared.createPlaylist(name: name)
                PlaylistManager.shared.addTrack(track, to: newPlaylist.id)
                self?.showAddedAlert(playlistName: name)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(createAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    private func showAddedAlert(playlistName: String) {
        let alert = UIAlertController(title: "Added!", message: "Track added to \(playlistName)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    private func showDownloadAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            alert.dismiss(animated: true)
        }
    }
    
    // MARK: - Actions
    @IBAction func artistNameTapped(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "showArtistFromPlayer", sender: nil)
    }

    @IBAction func likeTapped(_ sender: UIButton) {
        guard let track = track else { return }
        _ = LikedSongsManager.shared.toggleLike(track)
      
        UIView.animate(withDuration: 0.1, animations: {
            self.likeButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.likeButton.transform = .identity
            }
        }
        
        updateLikeButton()
    }
    @IBAction func downloadTapped(_ sender: UIButton) {
        guard let track = track else { return }
        
        let wasDownloaded = DownloadsManager.shared.toggleDownload(track)
        
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                sender.transform = .identity
            }
        }
        
        updateDownloadButton()
        let message = wasDownloaded ? "Downloaded" : "Removed from downloads"
        showDownloadAlert(message: message)
    }
    
    @IBAction func menuTapped(_ sender: UIButton) {
        guard let track = track else { return }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let addToPlaylistAction = UIAlertAction(title: "Add to Playlist", style: .default) { [weak self] _ in
            self?.showPlaylistPicker(for: track)
        }
        
        let shareAction = UIAlertAction(title: "Share", style: .default) { _ in
            print("Share")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(addToPlaylistAction)
        alert.addAction(shareAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    @IBAction func playPauseTapped(_ sender: UIButton) {
        if isPlaying {
            player?.pause()
            playPauseButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        } else {
            player?.play()
            playPauseButton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
        }
        isPlaying.toggle()
    }
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        guard let duration = player?.currentItem?.duration else { return }
        let totalSeconds = CMTimeGetSeconds(duration)
        let seekTime = CMTime(seconds: Double(sender.value) * totalSeconds, preferredTimescale: 1)
        player?.seek(to: seekTime)
    }
    @IBAction func previousTapped(_ sender: UIButton) {
        playPreviousTrack()
    }
    
    @IBAction func nextTapped(_ sender: UIButton) {
        playNextTrack()
    }
    
    @IBAction func shuffleTapped(_ sender: UIButton) {
        isShuffleOn.toggle()
        updateShuffleButton()
    }
    
    @IBAction func repeatTapped(_ sender: UIButton) {
        switch repeatMode {
        case .off:
            repeatMode = .all
        case .all:
            repeatMode = .one
        case .one:
            repeatMode = .off
        }
        updateRepeatButton()
    }

}
// MARK: - Navigation
extension PlayerViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showArtistFromPlayer",
           let artistVC = segue.destination as? ArtistViewController {
            artistVC.artistName = track?.artistName
            artistVC.artistImageUrl = track?.artworkUrl600
        }
    }
    
}
