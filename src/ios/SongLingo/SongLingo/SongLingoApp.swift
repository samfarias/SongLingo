//
//  SongLingoApp.swift
//  SongLingo
//
//  Created by Derek Huang on 3/10/26.
//

// NOTE: First screen declaration
import SwiftUI

@main
struct SongLingoApp: App {
    @AppStorage("isLoggedIn") private var isLoggedIn = false

    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                ContentView()
            } else {
                Login()
            }
        }
    }
}
