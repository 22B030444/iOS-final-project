//
//  AlbumViewController.swift
//  HearoApp
//
//  Created by Zhasmin Suleimenova on 16.12.2025.
//


import UIKit
import Kingfisher
class AlbumViewController: UIViewController {
    
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var album: Album?
    private var tracks: [Track] = []
    private var isSaved = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadAlbumTracks()
    }
    
    private func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        
        let nib = UINib(nibName: "TrackTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TrackCell")
        
        albumImageView.contentMode = .scaleAspectFill
        albumImageView.clipsToBounds = true
        
        albumNameLabel.text = album?.collectionName ?? "Unknown Album"
        artistNameLabel.text = album?.artistName ?? "Unknown Artist"
   
        if let album = album {
            isSaved = SavedAlbumsManager.shared.isSaved(album)
        }
        updateSaveButton()
        
        saveButton.layer.cornerRadius = 12
        saveButton.layer.borderWidth = 1
        saveButton.layer.borderColor = UIColor.white.cgColor
        
        loadAlbumImage()
    }
    
    private func loadAlbumImage() {
        let placeholder = UIImage(systemName: "music.note")
        
        if let urlString = album?.artworkUrl600,
           let url = URL(string: urlString) {
            albumImageView.kf.setImage(
                with: url,
                placeholder: placeholder,
                options: [
                    .transition(.fade(0.3)),
                    .cacheOriginalImage
                ]
            )
        } else {
            albumImageView.image = placeholder
            albumImageView.tintColor = UIColor(named: "AccentPurple")
        }
    }
    
    private func loadAlbumTracks() {
        guard let collectionId = album?.collectionId else { return }
        
        NetworkManager.shared.getAlbumTracks(collectionId: collectionId) { [weak self] result in
            switch result {
            case .success(let tracks):
                self?.tracks = tracks
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Error loading album tracks: \(error)")
            }
        }
    }
    
    private func updateSaveButton() {
        if isSaved {
            saveButton.setTitle("Saved", for: .normal)
            saveButton.setTitleColor(UIColor(named: "AccentPurple"), for: .normal)
            saveButton.backgroundColor = .white
            saveButton.layer.borderColor = UIColor(named: "AccentPurple")?.cgColor
        } else {
            saveButton.setTitle("Save", for: .normal)
            saveButton.setTitleColor(.white, for: .normal)
            saveButton.backgroundColor = .clear
            saveButton.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    // MARK: - Actions
    @IBAction func saveTapped(_ sender: UIButton) {
        guard let album = album else { return }
        
        isSaved = SavedAlbumsManager.shared.toggleSave(album)
        
        UIView.animate(withDuration: 0.1, animations: {
            self.saveButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.saveButton.transform = .identity
            }
        }
        
        updateSaveButton()
    }
    
    @IBAction func playAllTapped(_ sender: UIButton) {
        if !tracks.isEmpty {
            performSegue(withIdentifier: "showPlayerFromAlbum", sender: 0)
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension AlbumViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        performSegue(withIdentifier: "showPlayerFromAlbum", sender: indexPath.row)
    }
}

// MARK: - Navigation
extension AlbumViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPlayerFromAlbum",
           let playerVC = segue.destination as? PlayerViewController,
           let index = sender as? Int {
            playerVC.tracks = tracks
            playerVC.currentIndex = index
            playerVC.track = tracks[index]
        }
    }
}
