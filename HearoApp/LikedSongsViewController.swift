//
//  LikedSongsViewController.swift
//  HearoApp
//
//  Created by Zhasmin Suleimenova on 11.12.2025.
//

import UIKit

class LikedSongsViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private var likedSongs: [Track] = []
    private var filteredSongs: [Track] = []
    private var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadLikedSongs()
    }
    
    private func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        let nib = UINib(nibName: "TrackTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TrackCell")
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
    }
    
    private func loadLikedSongs() {
        likedSongs = LikedSongsManager.shared.getLikedSongs()
        filteredSongs = likedSongs
        tableView.reloadData()
    }
    
    private func filterSongs(with searchText: String) {
        if searchText.isEmpty {
            filteredSongs = likedSongs
            isSearching = false
        } else {
            isSearching = true
            filteredSongs = likedSongs.filter { track in
                let trackName = track.trackName?.lowercased() ?? ""
                let artistName = track.artistName?.lowercased() ?? ""
                let searchLower = searchText.lowercased()
                return trackName.contains(searchLower) || artistName.contains(searchLower)
            }
        }
        tableView.reloadData()
    }
}

// MARK: - UISearchBarDelegate
extension LikedSongsViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterSongs(with: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filterSongs(with: "")
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension LikedSongsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = filteredSongs.count
        
        if count == 0 {
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: tableView.bounds.height))
            messageLabel.text = isSearching ? "No results found" : "No liked songs yet"
            messageLabel.textColor = .white
            messageLabel.textAlignment = .center
            messageLabel.font = UIFont.systemFont(ofSize: 16)
            tableView.backgroundView = messageLabel
        } else {
            tableView.backgroundView = nil
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TrackTableViewCell
        let track = filteredSongs[indexPath.row]
        cell.configure(with: track)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showPlayerFromLiked", sender: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let track = filteredSongs[indexPath.row]
            LikedSongsManager.shared.removeTrack(track)
            
            if isSearching {
                filteredSongs.remove(at: indexPath.row)
                likedSongs.removeAll { $0.trackId == track.trackId }
            } else {
                likedSongs.remove(at: indexPath.row)
                filteredSongs = likedSongs
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

// MARK: - Navigation
extension LikedSongsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPlayerFromLiked",
           let playerVC = segue.destination as? PlayerViewController,
           let index = sender as? Int {
            playerVC.tracks = filteredSongs
            playerVC.currentIndex = index
            playerVC.track = filteredSongs[index]
        }
    }
}
