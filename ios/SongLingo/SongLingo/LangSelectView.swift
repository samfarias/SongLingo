import SwiftUI

struct LangSelectionView: View {
    @State private var selectedLanguage: Int? = nil

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

                VStack(spacing: 22) {
                    Spacer()

                    VStack(spacing: 6) {
                        Text("♪ SongLingo")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)

                        Text("Learn languages through the music you love")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.9))
                    }

                    VStack(spacing: 18) {
                        VStack(spacing: 6) {
                            Text("Which language do you want to learn?")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 260)

                            Text("Choose your target language")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.9))
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
                                    .background(selectedLanguage == index ? Color.blue.opacity(0.2) : Color.white.opacity(0.55))
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
                            NavigationLink(destination: CreateAccView()) {
                                Text("Back")
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
                            
                            NavigationLink(destination: ProficiencyView(selectedLanguage: languages[selectedLanguage ?? 0].name)) {
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
                            .opacity(selectedLanguage == nil ? 0.5 : 1.0)
                            .disabled(selectedLanguage == nil)
                        }
                    }
                    .padding(.vertical, 26)
                    .padding(.horizontal, 22)
                    .background(Color.white.opacity(0.09))
                    .foregroundColor(.black)
                    .cornerRadius(28)
                    .padding(.horizontal, 34)

                    Spacer()
                }
                .padding(.vertical, 30)
            }
            .navigationBarBackButtonHidden()
        }
    }
}

#Preview {
    LangSelectionView()
}
