import Foundation

/// JSON deserialization error
enum SerializationError: Error {
    case missing(String)
    case invalidRoot(Any)
}

/// A struct representing github pull request
///
/// Note: only fields interesting for this application are represented
struct PullRequestFile {
    
    /// Filename and its path in the repo
    let filename: String
    
    /// Number of changes in the file
    let changes: Int
    
    init(filename: String, changes: Int) {
        self.filename = filename
        self.changes = changes
    }
}

// Deserialization from json
extension PullRequestFile {
    
    private init(json: Any) throws {
        guard let prJson = json as? [String: Any] else {
            throw SerializationError.invalidRoot(json)
        }
        
        guard let filename = prJson["filename"] as? String else {
            throw SerializationError.missing("filename")
        }
        
        guard let changes = prJson["changes"] as? Int else {
            throw SerializationError.missing("changes")
        }
        
        self.filename = filename
        self.changes = changes
    }
    
    static fileprivate func fromJsonArray(json: Any) throws -> [PullRequestFile] {
        guard let prs = json as? [Any] else {
            throw SerializationError.invalidRoot(json)
        }
        let result = try prs.map { pr in
            try PullRequestFile(json: pr)
            
        }
        return result
    }
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
    func listFilesInPr(_ pr: Int) -> [PullRequestFile] {
        
        let url = URL(string: "\(baseUrl())/pulls/\(pr)/files?access_token=\(apiToken)&per_page=300")
        
        var prs: [PullRequestFile] = []
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let task = session.dataTask(with: url!) { responseData, _, _ in
            guard let data = responseData else {
                semaphore.signal()
                return
            }
            
            guard let responseJson = try? JSONSerialization.jsonObject(with: data) else {
                semaphore.signal()
                return
            }
            
            prs = (try? PullRequestFile.fromJsonArray(json: responseJson)) ?? []
            prs.sort(by: self.mostChangesFirst)
            semaphore.signal()
        }
        task.resume()
        
        // TODO: do not wait indefintely
        let _ = semaphore.wait(timeout: .distantFuture)
        
        return prs
    }
    
    private let mostChangesFirst: (PullRequestFile, PullRequestFile) -> Bool = { $0.changes > $1.changes}
}
