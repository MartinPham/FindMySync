//
//  DataAccess.swift
//  FindMySync
//

import Foundation

/// Remembers the FindMy folder the user picked, so it stays readable on later
/// launches.
///
/// Picking the folder only grants access while its security scope is held open.
/// Without a stored bookmark the grant is lost as soon as the sync that follows
/// the picker finishes, and every sync after that fails - which leaves Full Disk
/// Access as the only thing that works. Keeping the bookmark, and reopening the
/// scope at launch, is what lets FindMySync run with access to nothing but the
/// FindMy folder.
enum DataAccess {

    private static let bookmarkKey = "bookmarkData"

    /// Held for the lifetime of the process. Releasing it revokes access, so it
    /// is deliberately never balanced with a stop until the folder changes.
    private static var scopedURL: URL?

    /// Stores a folder the user picked and opens its scope.
    static func grant(_ url: URL) throws {
        let bookmark = try url.bookmarkData(
            options: .withSecurityScope,
            includingResourceValuesForKeys: nil,
            relativeTo: nil)

        UserDefaults.standard.set(bookmark, forKey: bookmarkKey)
        open(url)
    }

    /// Reopens the scope of a previously picked folder.
    ///
    /// Returns false when nothing was stored, or when the bookmark no longer
    /// resolves - the folder having moved, or the grant having been revoked.
    @discardableResult
    static func restore() -> Bool {
        guard let bookmark = UserDefaults.standard.data(forKey: bookmarkKey) else {
            return false
        }

        var isStale = false
        guard
            let url = try? URL(
                resolvingBookmarkData: bookmark,
                options: [.withSecurityScope],
                relativeTo: nil,
                bookmarkDataIsStale: &isStale)
        else {
            UserDefaults.standard.removeObject(forKey: bookmarkKey)
            return false
        }

        open(url)

        // A stale bookmark still resolves, but only once more - rewrite it while
        // we hold the scope.
        if isStale {
            try? grant(url)
        }

        return true
    }

    private static func open(_ url: URL) {
        if let current = scopedURL {
            if current == url {
                return
            }
            current.stopAccessingSecurityScopedResource()
        }

        _ = url.startAccessingSecurityScopedResource()
        scopedURL = url
    }
}
