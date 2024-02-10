import Foundation

enum GitHubSearcherState {
    case initial
    case loading(Task<Void, Error>, [GitHubRepository])
    case loaded([GitHubRepository])
    case failed(Error, [GitHubRepository])
}

extension GitHubSearcherState {
    var repositories: [GitHubRepository] {
        switch self {
        case .initial:
            []
        case .loading(_, let repositories), .loaded(let repositories), .failed(_, let repositories):
            repositories
        }
    }

    var task: Task<Void, Error>? {
        switch self {
        case .loading(let task, _):
            task
        case .initial, .loaded, .failed:
            nil
        }
    }
}
