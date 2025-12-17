//
//  HomeViewController.swift
//  HearoApp
//
//  Created by Zhasmin Suleimenova on 09.12.2025.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var featuringCollectionView: UICollectionView!
    @IBOutlet weak var recentlyPlayedCollectionView: UICollectionView!
    @IBOutlet weak var mixesCollectionView: UICollectionView!
    @IBOutlet weak var albumsCollectionView: UICollectionView!
    
    private var featuringTracks: [Track] = []
    private var recentlyPlayedTracks: [Track] = []
    private var mixesTracks: [Track] = []
    private var albums: [Album] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionViews()
        loadData()
    }
    
    private func setupCollectionViews() {
        let nib = UINib(nibName: "TrackCollectionViewCell", bundle: nil)
        
        featuringCollectionView.register(nib, forCellWithReuseIdentifier: "TrackCell")
        recentlyPlayedCollectionView.register(nib, forCellWithReuseIdentifier: "TrackCell")
        mixesCollectionView.register(nib, forCellWithReuseIdentifier: "TrackCell")
        albumsCollectionView.register(nib, forCellWithReuseIdentifier: "AlbumCell")
        
        featuringCollectionView.delegate = self
        featuringCollectionView.dataSource = self
        
        recentlyPlayedCollectionView.delegate = self
        recentlyPlayedCollectionView.dataSource = self
        
        mixesCollectionView.delegate = self
        mixesCollectionView.dataSource = self
        
        albumsCollectionView.delegate = self
        albumsCollectionView.dataSource = self
    }
    
    private func loadData() {
    
        NetworkManager.shared.searchTracks(query: "top hits 2024") { [weak self] result in
            switch result {
            case .success(let tracks):
                self?.featuringTracks = tracks
                DispatchQueue.main.async {
                    self?.featuringCollectionView.reloadData()
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
   
        let recentTracks = PlayHistoryManager.shared.getRecentlyPlayedTracks(limit: 20)
        if !recentTracks.isEmpty {
            self.recentlyPlayedTracks = recentTracks
            DispatchQueue.main.async {
                self.recentlyPlayedCollectionView.reloadData()
            }
        } else {
            NetworkManager.shared.searchTracks(query: "chainsmokers") { [weak self] result in
                switch result {
                case .success(let tracks):
                    self?.recentlyPlayedTracks = tracks
                    DispatchQueue.main.async {
                        self?.recentlyPlayedCollectionView.reloadData()
                    }
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }
            
        NetworkManager.shared.searchTracks(query: "martin garrix") { [weak self] result in
            switch result {
            case .success(let tracks):
                self?.mixesTracks = tracks
                DispatchQueue.main.async {
                    self?.mixesCollectionView.reloadData()
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }

        NetworkManager.shared.searchAlbums(query: "top albums 2024") { [weak self] result in
            switch result {
            case .success(let albums):
                self?.albums = albums
                DispatchQueue.main.async {
                    self?.albumsCollectionView.reloadData()
                }
            case .failure(let error):
                print("Error loading albums: \(error)")
            }
        }
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            
        let recentTracks = PlayHistoryManager.shared.getRecentlyPlayedTracks(limit: 20)
        if !recentTracks.isEmpty {
            self.recentlyPlayedTracks = recentTracks
            self.recentlyPlayedCollectionView.reloadData()
        }
    }
    
    @IBAction func profileTapped(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "showProfileFromHome", sender: nil)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == featuringCollectionView {
            return featuringTracks.count
        } else if collectionView == recentlyPlayedCollectionView {
            return recentlyPlayedTracks.count
        } else if collectionView == mixesCollectionView {
            return mixesTracks.count
        } else if collectionView == albumsCollectionView {
            return albums.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == albumsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as! TrackCollectionViewCell
            let album = albums[indexPath.item]
            
            cell.trackNameLabel.text = album.collectionName ?? "Unknown Album"
            cell.artistNameLabel.text = album.artistName ?? "Unknown Artist"
            
            let placeholder = UIImage(systemName: "music.note")
            if let urlString = album.artworkUrl100,
                let url = URL(string: urlString) {
                    cell.artworkImageView.kf.setImage(
                    with: url,
                    placeholder: placeholder,
                    options: [.transition(.fade(0.2))]
                )
            } else {
                cell.artworkImageView.image = placeholder
            }
                    
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackCell", for: indexPath) as! TrackCollectionViewCell
        
        let track: Track
        if collectionView == featuringCollectionView {
            track = featuringTracks[indexPath.item]
        } else if collectionView == recentlyPlayedCollectionView {
            track = recentlyPlayedTracks[indexPath.item]
        } else {
            track = mixesTracks[indexPath.item]
        }
        
        cell.configure(with: track)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == albumsCollectionView {
            let album = albums[indexPath.item]
            performSegue(withIdentifier: "showAlbumFromHome", sender: album)
            return
        }
        
        let tracks: [Track]
        let index = indexPath.item
        
        if collectionView == featuringCollectionView {
            tracks = featuringTracks
        } else if collectionView == recentlyPlayedCollectionView {
            tracks = recentlyPlayedTracks
        } else {
            tracks = mixesTracks
        }
        
        performSegue(withIdentifier: "showPlayerFromHome", sender: (tracks, index))
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 140, height: 170)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
}

// MARK: - Navigation
extension HomeViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPlayerFromHome",
           let playerVC = segue.destination as? PlayerViewController,
           let (tracks, index) = sender as? ([Track], Int) {
            playerVC.tracks = tracks
            playerVC.currentIndex = index
            playerVC.track = tracks[index]
        }
        
        if segue.identifier == "showAlbumFromHome",
           let albumVC = segue.destination as? AlbumViewController,
           let album = sender as? Album {
            albumVC.album = album
        }
    }
}
