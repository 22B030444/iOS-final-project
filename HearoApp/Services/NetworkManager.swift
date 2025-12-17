//
//  NetworkManager.swift
//  HearoApp
//
//  Created by Zhasmin Suleimenova on 09.12.2025.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case networkError(String)
    
    var message: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to parse data"
        case .networkError(let msg):
            return msg
        }
    }
}

class NetworkManager {
    
    static let shared = NetworkManager()
    private init() {}
    
    private let baseURL = "https://itunes.apple.com"
    
    // MARK: - Search Tracks
    func searchTracks(query: String, completion: @escaping (Result<[Track], NetworkError>) -> Void) {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/search?term=\(encodedQuery)&entity=song&limit=50") else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.networkError(error.localizedDescription)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(iTunesResponse.self, from: data)
                    completion(.success(result.results))
                } catch {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
    }
    
    // MARK: - Search Albums
    func searchAlbums(query: String, completion: @escaping (Result<[Album], NetworkError>) -> Void) {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/search?term=\(encodedQuery)&entity=album&limit=20") else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.networkError(error.localizedDescription)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(iTunesAlbumResponse.self, from: data)
                    completion(.success(result.results))
                } catch {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
    }
    
    // MARK: - Get Album Tracks
    func getAlbumTracks(collectionId: Int, completion: @escaping (Result<[Track], NetworkError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/lookup?id=\(collectionId)&entity=song") else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.networkError(error.localizedDescription)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(iTunesResponse.self, from: data)
                    let tracks = Array(result.results.dropFirst())
                    completion(.success(tracks))
                } catch {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
    }
    
    // MARK: - Get Artist Tracks
    func getArtistTracks(artistName: String, completion: @escaping (Result<[Track], NetworkError>) -> Void) {
        guard let encodedName = artistName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/search?term=\(encodedName)&entity=song&limit=50") else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.networkError(error.localizedDescription)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(iTunesResponse.self, from: data)
                    completion(.success(result.results))
                } catch {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
    }
}
