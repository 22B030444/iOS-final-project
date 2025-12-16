//
//  ArtistViewController.swift
//  HearoApp
//
//  Created by Zhasmin Suleimenova on 15.12.2025.
//

import UIKit

class ArtistViewController: UIViewController {
    
    @IBOutlet weak var artistImageView: UIImageView!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var listenersLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var artistName: String?
    var artistImageUrl: String?
    private var tracks: [Track] = []
    private var isFollowing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadArtistTracks()
    }
    
    private func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
    
        let nib = UINib(nibName: "TrackTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TrackCell")
        
        artistNameLabel.text = artistName ?? "Unknown Artist"
     
        let listeners = Double.random(in: 1.0...10.0)
        listenersLabel.text = String(format: "%.1f M monthly listeners", listeners)
        
        updateFollowButton()
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor.white.cgColor
   
        loadArtistImage()
    }
    
    private func loadArtistImage() {
        if let urlString = artistImageUrl,
           let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.artistImageView.image = image
                    }
                }
            }.resume()
        } else {
            artistImageView.image = UIImage(systemName: "person.circle.fill")
            artistImageView.tintColor = UIColor(named: "AccentPurple")
        }
    }
    
    private func loadArtistTracks() {
        guard let artistName = artistName else { return }
        
        NetworkManager.shared.searchTracks(query: artistName) { [weak self] result in
            switch result {
            case .success(let tracks):
                self?.tracks = tracks.filter { $0.artistName?.lowercased().contains(artistName.lowercased()) ?? false }
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Error loading artist tracks: \(error)")
            }
        }
    }
    
    private func updateFollowButton() {
        if isFollowing {
            followButton.setTitle("Following", for: .normal)
            followButton.setTitleColor(.black, for: .normal)
            followButton.backgroundColor = .white
        } else {
            followButton.setTitle("Follow", for: .normal)
            followButton.setTitleColor(.white, for: .normal)
            followButton.backgroundColor = .clear
            followButton.layer.borderColor = UIColor.white.cgColor
        }
    }

    // MARK: - Actions
    @IBAction func followTapped(_ sender: UIButton) {
        guard let name = artistName else { return }
                
        isFollowing = FollowedArtistsManager.shared.toggleFollow(name: name, imageUrl: artistImageUrl)
                
        UIView.animate(withDuration: 0.1, animations: {
            self.followButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.followButton.transform = .identity
            }
        }
        updateFollowButton()
    }
    
    @IBAction func playAllTapped(_ sender: UIButton) {
        if !tracks.isEmpty {
            performSegue(withIdentifier: "showPlayerFromArtist", sender: 0)
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ArtistViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TrackTableViewCell
        let track = tracks[indexPath.row]
        cell.configure(with: track)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showPlayerFromArtist", sender: indexPath.row)
    }
}

// MARK: - Navigation
extension ArtistViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPlayerFromArtist",
           let playerVC = segue.destination as? PlayerViewController,
           let index = sender as? Int {
            playerVC.tracks = tracks
            playerVC.currentIndex = index
            playerVC.track = tracks[index]
        }
    }
}
