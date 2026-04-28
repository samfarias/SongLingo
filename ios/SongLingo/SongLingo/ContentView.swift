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
                Dashboard()
            }
            Tab(Constants.playlistString, systemImage: Constants.playlistIcon) {
                Text("Empy2")
            }
            Tab(Constants.profileString, systemImage: Constants.profileIcon) {
                Profile()
            }
        }
        .onAppear {
            // 1. target specific django endpoint
            guard let url = URL(string: "http://127.0.0.1:8000/api/home/?user_id=1") else { return }
            
            // 2. fire off request in the background
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    // 3. print django's response straight to the xcode console
                    print("\n=== DJANGO SAYS ===")
                    print(String(data: data, encoding: .utf8) ?? "no data")
                    print("===================\n")
                }
            }.resume()
        }
    }
}

#Preview {
    ContentView()
}
