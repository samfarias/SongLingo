import Foundation
import AuthenticationServices

class SpotifyAuthManager: NSObject, ASWebAuthenticationPresentationContextProviding {
    static let shared = SpotifyAuthManager()

    private var session: ASWebAuthenticationSession?

    private override init() { super.init() }

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return windowScene?.windows.first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }

    @MainActor
    func connect() async throws {
        let authUrl = try await NetworkManager.shared.fetchSpotifyAuthURL()

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            let session = ASWebAuthenticationSession(url: authUrl, callbackURLScheme: "songlingo") { callbackURL, error in
                if let error = error {
                    if (error as NSError).code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(throwing: error)
                    }
                    return
                }

                guard let callbackURL = callbackURL,
                      let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: true),
                      let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
                    continuation.resume(throwing: URLError(.badURL))
                    return
                }

                Task {
                    do {
                        try await NetworkManager.shared.sendSpotifyCode(code)
                        UserDefaults.standard.set(true, forKey: "spotifyLinked")
                        continuation.resume()
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }

            session.presentationContextProvider = self
            self.session = session
            session.start()
        }
    }
}
