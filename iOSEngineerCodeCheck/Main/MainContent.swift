import Foundation

struct MainContent {
    let cellContents: [MainCellContent]
    let message: MainMessage
}

enum MainMessage {
    case waiting
    case loading
    case loaded
    case failed
    case cancelled
}

struct MainCellContent {
    let fullName: String?
    let language: String?
}
