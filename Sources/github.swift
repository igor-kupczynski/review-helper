import Foundation

/// A struct representing github pull request
///
/// Note: only fields interesting for this application are represented
struct PullRequestFile : Decodable {
    
    /// Filename and its path in the repo
    let filename: String
    
    /// Number of changes in the file
    let changes: Int
    
    init(filename: String, changes: Int) {
        self.filename = filename
        self.changes = changes
    }
}

/// Error response from the Github API
enum ApiError : Error {
    case cantFetch(url: URL)
}


/// A facade to interact with github repository
class GithubRepoHandle {
    
    private let session: URLSession = URLSession.shared

    let apiToken: String
    let owner: String
    let repo: String
    
    private func baseUrl() -> String {
        return "https://api.github.com/repos/\(owner)/\(repo)"
    }
    
    init(apiToken: String, owner: String, repo: String) {
        self.apiToken = apiToken
        self.owner = owner
        self.repo = repo
    }
    
    /// List files in a Pull Request ordering by the most number of changes first
    func listFilesInPr(_ pr: Int) throws -> [PullRequestFile] {
        
        let url = URL(string: "\(baseUrl())/pulls/\(pr)/files?access_token=\(apiToken)&per_page=300")!

        let response = try fetch(url: url)

        var prs: [PullRequestFile] = []
        prs = try JSONDecoder().decode([PullRequestFile].self, from: response)
        prs.sort(by: self.mostChangesFirst)

        return prs
    }

    private func fetch(url: URL) throws -> Data {
        var response: Data? = nil

        let semaphore = DispatchSemaphore(value: 0)

        let task = session.dataTask(with: url) { responseData, _, _ in
            guard let data = responseData else {
                semaphore.signal()
                return
            }
            response = data
            semaphore.signal()
        }
        task.resume()

        // TODO: do not wait indefintely
        let _ = semaphore.wait(timeout: .distantFuture)

        guard let r = response else {
            throw ApiError.cantFetch(url: url)
        }

        return r
    }
    
    private let mostChangesFirst: (PullRequestFile, PullRequestFile) -> Bool = { $0.changes > $1.changes}
}
