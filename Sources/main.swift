import Commander

class GithubReviewHelper {
    func review(org: String, repo: String, pr: Int) -> String {
        return "FFF \(org)/\(repo)/\(pr)"
    }
}

let main = command(
    Argument<String>("org", description: "Github organization or username"),
    Argument<String>("repo", description: "Repository name"),
    Argument<Int>("pr", description: "PR id")
) { (org: String, repo: String, pr: Int) in
    
    let result = GithubReviewHelper().review(org: org, repo: repo, pr: pr)
    print(result)
    
}

main.run()
