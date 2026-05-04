/*
import Foundation

class NetworkManager {
    // allows you to call NetworkManager.shared from anywhere in the app
    static let shared = NetworkManager()
    
    private init() {} // keeps things secure by preventing duplicate managers
    
    func testBackendConnection() {
        // points straight to our live DigitalOcean Droplet
        guard let url = URL(string: "http://68.183.31.175:8000/api/home/?user_id=1") else { 
            print("Invalid URL")
            return 
        }
        
        // fire off the request in the background
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Network Error: \(error.localizedDescription)")
                return
            }
            
            if let data = data {
                print("\n=== DJANGO Server says: ===")
                print(String(data: data, encoding: .utf8) ?? "no readable data")
                print("========================\n")
            }
        }.resume()
    }
}
*/