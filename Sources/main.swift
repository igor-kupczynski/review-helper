import Commander


// TODO: Fallback nicely
let config = Config.load()!

let main = command(
    Argument<String>("owner", description: "Github repository owner"),
    Argument<String>("repo", description: "Repository name"),
    Argument<Int>("pr", description: "PR id")
) { (owner: String, repo: String, pr: Int) in
    let repo = GithubRepoHandle(apiToken: config.apiToken, owner: owner, repo: repo)
    let result = repo.listFilesInPr(pr)
    
    result.forEach { print("\($0.filename) -> \($0.changes)") }
}

main.run()
