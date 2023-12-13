// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import MozillaAppServices

public protocol RustFirefoxSuggestActor: Actor {
    /// Downloads and stores new Firefox Suggest suggestions.
    func ingest() async throws

    /// Searches the store for matching suggestions.
    func query(
        _ keyword: String,
        includeSponsored: Bool,
        includeNonSponsored: Bool
    ) async throws -> [RustFirefoxSuggestion]

    /// Interrupts any ongoing queries for suggestions.
    nonisolated func interruptReader()
}

/// An actor that wraps the synchronous Rust `SuggestStore` binding to execute
/// blocking operations on the default global concurrent executor.
public actor RustFirefoxSuggest: RustFirefoxSuggestActor {
    private let store: SuggestStore

    public init(databasePath: String, remoteSettingsConfig: RemoteSettingsConfig? = nil) throws {
        store = try SuggestStore(path: databasePath, settingsConfig: remoteSettingsConfig)
    }

    public func ingest() async throws {
        // Ensure that the Rust networking stack has been initialized before
        // downloading new suggestions. This is safe to call multiple times.
        Viaduct.shared.useReqwestBackend()

        try store.ingest(constraints: SuggestIngestionConstraints())
    }

    public func query(
        _ keyword: String,
        includeSponsored: Bool,
        includeNonSponsored: Bool
    ) async throws -> [RustFirefoxSuggestion] {
        var providers = [SuggestionProvider]()
        if includeSponsored {
            providers.append(.amp)
        }
        if includeNonSponsored {
            providers.append(.wikipedia)
        }
        return try store.query(query: SuggestionQuery(
            keyword: keyword,
            providers: providers
        )).compactMap(RustFirefoxSuggestion.init)
    }

    public nonisolated func interruptReader() {
        store.interrupt()
    }
}
