//
//  AlbumsViewController.swift
//  HearoApp
//
//  Created by Zhasmin Suleimenova on 16.12.2025.
//

import UIKit

class AlbumsViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var albums: [Album] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAlbums()
    }
    
    private func setupUI() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        
        let nib = UINib(nibName: "TrackCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "AlbumCell")
    }
    
    private func loadAlbums() {
        albums = SavedAlbumsManager.shared.getSavedAlbums()
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension AlbumsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if albums.isEmpty {
            let messageLabel = UILabel(frame: collectionView.bounds)
            messageLabel.text = "No saved albums"
            messageLabel.textColor = .white
            messageLabel.textAlignment = .center
            messageLabel.font = UIFont.systemFont(ofSize: 16)
            collectionView.backgroundView = messageLabel
        } else {
            collectionView.backgroundView = nil
        }
        return albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as! TrackCollectionViewCell
        let album = albums[indexPath.item]
        
        cell.trackNameLabel.text = album.collectionName ?? "Unknown Album"
        cell.artistNameLabel.text = album.artistName ?? "Unknown Artist"
        
        cell.artworkImageView.image = UIImage(systemName: "square.stack")
        cell.artworkImageView.tintColor = UIColor(named: "AccentPurple")
        cell.artworkImageView.layer.cornerRadius = 8
        cell.artworkImageView.clipsToBounds = true
        
        if let urlString = album.artworkUrl600,
           let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        cell.artworkImageView.image = image
                    }
                }
            }.resume()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let album = albums[indexPath.item]
        performSegue(withIdentifier: "showAlbumDetail", sender: album)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension AlbumsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 48) / 2
        return CGSize(width: width, height: width + 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}

// MARK: - Navigation
extension AlbumsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAlbumDetail",
           let albumVC = segue.destination as? AlbumViewController,
           let album = sender as? Album {
            albumVC.album = album
        }
    }
}
