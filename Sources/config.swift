import Foundation

enum ConfigError : Error {
    case cantReadConfigFile(where: String)
}

struct Config : Codable {
    let apiToken: String

    enum CodingKeys: String, CodingKey {
        case apiToken = "token"
    }
}


// Json deserialization
extension Config {

    static let configFileName = ".review-helper.json"
    static let configFile = URL(string: ".review-helper.json", relativeTo: URL(fileURLWithPath: NSHomeDirectory()))!
    
    /// Load the config from "~/.review-helper.json"
    static func load() throws -> Config {
        guard let data = try? Data(contentsOf: configFile) else {
            throw ConfigError.cantReadConfigFile(where: configFile.absoluteString)
        }

        let config = try JSONDecoder().decode(Config.self, from: data)
        return config
    }
}
