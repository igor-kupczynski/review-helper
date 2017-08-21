// TODO: Fallback nicely
let config = Config.load()!

func review(args: [String]) {
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
    
    let args: [String] = CommandLine.arguments
    
    review(args: Array(args.dropFirst(1)))
}


main()
