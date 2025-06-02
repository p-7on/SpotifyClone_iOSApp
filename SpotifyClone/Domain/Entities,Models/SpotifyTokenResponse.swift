//
//  SpotifyTokenResponse.swift
//  SpotifyClone
//
//  Created by Simon Puchner on 30.04.25.
//

import Foundation

struct SpotifyTokenResponse: Decodable {
    let accessToken: String
    let tokenType: String?
    let expiresIn: Int?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
    }
}
