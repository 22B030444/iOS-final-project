//
//  SearchViewController.swift
//  HearoApp
//
//  Created by Zhasmin Suleimenova on 10.12.2025.
//


import UIKit
import Kingfisher
enum SearchResultType {
    case track(Track)
    case album(Album)
}

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private var searchResults: [SearchResultType] = []
    private var searchTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        let nib = UINib(nibName: "TrackTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TrackCell")
    }
    
    private func search(query: String) {
        activityIndicator.startAnimating()
        searchResults.removeAll()
        
        let group = DispatchGroup()
        var trackResults: [Track] = []
        var albumResults: [Album] = []
        var networkError: NetworkError?
        
        group.enter()
        NetworkManager.shared.searchTracks(query: query) { result in
            switch result {
            case .success(let tracks):
                trackResults = tracks
            case .failure(let error):
                networkError = error
            }
            group.leave()
        }
        
        group.enter()
        NetworkManager.shared.searchAlbums(query: query) { result in
            switch result {
            case .success(let albums):
                albumResults = albums
            case .failure(let error):
                networkError = error
            }
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.activityIndicator.stopAnimating()
            
            if let error = networkError, trackResults.isEmpty && albumResults.isEmpty {
                self?.showErrorAlert(message: error.message)
                return
            }
        
            for album in albumResults.prefix(5) {
                self?.searchResults.append(.album(album))
            }
            for track in trackResults {
                self?.searchResults.append(.track(track))
            }
            
            self?.tableView.reloadData()
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Network Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTimer?.invalidate()
        
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            if !searchText.isEmpty {
                self?.search(query: searchText)
            } else {
                self?.searchResults = []
                self?.tableView.reloadData()
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let query = searchBar.text, !query.isEmpty {
            search(query: query)
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TrackTableViewCell
        
        let result = searchResults[indexPath.row]
        
        switch result {
        case .track(let track):
            cell.trackNameLabel.text = track.trackName ?? "Unknown"
            cell.artistNameLabel.text = track.artistName ?? "Unknown Artist"
            
            cell.artworkImageView.image = UIImage(systemName: "music.note")
            cell.artworkImageView.tintColor = .gray
            
            if let urlString = track.artworkUrl100,
               let url = URL(string: urlString) {
                cell.artworkImageView.kf.setImage(
                    with: url,
                    placeholder: UIImage(systemName: "music.note"),
                    options: [.transition(.fade(0.2))]
                )
            }
            
        case .album(let album):
            cell.trackNameLabel.text = album.collectionName ?? "Unknown Album"
            cell.artistNameLabel.text = "💿 \(album.artistName ?? "Unknown Artist")"
            
            cell.artworkImageView.image = UIImage(systemName: "square.stack")
            cell.artworkImageView.tintColor = UIColor(named: "AccentPurple")
            
            if let urlString = album.artworkUrl100,
               let url = URL(string: urlString) {
                cell.artworkImageView.kf.setImage(
                    with: url,
                    placeholder: UIImage(systemName: "music.note"),
                    options: [.transition(.fade(0.2))]
                )
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = searchResults[indexPath.row]
        
        switch result {
        case .track:
            let tracks = searchResults.compactMap { result -> Track? in
                if case .track(let track) = result {
                    return track
                }
                return nil
            }
            var trackIndex = 0
            var currentTrackCount = 0
            for (i, r) in searchResults.enumerated() {
                if case .track = r {
                    if i == indexPath.row {
                        trackIndex = currentTrackCount
                        break
                    }
                    currentTrackCount += 1
                }
            }
            
            performSegue(withIdentifier: "showPlayerFromSearch", sender: (tracks, trackIndex))
            
        case .album(let album):
            performSegue(withIdentifier: "showAlbumFromSearch", sender: album)
        }
    }
}

// MARK: - Navigation
extension SearchViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPlayerFromSearch",
           let playerVC = segue.destination as? PlayerViewController,
           let (tracks, index) = sender as? ([Track], Int) {
            playerVC.tracks = tracks
            playerVC.currentIndex = index
            playerVC.track = tracks[index]
        }
        
        if segue.identifier == "showAlbumFromSearch",
           let albumVC = segue.destination as? AlbumViewController,
           let album = sender as? Album {
            albumVC.album = album
        }
    }
}
