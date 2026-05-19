import SwiftUI

struct ProficiencyView: View {
    // baton being received from LangSelectionView
    var selectedLanguage: String
    
    @State private var selectedLevel: String? = nil
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.030, green: 0.050, blue: 0.120),
                        Color(red: 0.275, green: 0.095, blue: 0.250),
                        Color(red: 0.110, green: 0.165, blue: 0.325)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                GeometryReader { geometry in
                    ZStack {
                        ForEach(0..<150, id: \.self) { i in
                            Circle()
                                .fill(.white)
                                .frame(width: CGFloat.random(in: 1.5...3), height: CGFloat.random(in: 1.5...3))
                                .opacity(Double.random(in: 0.1...0.9))
                                .position(
                                    x: CGFloat.random(in: 0...geometry.size.width),
                                    y: CGFloat.random(in: 0...geometry.size.height)
                                )
                        }
                        
                        ForEach(0..<10, id: \.self) { i in
                            Image(systemName: i % 2 == 0 ? "sparkles" : "star.fill")
                                .foregroundColor(.gray)
                                .font(.system(size: CGFloat.random(in: 10...15)))
                                .opacity(Double.random(in: 0.5...0.7))
                                .shadow(color: .white.opacity(0.3), radius: 3)
                                .position(
                                    x: CGFloat.random(in: 0...geometry.size.width),
                                    y: CGFloat.random(in: 0...geometry.size.height)
                                )
                        }
                    }
                }
                
                VStack {
                    RadialGradient(
                        colors: [
                            Color.red.opacity(0.25),
                                .clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 200
                    )
                    .frame(width: 400, height: 400)
                    .offset(x: -100, y: 10)
                    
                    Spacer(minLength: 0.2)
                    
                    RadialGradient(
                        colors: [
                            Color.red.opacity(0.25),
                                .clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 200
                    )
                    .frame(width: 400, height: 400)
                    .offset(x: 200, y: -10)
                }
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    VStack(spacing: 6) {
                        Text("♪ SongLingo")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Learn languages through the music you love")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    VStack(spacing: 20) {
                        VStack(spacing: 6) {
                            Text("What's your current level?")
                                .font(.system(size: 18, weight: .bold))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 260)
                            
                            Text("We'll tailor content to your proficiency")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        
                        VStack(spacing: 12) {
                            proficiencyOption(title: "Beginner", subtitle: "Just starting out")
                            proficiencyOption(title: "Intermediate", subtitle: "Basic conversations")
                            proficiencyOption(title: "Advanced", subtitle: "Fluent speaker")
                        }
                        
                        HStack(spacing: 16) {
                            Button("Back") {
                                dismiss()
                            }
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(LinearGradient(
                                colors: [
                                    Color(red: 0.250, green: 0.150, blue: 0.920),
                                    Color(red: 0.655, green: 0.195, blue: 0.950),
                                    Color(red: 0.985, green: 0.165, blue: 0.555)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            
                            // handing the batons to GenreSelectionView
                            NavigationLink(destination: GenreSelectionView(
                                selectedLanguage: selectedLanguage,
                                selectedProficiency: selectedLevel ?? "Beginner"
                            )) {
                                Text("Continue")
                            }
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(LinearGradient(
                                colors: [
                                    Color(red: 0.250, green: 0.150, blue: 0.920),
                                    Color(red: 0.655, green: 0.195, blue: 0.950),
                                    Color(red: 0.985, green: 0.165, blue: 0.555)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .opacity(selectedLevel == nil ? 0.5 : 1.0)
                            .disabled(selectedLevel == nil)
                        }
                    }
                    .padding(25)
                    .background(Color.white.opacity(0.09))
                    .foregroundColor(.white)
                    .cornerRadius(25)
                    .padding(.horizontal, 30)
                    
                    Spacer()
                }
            }
            .navigationBarBackButtonHidden()
        }
    }
    
    @ViewBuilder
    func proficiencyOption(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .fontWeight(.semibold)
                .foregroundColor(selectedLevel == title ? .black : .primary)
            
            Text(subtitle)
                .font(.system(size: 13))
                .foregroundColor(.black.opacity(0.9))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(selectedLevel == title ? Color.blue.opacity(0.12) : Color.white.opacity(0.55))
        .cornerRadius(20)
        .overlay (
            RoundedRectangle(cornerRadius: 20)
                .stroke(selectedLevel == title ? Color.purple : Color.gray.opacity(0.3),
                        lineWidth: selectedLevel == title ? 2 : 1)
        )
        .onTapGesture {
            selectedLevel = title
        }
    }
}

// preview provides a dummy language so it doesn't crash
#Preview {
    ProficiencyView(selectedLanguage: "Spanish")
}
