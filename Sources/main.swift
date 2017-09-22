import Foundation

var standardError = FileHandle.standardError

extension FileHandle : TextOutputStream {
    public func write(_ string: String) {
        guard let data = string.data(using: .utf8) else { return }
        self.write(data)
    }
}

func review(config: Config, args: [String]) throws {
    let owner: String = args[0]
    let repo: String = args[1]
    let pr: Int = Int(args[2])!  // TODO: error handling
    
    let repoHandle = GithubRepoHandle(apiToken: config.apiToken, owner: owner, repo: repo)
    let result = try repoHandle.listFilesInPr(pr)
    
    result.forEach { print("\($0.filename) -> \($0.changes)") }
}

func main() -> () {
    
    // TODO: help
    // TODO: github login
    
    do {
        let config = try Config.load()
        let args: [String] = CommandLine.arguments

        try review(config: config, args: Array(args.dropFirst(1)))
    } catch let configError as ConfigError {
        switch configError {
        case .cantReadConfigFile(let message):
            print("Can't read the config file: \(message).", to:&standardError)
        }
    } catch let apiError as ApiError {
        switch apiError {
        case .cantFetch(let url):
            print("Can't fetch the url: \(url).", to:&standardError)
        }
    } catch {
        print("Unexpected error \(error)", to:&standardError)
    }
}


main()
