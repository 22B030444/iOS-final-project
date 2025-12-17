//
//  ArtistsViewController.swift
//  HearoApp
//
//  Created by Zhasmin Suleimenova on 15.12.2025.
//

import UIKit

class ArtistsViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var artists: [Artist] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadArtists()
    }
    
    private func setupUI() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
    }
    
    private func loadArtists() {
        artists = FollowedArtistsManager.shared.getFollowedArtists()
        collectionView.reloadData()
    }
    
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension ArtistsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return artists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArtistCell", for: indexPath)
        let artist = artists[indexPath.item]
        
        if let imageView = cell.viewWithTag(100) as? UIImageView,
           let nameLabel = cell.viewWithTag(101) as? UILabel {
            
            nameLabel.text = artist.name
            imageView.layer.cornerRadius = 40
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill
            imageView.image = UIImage(systemName: "person.circle.fill")
            imageView.tintColor = UIColor(named: "AccentPurple")
         
            if let urlString = artist.imageUrl,
               let url = URL(string: urlString) {
                URLSession.shared.dataTask(with: url) { data, _, _ in
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            imageView.image = image
                        }
                    }
                }.resume()
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let artist = artists[indexPath.item]
        performSegue(withIdentifier: "showArtistDetail", sender: artist)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ArtistsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 8
        let totalSpacing = spacing * 2 + 32 
        let width = floor((collectionView.frame.width - totalSpacing) / 3)
        return CGSize(width: width, height: width + 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}

// MARK: - Navigation
extension ArtistsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showArtistDetail",
           let artistVC = segue.destination as? ArtistViewController,
           let artist = sender as? Artist {
            artistVC.artistName = artist.name
            artistVC.artistImageUrl = artist.imageUrl
        }
    }
}
