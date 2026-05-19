//
//  ContentView.swift
//  SongLingo
//
//  Created by Jaci on 3/9/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            TabView {
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
            .tint(Color(red: 0.90, green: 0.15, blue: 0.25).opacity(0.8))
            .navigationBarBackButtonHidden()
        }
    }
}

#Preview {
    ContentView()
}
