//
//  ContentView.swift
//  SongLingo
//
//  Created by Jaci on 3/9/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Dashboard()
                .tabItem {
                    Label(Constants.homeString, systemImage: Constants.homeIcon)
                }
            SpotifyPlayerView()
                .tabItem {
                    Label("Player", systemImage: "play.circle.fill")
                }
            PlaylistCollection()
                .tabItem {
                    Label(Constants.playlistString, systemImage: Constants.playlistIcon)
                }
            Profile()
                .tabItem {
                    Label(Constants.profileString, systemImage: Constants.profileIcon)
                }
        }
        .navigationBarBackButtonHidden(true)

    }
}

#Preview {
    ContentView()
}
