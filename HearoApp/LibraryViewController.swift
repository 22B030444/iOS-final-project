//
//  LibraryViewController.swift
//  HearoApp
//
//  Created by Zhasmin Suleimenova on 11.12.2025.
//

import UIKit

class LibraryViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var recentlyPlayed: [Track] = []
    var playlists: [Playlist] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadRecentlyPlayed()
    }

    private func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        
        let nib = UINib(nibName: "TrackTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TrackCell")
    }
    
    private func loadRecentlyPlayed() {
        NetworkManager.shared.searchTracks(query: "imagine dragons") { [weak self] result in
            switch result {
            case .success(let tracks):
                self?.recentlyPlayed = Array(tracks.prefix(10))
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    // MARK: - Menu Actions
    @IBAction func playlistsTapped(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "showPlaylists", sender: nil)
        print("Playlists tapped")
    }
    
    @IBAction func downloadsTapped(_ sender: UITapGestureRecognizer) {
        print("Downloads tapped")
    }
    
    @IBAction func likedSongsTapped(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "showLikedSongs", sender: nil)
        print("Liked songs tapped")
    }
    
    @IBAction func artistsTapped(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "showArtists", sender: nil)
        print("Artists tapped")
    }
    @IBAction func profileTapped(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "showProfileFromLibrary", sender: nil)
        print("Profile tapped")
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension LibraryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentlyPlayed.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TrackTableViewCell
        let track = recentlyPlayed[indexPath.row]
        cell.configure(with: track)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showPlayerFromLibrary", sender: indexPath.row)
    }
}

// MARK: - Navigation
extension LibraryViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPlayerFromLibrary",
           let playerVC = segue.destination as? PlayerViewController,
           let index = sender as? Int {
            playerVC.tracks = recentlyPlayed
            playerVC.currentIndex = index
            playerVC.track = recentlyPlayed[index]
        }
        if segue.identifier == "showProfileFromLibrary",
           let profileVC = segue.destination as? ProfileViewController {
            profileVC.playlistsCount = playlists.count
        }
    }

}
