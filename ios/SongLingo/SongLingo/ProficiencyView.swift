//
//  ProficiencyView.swift
//  SongLingo
//
//  Created by Derek Huang on 4/11/26.
//

import SwiftUI

struct ProficiencyView: View {
    // 1. Added selection state
    @State private var selectedLevel: String? = nil
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
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
                        
                        VStack(spacing: 12) {
                            // BEGINNER OPTION
                            proficiencyOption(title: "Beginner", subtitle: "Just starting out")
                            
                            // INTERMEDIATE OPTION
                            proficiencyOption(title: "Intermediate", subtitle: "Basic conversations")
                            
                            // ADVANCED OPTION
                            proficiencyOption(title: "Advanced", subtitle: "Fluent speaker")
                        }
                        
                        HStack(spacing: 16) {
                            Button("Back") {
                                dismiss()
                            }
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(red: 0.486, green: 0.227, blue: 0.929))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            
                            NavigationLink(destination: GenreSelectView()){
                                Text("Continue")
                            }
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(red: 0.486, green: 0.227, blue: 0.929))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            // Optional: Disable continue if nothing is selected
                            .opacity(selectedLevel == nil ? 0.5 : 1.0)
                            .disabled(selectedLevel == nil)
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
    
    // Helper function to create the selectable rows
    @ViewBuilder
    func proficiencyOption(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .fontWeight(.semibold)
                .foregroundColor(selectedLevel == title ? .black : .primary)
            
            Text(subtitle)
                .font(.system(size: 13))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        // 2. Dynamic background color
        .background(selectedLevel == title ? Color.blue.opacity(0.12) : Color.white)
        .cornerRadius(20)
        .overlay (
            RoundedRectangle(cornerRadius: 20)
                // 3. Dynamic stroke color and width
                .stroke(selectedLevel == title ? Color.purple : Color.gray.opacity(0.3),
                        lineWidth: selectedLevel == title ? 2 : 1)
        )
        // 4. Make it tappable
        .onTapGesture {
            selectedLevel = title
        }
    }
}

#Preview {
    ProficiencyView()
}
