//
//  ProficiencyView.swift
//  SongLingo
//
//  Created by Derek Huang on 4/11/26.
//

import SwiftUI

struct ProficiencyView: View {
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
                        Text("What's your current level?")
                            .font(.system(size: 18, weight: .bold))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 260)
                        
                        Text("We'll tailor content to your proficiency")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                    VStack(spacing: 20) {
                        VStack(spacing: 6) {
                            Text("Beginner")
                            
                            Text("Just starting out")
                        }
                    }
                    VStack(spacing: 20) {
                        VStack(spacing: 6) {
                            Text("Intermediate")
                            
                            Text("Basic conversations")
                        }
                    }
                    VStack(spacing: 20) {
                        VStack(spacing: 6) {
                            Text("Advanced")
                            
                            Text("Fluent speaker")
                        }
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
    ProficiencyView()
}
