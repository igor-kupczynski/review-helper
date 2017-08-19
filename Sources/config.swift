import Foundation

/// review helper configuration
struct Config {
    let apiToken: String
}

// deserialization from json
// TODO: error handling instead of `nil`s
extension Config {
    private init?(json: Any) {
        guard let configJson = json as? [String: Any] else {
            return nil
        }
        
        guard let apiToken = configJson["token"] as? String else {
            return nil
        }
        
        self.apiToken = apiToken
    }
    
    /// Load the config from "~/.review-helper.json"
    static func load() -> Config? {
        
        let home = URL(fileURLWithPath: NSHomeDirectory())
        
        guard let data = try? Data(
            contentsOf: URL(string: ".review-helper.json", relativeTo: home)!) else {
                return nil
        }
        
        guard let configJson = try? JSONSerialization.jsonObject(with: data) else {
            return nil
        }
        
        return Config(json: configJson)
    }
}
