//
//  CurrentlyPlayingView.swift
//  SpotifyClone
//
//  Created by Simon Puchner on 30.04.25.
//

import SwiftUI
import SDWebImageSwiftUI

struct PlayerView: View {
    
    @Environment(\.scenePhase) private var scenePhase
    @StateObject var viewModel = PlayerViewModel()
    @EnvironmentObject var loginViewModel: LoginViewModel
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                WebImage(url: viewModel.albumImageURL)
                    .resizable()
                    .indicator(.activity)
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                
                Text(viewModel.trackName)
                    .font(.title)
                    .bold()
                
                Text(viewModel.artistName)
                    .font(.headline)
            }
            .padding()
            
            if !viewModel.isPlaying {
                Text("Actually no song playing... 🔇")
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    print("logout")
                    loginViewModel.logout()
                } label: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .foregroundStyle(Color.spotifyGreen)
                }
            }
        }
        
        .onAppear {
            viewModel.startPolling()
        }
        .onChange(of: scenePhase) { oldValue, newValue in
            switch newValue {
            case .background:
                viewModel.stopPolling()
            case .inactive:
                viewModel.stopPolling()
            case .active:
                viewModel.startPolling()
            @unknown default:
                break
            }
        }
    }
}

#Preview {
    PlayerView()
}
