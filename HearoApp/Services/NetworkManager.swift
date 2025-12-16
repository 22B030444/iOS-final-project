//
//  NetworkManager.swift
//  HearoApp
//
//  Created by Zhasmin Suleimenova on 09.12.2025.
//

import Foundation

class NetworkManager {
    
    static let shared = NetworkManager()
    private init() {}
    
    private let baseURL = "https://itunes.apple.com"
    
    func searchTracks(query: String, completion: @escaping (Result<[Track], Error>) -> Void) {
        let searchQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "\(baseURL)/search?term=\(searchQuery)&media=music&limit=20"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(iTunesResponse.self, from: data)
                completion(.success(response.results))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func getTopSongs(genre: String = "pop", completion: @escaping (Result<[Track], Error>) -> Void) {
        searchTracks(query: genre, completion: completion)
    }
    func searchAlbums(query: String, completion: @escaping (Result<[Album], Error>) -> Void) {
        let searchQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "\(baseURL)/search?term=\(searchQuery)&media=music&entity=album&limit=20"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(iTunesAlbumResponse.self, from: data)
                completion(.success(response.results))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func getAlbumTracks(collectionId: Int, completion: @escaping (Result<[Track], Error>) -> Void) {
        let urlString = "\(baseURL)/lookup?id=\(collectionId)&entity=song"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(iTunesResponse.self, from: data)
                // Первый результат - это сам альбом, пропускаем его
                let tracks = response.results.filter { $0.trackId != nil }
                completion(.success(tracks))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
