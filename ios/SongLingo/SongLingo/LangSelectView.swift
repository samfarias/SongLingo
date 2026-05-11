import SwiftUI

struct LangSelectionView: View {
    @State private var selectedLanguage: Int? = nil
    
    @Environment(\.dismiss) var dismiss

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    let languages = [
        (name: "Spanish", image: "Spain"),
        (name: "Greek", image: "Greece"),
        (name: "Japanese", image: "Japan"),
        (name: "French", image: "France")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.984, green: 0.443, blue: 0.522),
                        Color(red: 0.576, green: 0.200, blue: 0.918),
                        Color(red: 0.231, green: 0.027, blue: 0.392)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 22) {
                    Spacer()

                    VStack(spacing: 6) {
                        Text("♪ SongLingo")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)

                        Text("Learn languages through the music you love")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.95))
                    }

                    VStack(spacing: 18) {
                        VStack(spacing: 6) {
                            Text("Which language do you want to learn?")
                                .font(.system(size: 18, weight: .bold))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 260)

                            Text("Choose your target language")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }

                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(0..<languages.count, id: \.self) { index in
                                Button {
                                    selectedLanguage = index
                                } label: {
                                    VStack(spacing: 8) {
                                        Image(languages[index].image)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 58, height: 40)

                                        Text(languages[index].name)
                                            .font(.system(size: 13))
                                            .foregroundColor(.black)
                                    }
                                    .frame(width: 130, height: 92)
                                    .background(selectedLanguage == index ? Color.blue.opacity(0.12) : Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(
                                                selectedLanguage == index
                                                ? Color(red: 0.486, green: 0.227, blue: 0.929)
                                                : Color.gray.opacity(0.35),
                                                lineWidth: selectedLanguage == index ? 2 : 1
                                            )
                                    )
                                    .cornerRadius(14)
                                }
                            }
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
                            
                            // NOTE: Still a NavigationLink! We will change this to a Button + Task when we build the PUT request next.
                            NavigationLink(destination: ProficiencyView(selectedLanguage: languages[selectedLanguage ?? 0].name)) {
                                Text("Continue")
                            }                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(red: 0.486, green: 0.227, blue: 0.929))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .opacity(selectedLanguage == nil ? 0.5 : 1.0)
                            .disabled(selectedLanguage == nil)
                        }
                    }
                    .padding(.vertical, 26)
                    .padding(.horizontal, 22)
                    .background(Color.white.opacity(0.95))
                    .foregroundColor(.black) // <-- THE FIX
                    .cornerRadius(28)
                    .padding(.horizontal, 34)

                    Spacer()
                }
                .padding(.vertical, 30)
            }
        }
    }
}

#Preview {
    LangSelectionView()
}
