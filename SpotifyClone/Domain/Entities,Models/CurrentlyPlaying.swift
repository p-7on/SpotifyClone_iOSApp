//
//  CurrentlyPlaying.swift
//  SpotifyClone
//
//  Created by Simon Puchner on 30.04.25.
//

import Foundation

struct CurrentlyPlaying: Decodable {
    let item: Track
}

struct Track: Decodable {
    let name: String
    let album: Album
    let artists: [Artist]
}

struct Album: Decodable {
    let images: [AlbumImage]
}

struct AlbumImage: Decodable {
    let url: String
}

struct Artist: Decodable {
    let name: String
}
