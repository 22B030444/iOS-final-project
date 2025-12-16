//
//  LikedSongsViewController.swift
//  HearoApp
//
//  Created by Zhasmin Suleimenova on 11.12.2025.
//

import UIKit

class LikedSongsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var likedSongs: [Track] = []
    
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
       
        let nib = UINib(nibName: "TrackTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TrackCell")
    }
    
    private func loadLikedSongs() {
        likedSongs = LikedSongsManager.shared.getLikedSongs()
        tableView.reloadData()
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension LikedSongsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return likedSongs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TrackTableViewCell
        let track = likedSongs[indexPath.row]
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
            let track = likedSongs[indexPath.row]
            LikedSongsManager.shared.removeTrack(track)
            likedSongs.remove(at: indexPath.row)
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
            playerVC.tracks = likedSongs
            playerVC.currentIndex = index
            playerVC.track = likedSongs[index]
        }
    }
}
    
