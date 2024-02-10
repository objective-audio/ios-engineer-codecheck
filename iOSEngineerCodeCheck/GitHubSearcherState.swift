import Foundation

enum GitHubSearcherState {
    case initial
    case loading(Task<Void, Never>, [GitHubRepository])
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

    var task: Task<Void, Never>? {
        switch self {
        case .loading(let task, _):
            task
        case .initial, .loaded, .failed:
            nil
        }
    }
}
