//
//  GenreSelectView.swift
//  SongLingo
//
//  Created by Derek Huang on 4/21/26.
//

import SwiftUI

struct GenreSelectView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.984, green: 0.443, blue: 0.522),
                    Color(red: 0.576, green: 0.200, blue: 0.918),
                    Color(red: 0.231, green: 0.027, blue: 0.392)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                VStack(spacing: 6) {
                    Text("♪ SongLingo")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Learn languages through the music you love")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.95))
                }
                VStack(spacing: 20) {
                    VStack(spacing: 6) {
                        Text("What music do you enjoy?")
                            .font(.system(size: 18, weight: .bold))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 260)
                        
                        Text("Pick your favorite genres to get started")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                    HStack(spacing: 16) {
                        Button("Back") {
                            print("Back tapped")
                        }
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(red: 0.486, green: 0.227, blue: 0.929))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        
                        Button("Continue") {
                            print("Continue tapped")
                        }
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(red: 0.486, green: 0.227, blue: 0.929))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding(25)
                .background(Color.white)
                .cornerRadius(25)
                .padding(.horizontal, 30)
                
                Spacer()
            }
        }
    }
}

#Preview {
    GenreSelectView()
}
