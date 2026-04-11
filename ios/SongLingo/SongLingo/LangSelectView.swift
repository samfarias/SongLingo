import SwiftUI

struct LanguageSelectionView: View {
    @State private var selectedLanguage: Int? = nil

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
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

            VStack {
                Spacer()

                VStack(spacing: 20) {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(0..<4, id: \.self) { index in
                            Button {
                                selectedLanguage = index
                            } label: {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(selectedLanguage == index
                                          ? Color(red: 0.486, green: 0.227, blue: 0.929).opacity(0.15)
                                          : Color.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 90)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(
                                                selectedLanguage == index
                                                ? Color(red: 0.486, green: 0.227, blue: 0.929)
                                                : Color.gray.opacity(0.3),
                                                lineWidth: selectedLanguage == index ? 2 : 1
                                            )
                                    )
                            }
                        }
                    }

                    Button("Continue") {
                        print("Continue tapped")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(red: 0.486, green: 0.227, blue: 0.929))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(25)
                .padding(.horizontal, 40)

                Spacer()
            }
        }
    }
}

#Preview {
    LanguageSelectionView()
}
