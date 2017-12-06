//
//  EditorWindowController+Typeset.swift
//  TexDocs
//
//  Created by Noah Peeters on 04.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

extension EditorWindowController {
    var autoTypesetEnabled: Bool {
        return autoTypesetToggle.state == .on
    }

    func resetAutoTypesetTimer(withTimeInterval timeInterval: TimeInterval = 3) {
        guard autoTypesetEnabled else { return }

        autoTypesetTimer?.invalidate()
        autoTypesetTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
            guard self?.autoTypesetEnabled == true else { return }
            self?.typeset()
        }
    }

    func typeset() {
        guard let scheme = selectedScheme else {
            return
        }

        autoTypesetTimer?.invalidate()
        autoTypesetTimer = nil

        guard currentTypesetProcess == nil else {
            return
        }

        let process = Process()
        currentTypesetProcess = process
        consoleViewController.clearConsole()

        let inputFile = workspaceURL.appendingPathComponent(scheme.path, isDirectory: false)
        let inputFileNameWithoutExtension = inputFile.deletingPathExtension().lastPathComponent
        let outputDirectory = workspaceURL.appendingPathComponent("out", isDirectory: false)
        let outputFile = outputDirectory
            .appendingPathComponent(inputFileNameWithoutExtension)
            .appendingPathExtension("pdf")

        do {
            try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            showErrorSheet(error)
            currentTypesetProcess = nil
            return
        }

        process.currentDirectoryPath = workspaceURL.path
        process.launchPath = "/Library/TeX/texbin/pdflatex"
        process.arguments = [
            "-output-directory=\(outputDirectory.path(relativeTo: workspaceURL)!)",
            inputFile.path(relativeTo: workspaceURL)!
        ]

        // handle outputs
        let pipe = Pipe()
        process.standardOutput = pipe
        let outHandle = pipe.fileHandleForReading

        outHandle.readabilityHandler = { [weak self, weak process] pipe in
            if let line = String(data: pipe.availableData, encoding: .utf8) {
                if line.hasSuffix("? ") {
                    process?.terminate()
                }

                DispatchQueue.main.sync { [weak self] in
                    self?.consoleViewController.addString(line)
                }
            }
        }

        saveAllDocuments()

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            //launch and wait
            process.launch()
            process.waitUntilExit()
            DispatchQueue.main.sync { [weak self] in
                self?.currentTypesetProcess = nil
                if process.terminationStatus == 0 {
                    self?.pdfViewController.showPDF(withURL: outputFile)
                }
            }
        }
    }
}
