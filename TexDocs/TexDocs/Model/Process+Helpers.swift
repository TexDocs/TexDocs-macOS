//
//  Process+Helpers.swift
//  TexDocs
//
//  Created by Noah Peeters on 09.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

extension Process {
    static func create(_ launchPath: String, workingDirectory: URL? = nil, arguments: [String], additionalEnvironmentPaths: [String]? = nil) -> Process {
        let process = Process()
        process.launchPath = launchPath
        process.currentDirectoryURL = workingDirectory ?? URL(fileURLWithPath: "/tmp")
        process.arguments = arguments

        var env = ProcessInfo.processInfo.environment
        if let additionalEnvironmentPaths = additionalEnvironmentPaths {
            env["PATH", default: ""] += ":" + additionalEnvironmentPaths.joined(separator: ":")
        }
        process.environment = env

        return process
    }

    func setOutputHandler(readabilityHandler: @escaping (FileHandle) -> Void) {
        let pipe = Pipe()
        standardOutput = pipe
        let outHandle = pipe.fileHandleForReading

        outHandle.readabilityHandler = readabilityHandler
    }

    func setStringOutputHandler(encoding: String.Encoding = .utf8, readabilityHandler: @escaping (String) -> Void) {
        setOutputHandler { pipe in
            if let string = String(data: pipe.availableData, encoding: encoding) {
                readabilityHandler(string)
            }
        }
    }

    func launchAndGetOutput(encoding: String.Encoding = .utf8) -> String {
        var output = ""

        setStringOutputHandler(encoding: encoding) { string in
            output += string
        }

        launch()
        waitUntilExit()

        return output
    }
}
