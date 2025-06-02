//
//  SpotifyAuthService.swift
//  SpotifyClone
//
//  Created by Simon Puchner on 30.04.25.
//

import Foundation
import CryptoKit
import AuthenticationServices
import Combine

class SpotifyAuthService: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return UIApplication.shared.connectedScenes
                    .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                    .first ?? ASPresentationAnchor()
    }
    
    static let shared = SpotifyAuthService()
    
    private let clientId = "54322e3b73564199acc2049e6cb9d51f"
    private let redirectURI = "myspotifycloneapp://callback"
    private let scopes = "user-read-playback-state user-read-currently-playing"
    
    private var codeVerifier = ""
    private var session: ASWebAuthenticationSession?
    
    @Published var accessToken: SpotifyTokenResponse?
    
    func authorize() {
        codeVerifier = generateCodeVerifier()
        let challenge = codeChallenge(for: codeVerifier)
        
        let authURL = URL(string: "https://accounts.spotify.com/authorize?" +
                          "client_id=\(clientId)&response_type=code&redirect_uri=\(redirectURI)&code_challenge_method=S256" +
                          "&code_challenge=\(challenge)&scope=\(scopes.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
                      )!
        
        let callbackScheme = "myspotifycloneapp"
        session = ASWebAuthenticationSession(
                url: authURL,
                callbackURLScheme: callbackScheme,
                completionHandler: { callbackURL, error in
                    guard let url = callbackURL,
                          let code = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                            .queryItems?.first(where: { $0.name == "code" })?.value else {
                        print("Login failed: \(error?.localizedDescription ?? "no Data")")
                        return
                    }

                    self.fetchAccessToken(with: code)
                }
            )
        
        session?.presentationContextProvider = self
        session?.prefersEphemeralWebBrowserSession = true
        session?.start()
        
    }
    
    // generates a random password for security
    private func generateCodeVerifier() -> String {
        let charset = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        return String((0..<128).map { _ in charset.randomElement()! })
    }
    
    // transform password in sha256-hash
    private func codeChallenge(for verifier: String) -> String {
        let data = Data(verifier.utf8)
        let hashed = SHA256.hash(data: data)
        return Data(hashed).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
    
    private func fetchAccessToken(with code: String) {
        print("Code received: \(code)")
        
        guard let tokenURL = URL(string: "https://accounts.spotify.com/api/token") else { return }
        
        let parameters = [
            "grant_type" : "authorization_code",
            "code" : code,
            "redirect_uri" : redirectURI,
            "client_id" : clientId,
            "code_verifier" : codeVerifier
        ]
        
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let body = parameters.compactMap { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching token: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("no data received")
                return
            }
            
            do {
                let tokenResponse = try JSONDecoder().decode(SpotifyTokenResponse.self, from: data)
                DispatchQueue.main.async {
                    self.accessToken = tokenResponse
                    print("AccessToken: \(tokenResponse.accessToken)")
                    print("Token Expires: \(String(tokenResponse.expiresIn ?? 00))")
                    
                    KeychainManager.shared.save(tokenResponse.accessToken, forKey: "spotifyAccessToken")
                    KeychainManager.shared.save(String(tokenResponse.expiresIn ?? 00), forKey: "spotifyAccessTokenExpiresIn")
                    let fetchDate = ISO8601DateFormatter().string(from: Date())
                    KeychainManager.shared.save(fetchDate, forKey: "spotifyAccessTokenFetchDate")
                    print("AccessToken saved to Keychain: \(tokenResponse.accessToken)")
                }
            } catch {
                print("Error parsing token response: \(error.localizedDescription)")
                print(String(data: data, encoding: .utf8) ?? "Keine Daten")
            }
        }
        task.resume()
    }
    
}
