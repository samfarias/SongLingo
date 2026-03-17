//
//  ContentView.swift
//  SongLingo
//
//  Created by Jaci on 3/9/26.
//

import SwiftUI

struct ContentView: View
{
    var body: some View
    {
        TabView
        {
            Tab(Constants.homeString, systemImage: Constants.homeIcon) {
                Text("Empty1")
            }
            Tab(Constants.playlistString, systemImage: Constants.playlistIcon) {
                Text("Empy2")
            }
            Tab(Constants.profileString, systemImage: Constants.profileIcon) {
                Profile()
            }
        }
    }
}

#Preview {
    ContentView()
}
