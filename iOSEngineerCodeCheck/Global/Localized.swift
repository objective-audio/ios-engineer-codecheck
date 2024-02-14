import Foundation

enum Localized {
    enum Main {
        enum Title {
            static var waiting: String {
                .init(localized: "main.title.waiting", defaultValue: "Search GitHub Repository")
            }
            static var loading: String {
                .init(localized: "main.title.loading", defaultValue: "Searching...")
            }
            static var loaded: String {
                .init(localized: "main.title.loaded", defaultValue: "Searched")
            }
            static var failed: String {
                .init(localized: "main.title.failed", defaultValue: "Search failed")
            }
            static var cancelled: String {
                .init(localized: "main.title.cancelled", defaultValue: "Search cancelled")
            }
        }
        static var searchPlaceholder: String {
            .init(localized: "main.searchPlaceholder", defaultValue: "Input keyword")
        }
    }
    enum Detail {
        static func language(_ language: String) -> String {
            .init(localized: "detail.language", defaultValue: "Written in \(language)")
        }
        static func starsCount(_ count: Int) -> String {
            .init(localized: "detail.starsCount", defaultValue: "\(count) stars")
        }
        static func watchersCount(_ count: Int) -> String {
            .init(localized: "detail.watchersCount", defaultValue: "\(count) watchers")
        }
        static func forksCount(_ count: Int) -> String {
            .init(localized: "detail.forksCount", defaultValue: "\(count) forks")
        }
        static func openIssuesCount(_ count: Int) -> String {
            .init(localized: "detail.openIssuesCount", defaultValue: "\(count) open issues")
        }
    }
}
