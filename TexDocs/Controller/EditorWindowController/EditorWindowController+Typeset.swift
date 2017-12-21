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
//        guard let mainTexFilePath = selectedScheme.path else {
//            return
//        }

        let mainTexFilePath = ""

        autoTypesetTimer?.invalidate()
        autoTypesetTimer = nil

        guard currentTypesetProcess == nil else {
            return
        }

        consoleViewController.clearConsole()

        let inputFile = workspaceURL.appendingPathComponent(mainTexFilePath, isDirectory: false)
        let inputFileNameWithoutExtension = inputFile.deletingPathExtension().lastPathComponent
        let outputDirectory = workspaceURL.appendingPathComponent("out", isDirectory: false)
        let outputFile = outputDirectory
            .appendingPathComponent(inputFileNameWithoutExtension)
            .appendingPathExtension("pdf")

        do {
            try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            showErrorSheet(error)
            return
        }

        guard let process = Process.create(UserDefaults.latexPath.value, workingDirectory: dataFolderURL, arguments: [
                "-output-directory=../\(relativePathInWorkspace(of: outputDirectory)!)",
                relativePathInWorkspace(of: inputFile)!
            ]) else {
                showUserNotificationSheet(text: NSLocalizedString("TD_ERROR_INVALID_LATEX_PATH", comment: "Shown to the user of the latex path is not executable"))
                return
        }
        currentTypesetProcess = process

        process.setStringOutputHandler { [weak self, weak process] string in
            if string.hasSuffix("? ") || string.hasSuffix("Enter file name: ") {
                process?.terminate()
            }

            DispatchQueue.main.sync { [weak self] in
                self?.consoleViewController.addString(string)
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
