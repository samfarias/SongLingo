//
//  PlaylistCollection.swift
//  SongLingo
//
//  Created by Jaci on 5/7/26.
//

import SwiftUI

struct PlaylistCollection: View {
    
    @State private var homeData: HomeScreenData?
    
    
    var body: some View {
        ScrollView {
            Spacer(minLength: 50)
            
            Text("Your Playlists")
                .font(.title)
                .bold()
                .padding(.bottom, 20)
            
            HStack {
                Text("Recently Played")
                    .font(.headline)
                    .padding(.leading)
                Spacer()
            }
            .padding(.top)
            
            Divider()
                .frame(height: 1)
                .background(Color.black)
                .padding(.horizontal)
                .padding(.top, 5)
            
            //PLAYLISTS HERE
            
            HStack {
                Text("New For You")
                    .font(.headline)
                    .padding(.leading)
                Spacer()
            }
            .padding(.top)
            
            Divider()
                .frame(height: 1)
                .background(Color.black)
                .padding(.horizontal)
                .padding(.top, 5)
            
            //PLAYLISTS HERE
            
            HStack {
                Text("A Trip Cown Memory Lane")
                    .font(.headline)
                    .padding(.leading)
                Spacer()
            }
            .padding(.top)
            
            Divider()
                .frame(height: 1)
                .background(Color.black)
                .padding(.horizontal)
                .padding(.top, 5)
            
            //PLAYLISTS HERE/
        }
    }
}

#Preview {
    PlaylistCollection()
}
