//
//  PlayerViewModel.swift
//  SpotifyClone
//
//  Created by Simon Puchner on 30.04.25.
//

import Foundation
import Combine

class PlayerViewModel: ObservableObject {
    @Published var trackName: String = ""
    @Published var artistName: String = ""
    @Published var albumImageURL: URL?
    
    private var timer: Timer?
    
    @Published var isPlaying = false
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        startPolling()
    }
    
    deinit {
        stopPolling()
    }
    
    func startPolling() {
        fetchCurrentlyPlaying()
        
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.fetchCurrentlyPlaying()
        }
    }
    
    func stopPolling() {
        timer?.invalidate()
        timer = nil
    }
    
    func fetchCurrentlyPlaying() {
        guard let token = KeychainManager.shared.get(forKey: "spotifyAccessToken"),
              let expiresString = KeychainManager.shared.get(forKey: "spotifyAccessTokenExpiresIn"),
              let expiresIn = Double(expiresString),
              let fetchDateString = KeychainManager.shared.get(forKey: "spotifyAccessTokenFetchDate"),
              let fetchDate = ISO8601DateFormatter().date(from: fetchDateString)
        else {
            print("no token in keychain")
            return
        }
        
        let expiryDate = fetchDate.addingTimeInterval(expiresIn)
        if expiryDate < Date() {
            print("token invalid or expired, login again")
            return
        }
        
        var request = URLRequest(url: URL(string: "https://api.spotify.com/v1/me/player/currently-playing")!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: CurrentlyPlaying.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.trackName = ""
                    self.artistName = ""
                    self.albumImageURL = nil
                    self.isPlaying = false
                    print("Fetch error: \(error)")
                }
            }, receiveValue: { [weak self] result in
                self?.trackName = result.item.name
                self?.artistName = result.item.artists.first?.name ?? "Unknown"
                self?.albumImageURL = URL(string: result.item.album.images.first?.url ?? "")
                self?.isPlaying = true
            })
            .store(in: &cancellables)
    }
}
