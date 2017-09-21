import Foundation

enum ConfigError : Error {
    case cantReadConfigFile(where: String)
    case notAJson(message: String)
    case invalidFormat(expected: String)
}

struct Config {
    let apiToken: String
}


// Json deserialization
extension Config {

    static let configFileLocation = "~/.review-helper.json"

    private init(json: Any?) throws {
        guard let configJson = json as? [String: Any] else {
            throw ConfigError.invalidFormat(expected: "top level object")
        }
        
        guard let apiToken = configJson["token"] as? String else {
            throw ConfigError.invalidFormat(expected: "token property representing Github API token")
        }
        
        self.apiToken = apiToken
    }
    
    /// Load the config from "~/.review-helper.json"
    static func load() throws -> Config {
        let home = URL(fileURLWithPath: NSHomeDirectory())
        let configFile = URL(string: ".review-helper.json", relativeTo: home)!

        guard let data = try? Data(contentsOf: configFile) else {
            throw ConfigError.cantReadConfigFile(where: configFileLocation)
        }

        var configJson: Any?
        do {
            configJson = try JSONSerialization.jsonObject(with: data)
        } catch let error as NSError {
            throw ConfigError.notAJson(message: error.localizedDescription)
        }
        return try Config(json: configJson)
    }
}
