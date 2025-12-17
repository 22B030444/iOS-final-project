//
//  PlaylistsViewController.swift
//  HearoApp
//
//  Created by Zhasmin Suleimenova on 13.12.2025.
//

import UIKit

class PlaylistsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var playlists: [Playlist] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPlaylists()
    }
    
    private func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func loadPlaylists() {
        playlists = PlaylistManager.shared.getPlaylists()
        tableView.reloadData()
    }
    
    @IBAction func addPlaylistTapped(_ sender: UIButton) {
        showCreatePlaylistAlert()
    }
    
    private func showCreatePlaylistAlert() {
        let alert = UIAlertController(title: "New Playlist", message: "Enter playlist name", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Playlist name"
        }
        
        let createAction = UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            if let name = alert.textFields?.first?.text, !name.isEmpty {
                _ = PlaylistManager.shared.createPlaylist(name: name)
                self?.loadPlaylists()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(createAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension PlaylistsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistCell", for: indexPath) as? PlaylistCell else {
            return UITableViewCell()
        }
        
        let playlist = playlists[indexPath.row]
        cell.configure(with: playlist)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let playlist = playlists[indexPath.row]
        performSegue(withIdentifier: "showPlaylistDetail", sender: playlist)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let playlist = playlists[indexPath.row]
            PlaylistManager.shared.deletePlaylist(playlist)
            playlists.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

// MARK: - Navigation
extension PlaylistsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPlaylistDetail",
           let detailVC = segue.destination as? PlaylistDetailViewController,
           let playlist = sender as? Playlist {
            detailVC.playlist = playlist
        }
    }
}
