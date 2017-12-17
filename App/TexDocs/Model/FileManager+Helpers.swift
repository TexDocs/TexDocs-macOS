//
//  FileManager+Helpers.swift
//  TexDocs
//
//  Created by Noah Peeters on 06.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

extension FileManager {
    func renameItem(at url: URL, to newName: String) throws {
        try moveItem(at: url, to: url.deletingLastPathComponent().appendingPathComponent(newName))
    }

    func applicationSupportDirectoryContent(withPath path: String) -> [URL] {
        return [
            subDirectorys(of: applicationSupportBundleURLs(in: .userDomainMask), withPath: path, generateMissingDirectories: true),
            subDirectorys(of: applicationSupportBundleURLs(in: .systemDomainMask), withPath: path),
            subDirectorys(of: [Bundle.main.bundleURL.appendingPathComponent("Contents/Resources/Application Support", isDirectory: true)], withPath: path)
        ].flatMap { $0 }
            .map { try? contentsOfDirectory(at: $0, includingPropertiesForKeys: [], options: []) }
            .flatMap { $0 }
            .flatMap { $0 }
    }

    func applicationSupportDirectoryFileContent(withPath path: String) -> [(url: URL, content: String)] {
        return applicationSupportDirectoryContent(withPath: path).flatMap { url in
            guard let content = try? String(contentsOf: url) else {
                return nil
            }
            return (url, content)
        }
    }

    private func subDirectorys(of urls: [URL], withPath path: String, generateMissingDirectories: Bool = false) -> [URL] {
        let directories = urls.map { $0.appendingPathComponent(path, isDirectory: true) }

        if generateMissingDirectories {
            directories.forEach {
                try? createDirectory(at: $0, withIntermediateDirectories: true, attributes: nil)
            }
        }
        return directories
    }

    private func applicationSupportBundleURLs(in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
        return urls(for: .applicationSupportDirectory, in: .userDomainMask).map { $0.appendingPathComponent(Bundle.main.bundleIdentifier!, isDirectory: true) }
    }
}
