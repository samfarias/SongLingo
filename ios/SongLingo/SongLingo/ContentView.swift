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
            // Each tab can be wrapped in its own NavigationStack if needed
            Dashboard()
                .tabItem {
                    Label(Constants.homeString, systemImage: Constants.homeIcon)
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

    }
}

#Preview {
    ContentView()
}
