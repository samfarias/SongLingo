//
//  PracticeGameOptions.swift
//  SongLingo
//
//  Created by Jaci on 4/20/26.
//

import SwiftUI

struct PracticeGameOptions: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    //Sends to Word Cards Screen
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.purple.opacity(0.5))
                        VStack (alignment: .leading) {
                            Text("Word Cards")
                                .foregroundStyle(Color.black)
                                .bold()
                                .font(.title2)
                        }
                        .padding(.horizontal)
                        .padding(.vertical)
                    }
                    .padding()
                    .padding(.bottom, 30)
                    
                    //Sends to Lyric Match Screen
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.purple.opacity(0.5))
                        VStack (alignment: .leading) {
                            Text("Lyric Match")
                                .foregroundStyle(Color.black)
                                .bold()
                                .font(.title2)
                        }
                        .padding(.horizontal)
                        .padding(.vertical)
                    }
                    .padding()
                    .padding(.bottom, 30)
                    
                    //Sends to Complete the Lyrics Screen
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.purple.opacity(0.5))
                        VStack (alignment: .leading) {
                            Text("Complete the Lyrics")
                                .foregroundStyle(Color.black)
                                .bold()
                                .font(.title2)
                        }
                        .padding(.horizontal)
                        .padding(.vertical)
                    }
                    .padding()
                }
                .padding(.top, 100)
            }
            .navigationTitle("Practice New Words!")
            .background(Color.purple.opacity(0.2))
        }
    }
}

#Preview {
    PracticeGameOptions()
}
