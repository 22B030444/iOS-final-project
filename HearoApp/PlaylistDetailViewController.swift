//
//  PlaylistDetailViewController.swift
//  HearoApp
//
//  Created by Zhasmin Suleimenova on 13.12.2025.
//

import UIKit

class PlaylistDetailViewController: UIViewController {
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var playlistNameLabel: UILabel!
    @IBOutlet weak var trackCountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var likeButton: UIButton!
    
    var playlist: Playlist?
    private var tracks: [Track] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadTracks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTracks()
    }
    
    private func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        
        let nib = UINib(nibName: "TrackTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TrackCell")

        coverImageView.layer.cornerRadius = 12
        coverImageView.clipsToBounds = true
        playlistNameLabel.text = playlist?.name
    }
    
    private func loadTracks() {
        if let playlist = PlaylistManager.shared.getPlaylist(by: playlist?.id ?? "") {
            self.playlist = playlist
            tracks = playlist.tracks
            trackCountLabel.text = "\(tracks.count) songs"
            tableView.reloadData()
    
            loadCoverImage()
        }
    }
    
    private func loadCoverImage() {
        if let firstTrack = tracks.first,
           let urlString = firstTrack.artworkUrl600,
           let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.coverImageView.image = image
                    }
                }
            }.resume()
        }
    }
    // MARK: - Actions
    @IBAction func likeTapped(_ sender: UIButton) {
        print("Like playlist")
    }
    
    @IBAction func downloadTapped(_ sender: UIButton) {
        print("Download playlist")
    }
    
    @IBAction func playAllTapped(_ sender: UIButton) {
        if !tracks.isEmpty {
            performSegue(withIdentifier: "showPlayerFromPlaylist", sender: 0)
        }
    }
    
    private func showMenuOptions() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let renameAction = UIAlertAction(title: "Rename Playlist", style: .default) { [weak self] _ in
            self?.showRenameAlert()
        }
        
        let deleteAction = UIAlertAction(title: "Delete Playlist", style: .destructive) { [weak self] _ in
            self?.deletePlaylist()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(renameAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func showRenameAlert() {
        let alert = UIAlertController(title: "Rename Playlist", message: nil, preferredStyle: .alert)
        
        alert.addTextField { [weak self] textField in
            textField.text = self?.playlist?.name
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            if let newName = alert.textFields?.first?.text, !newName.isEmpty {
                self?.renamePlaylist(to: newName)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func renamePlaylist(to newName: String) {
        guard let playlistId = playlist?.id else { return }
        PlaylistManager.shared.renamePlaylist(id: playlistId, newName: newName)
        playlistNameLabel.text = newName
        playlist?.name = newName
    }
    
    private func deletePlaylist() {
        guard let playlist = playlist else { return }
        PlaylistManager.shared.deletePlaylist(playlist)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension PlaylistDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        performSegue(withIdentifier: "showPlayerFromPlaylist", sender: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let track = tracks[indexPath.row]
            PlaylistManager.shared.removeTrack(track, from: playlist?.id ?? "")
            tracks.remove(at: indexPath.row)
            trackCountLabel.text = "\(tracks.count) songs"
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            loadCoverImage()
        }
    }
}

// MARK: - Navigation
extension PlaylistDetailViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPlayerFromPlaylist",
           let playerVC = segue.destination as? PlayerViewController,
           let index = sender as? Int {
            playerVC.tracks = tracks
            playerVC.currentIndex = index
            playerVC.track = tracks[index]
        }
    }
}
