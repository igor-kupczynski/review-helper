import Foundation

var standardError = FileHandle.standardError

extension FileHandle : TextOutputStream {
    public func write(_ string: String) {
        guard let data = string.data(using: .utf8) else { return }
        self.write(data)
    }
}

func review(config: Config, args: [String]) {
    let owner: String = args[0]
    let repo: String = args[1]
    let pr: Int = Int(args[2])!  // TODO: error handling
    
    let repoHandle = GithubRepoHandle(apiToken: config.apiToken, owner: owner, repo: repo)
    let result = repoHandle.listFilesInPr(pr)
    
    result.forEach { print("\($0.filename) -> \($0.changes)") }
}

func main() -> () {
    
    // TODO: help
    // TODO: github login
    
    do {
        let config = try Config.load()
        let args: [String] = CommandLine.arguments

        review(config: config, args: Array(args.dropFirst(1)))
    } catch let configError as ConfigError {
        switch configError {
        case .cantReadConfigFile(let message):
            print("Can't read the config file: \(message).", to:&standardError)
        case .invalidFormat(let expected):
            print("Invalid config file format, expected: \(expected).", to:&standardError)
        case .notAJson(let message):
            print("Config file is not a JSON: \(message).", to:&standardError)
        }
        print("Valid config file at \(Config.configFileLocation) expected, see the README.md for details on its format",
            to:&standardError)
    } catch {
        print("Unexpected error \(error)", to:&standardError)
    }
}


main()
