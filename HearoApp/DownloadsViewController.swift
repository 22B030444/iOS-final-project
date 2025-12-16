//
//  DownloadsViewController.swift
//  HearoApp
//
//  Created by Zhasmin Suleimenova on 16.12.2025.
//


import UIKit

class DownloadsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var downloadedTracks: [DownloadedTrack] = []
    private var filteredTracks: [DownloadedTrack] = []
    private var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadDownloads()
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
    
    private func loadDownloads() {
        downloadedTracks = DownloadsManager.shared.getDownloadedTracks()
        filteredTracks = downloadedTracks
        tableView.reloadData()
    }
    
    private func filterTracks(with searchText: String) {
        if searchText.isEmpty {
            filteredTracks = downloadedTracks
            isSearching = false
        } else {
            isSearching = true
            filteredTracks = downloadedTracks.filter { downloaded in
                let trackName = downloaded.track.trackName?.lowercased() ?? ""
                let artistName = downloaded.track.artistName?.lowercased() ?? ""
                let searchLower = searchText.lowercased()
                return trackName.contains(searchLower) || artistName.contains(searchLower)
            }
        }
        tableView.reloadData()
    }
}

// MARK: - UISearchBarDelegate
extension DownloadsViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterTracks(with: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filterTracks(with: "")
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension DownloadsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = filteredTracks.count
        
        if count == 0 {
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: tableView.bounds.height))
            messageLabel.text = isSearching ? "No results found" : "No downloads yet"
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
        let downloadedTrack = filteredTracks[indexPath.row]
        cell.configure(with: downloadedTrack.track)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showPlayerFromDownloads", sender: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let downloadedTrack = filteredTracks[indexPath.row]
            DownloadsManager.shared.removeTrack(downloadedTrack.track)
            
            if isSearching {
                filteredTracks.remove(at: indexPath.row)
                downloadedTracks.removeAll { $0.track.trackId == downloadedTrack.track.trackId }
            } else {
                downloadedTracks.remove(at: indexPath.row)
                filteredTracks = downloadedTracks
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

// MARK: - Navigation
extension DownloadsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPlayerFromDownloads",
           let playerVC = segue.destination as? PlayerViewController,
           let index = sender as? Int {
            let tracks = filteredTracks.map { $0.track }
            playerVC.tracks = tracks
            playerVC.currentIndex = index
            playerVC.track = tracks[index]
        }
    }
}
