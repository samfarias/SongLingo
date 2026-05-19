import SwiftUI

struct CreateAccView: View {
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @State private var navigateToOnboarding = false
    
    // MARK: - Computed Validation Properties
    // These calculate in real-time instantly, no .onChange needed!
    
    private var isUsernameValid: Bool {
        !username.isEmpty && username.count >= 3
    }
    
    private var isEmailValid: Bool {
        let emailConditions = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", emailConditions).evaluate(with: email) && !email.isEmpty
    }
    
    private var isPasswordValid: Bool {
        let passwordConditions = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[#$@!%&*?])[A-Za-z\\d#$@!%&*?]{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordConditions).evaluate(with: password) && !password.isEmpty
    }
    
    private var isConfirmPasswordValid: Bool {
        password == confirmPassword && !confirmPassword.isEmpty
    }
    
    private var isFormValid: Bool {
        isUsernameValid && isEmailValid && isPasswordValid && isConfirmPasswordValid
    }
    
    // MARK: - View Body
    
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

                VStack(spacing: 16) {
                    VStack(spacing: 6) {
                        Text("♪ SongLingo")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text("Learn languages through the music you love")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.top, 40)

                    VStack(spacing: 18) {
                        VStack(spacing: 6) {
                            Text("Create Account")
                                .font(.title2)
                                .fontWeight(.bold)

                            Text("Join SongLingo and start learning today")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                                .padding(.top, 10)
                        }

                        VStack {
                            VStack(alignment: .leading, spacing: 14) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Username")
                                        .fontWeight(.semibold)
                                    
                                    TextField("", text: $username)
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 12)
                                        .background(Color.white.opacity(0.55))
                                        .foregroundColor(.black)
                                        .cornerRadius(10)
                                        .autocapitalization(.none) // Helpful for usernames
                                    
                                    if !isUsernameValid && !username.isEmpty {
                                        Text("Username must be at least 3 characters")
                                            .foregroundColor(.red)
                                            .font(.caption)
                                    }
                                }
                               
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Email")
                                        .fontWeight(.semibold)
                                    
                                    TextField("", text: $email)
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 12)
                                        .background(Color.white.opacity(0.55))
                                        .foregroundColor(.black)
                                        .cornerRadius(10)
                                        .keyboardType(.emailAddress) // Helps mobile users
                                        .autocapitalization(.none)
                                    
                                    if !isEmailValid && !email.isEmpty {
                                        Text("Enter a valid email")
                                            .foregroundColor(.red)
                                            .font(.caption)
                                    }
                                }
                               
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Password")
                                        .fontWeight(.semibold)
                                    
                                    SecureField("", text: $password)
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 12)
                                        .background(Color.white.opacity(0.55))
                                        .foregroundColor(.black)
                                        .cornerRadius(10)
                                    
                                    if !isPasswordValid && !password.isEmpty {
                                        Text("Need 8+ chars, Uppercase, Number, & Symbol")
                                            .foregroundColor(.red)
                                            .font(.caption)
                                    }
                                }
                               
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Confirm Password")
                                        .fontWeight(.semibold)
                                    
                                    SecureField("", text: $confirmPassword)
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 12)
                                        .background(Color.white.opacity(0.55))
                                        .foregroundColor(.black)
                                        .cornerRadius(10)
                                    
                                    if !isConfirmPasswordValid && !confirmPassword.isEmpty {
                                        Text("Passwords do not match")
                                            .foregroundColor(.red)
                                            .font(.caption)
                                    }
                                }
                            }
                        }

                        Button {
                            Task {
                                do {
                                    let _ = try await NetworkManager.shared.register(username: username, password: password)
                                    UserDefaults.standard.set(true, forKey: "is_new_user")
                                    navigateToOnboarding = true
                                } catch {
                                    print("Registration failed: \(error)")
                                }
                            }
                        } label: {
                            Text("Create Account")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
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
                        }
                        .padding(.top, 10)
                        .opacity(isFormValid ? 1.0 : 0.5)
                        .disabled(!isFormValid)

                        VStack(spacing: 8) {
                            Text("Already have an account?")
                                .foregroundColor(.white.opacity(0.75))
                                .padding(5)

                            NavigationLink(destination: Login()) {
                                Text("Sign In")
                            }
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
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
                            .padding(.top, 10)
                            .padding(.bottom, 20)
                        }
                    }
                    .padding(20)
                    .background(.white.opacity(0.09))
                    .foregroundColor(.white)
                    .cornerRadius(25)
                    .padding(.horizontal, 40)

                    Spacer()
                }
            }
            .navigationBarBackButtonHidden()
            .navigationDestination(isPresented: $navigateToOnboarding) {
                LangSelectionView()
            }
        }
    }
}

#Preview {
    CreateAccView()
}
