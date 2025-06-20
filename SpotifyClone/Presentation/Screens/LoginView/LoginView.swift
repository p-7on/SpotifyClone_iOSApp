//
//  ContentView.swift
//  SpotifyClone
//
//  Created by Simon Puchner on 30.04.25.
//

import SwiftUI

struct LoginView: View {
    
    @StateObject var viewModel = LoginViewModel()
    
    var body: some View {
        NavigationStack {
            if (viewModel.accessToken != nil) {
                PlayerView()
                    .environmentObject(viewModel)
            } else {
                ZStack {
                    Text("🎧 Spotify")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundStyle(Color.spotifyGreen)
                    Text("Clone")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.spotifyGreen)
                        .offset(x: 90, y: 50)
                }
                
                VStack {
                    Button {
                        viewModel.login()
                    } label: {
                        Text("Login with Spotify")
                            .fontWeight(.semibold)
                            .frame(maxWidth: 200, maxHeight: 35)
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                    .tint(Color.spotifyGreen)
                    .foregroundStyle(Color.accent)
                }
                .background(Color.accent)
            }
            
        }
    }
}

#Preview {
    LoginView()
}
