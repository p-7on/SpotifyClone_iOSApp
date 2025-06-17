//
//  LoginViewModel.swift
//  SpotifyClone
//
//  Created by Simon Puchner on 01.05.25.
//

import Foundation
import Combine

class LoginViewModel: ObservableObject {
    
    @Published var accessToken: SpotifyTokenResponse?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        SpotifyAuthService.shared.$accessToken
            .receive(on: DispatchQueue.main)
            .assign(to: &$accessToken)
        
        loadTokenFromKeychain()
    }
    
    func login() {
        SpotifyAuthService.shared.authorize()
    }
    
    func logout() {
        KeychainManager.shared.delete(forKey: "spotifyAccessToken")
        KeychainManager.shared.delete(forKey: "spotifyAccessTokenExpiresIn")
        KeychainManager.shared.delete(forKey: "spotifyAccessTokenFetchDate")
        SpotifyAuthService.shared.accessToken = nil
    }
    
    private func isTokenValid() -> Bool {
        guard let expiresInString = KeychainManager.shared.get(forKey: "spotifyAccessTokenExpiresIn"),
              let expiresIn = Double(expiresInString),
              let savedDateString = KeychainManager.shared.get(forKey: "spotifyAccessTokenFetchDate"),
              let savedDate = ISO8601DateFormatter().date(from: savedDateString) else {
            return false
        }
        
        let expiryDate = savedDate.addingTimeInterval(expiresIn)
        return expiryDate > Date()
    }
    
    func loadTokenFromKeychain() {
        if let accessToken = KeychainManager.shared.get(forKey: "spotifyAccessToken"),
           isTokenValid() {
            let tokenResponse = SpotifyTokenResponse(
                accessToken: accessToken,
                tokenType: nil,
                expiresIn: Int(KeychainManager.shared.get(forKey: "spotifyAccessTokenExpiresIn") ?? "0")
            )
            self.accessToken = tokenResponse
            SpotifyAuthService.shared.accessToken = tokenResponse
            print("Token loaded from Keychain")
        } else {
            logout()
            print("Token expired or not missing")
        }
    }
}
