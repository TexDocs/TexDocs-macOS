//
//  LaTeXLanguageDelegate.swift
//  TexDocs
//
//  Created by Noah Peeters on 07.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

class LaTeXLanguageDelegate: LanguageDelegate {
    private var cachedPackages: [String: [LanguageCompletion]] = [:]

    func prepareForTextStorage(_ textStorage: NSTextStorage) {
        DispatchQueue.main.async { [weak self] in
            self?.scanPackages(in: textStorage.string)
        }
    }

    func textStorageDocumentStructure(_ textStorage: NSTextStorage) -> DocumentStructureNode {
        return documentStructure(of: textStorage)
    }

    func textStorageRulerAnnotations(_ textStorage: NSTextStorage) -> [RulerAnnotation] {
        let string = textStorage.string
        let range = NSRange(string.startIndex..<string.endIndex, in: string)

        return LaTeXLanguageDelegate.includeRegex.matches(in: string, options: [], range: range).map {
            let match = $0.regularExpressionMatch(in: string)
            return RulerAnnotation(lineNumber: match.captureGroups[0].range.location, type: .file(relativePath: match.captureGroups[1].string))
        }
    }

    func sourceCodeView(_ sourceCodeView: SourceCodeView, updateCodeHighlightingInRange editedRange: NSRange) {
        let range = sourceCodeView.nsString.lineRange(for: editedRange)

        sourceCodeView.textStorage?.addAttribute(NSAttributedStringKey.foregroundColor, value: ThemesHandler.default.color(for: .text), range: range)
        
        for rule in LaTeXLanguageDelegate.highlightingRules {
            rule.applyRule(to: sourceCodeView, range: range)
        }
    }

    func sourceCodeView(_ sourceCodeView: SourceCodeView, completionsForLocation location: Int, completionBlock: @escaping (LanguageCompletions?) -> Void) {
        let latexSource = sourceCodeView.string
        let nslatexSource = NSString(string: latexSource)

        guard let inspectionResult = self.inspectCompletionLocation(location, inString: nslatexSource) else {
            completionBlock(nil)
            return
        }

        let commandString = nslatexSource.substring(with: inspectionResult.commandRangeWithoutBackslash)

        if let argumentRange = inspectionResult.argumentRange {
            let argumentString = nslatexSource.substring(with: argumentRange)

            guard let completions = LaTeXLanguageDelegate.knownArguments[commandString] else {
                completionBlock(nil)
                return
            }

            completionBlock(LanguageCompletions(words: completions, range: argumentRange, filteredAndSortedBy: argumentString))
            return
        }

        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.scanPackages(in: latexSource)

            guard var commands = self?.cachedPackages.flatMap({ $0.value }) else {
                completionBlock(nil)
                return
            }

            commands.append(contentsOf: LaTeXLanguageDelegate.knownCommands)
            commands.append(contentsOf: LaTeXLanguageDelegate.templates)

            DispatchQueue.main.async {
                completionBlock(LanguageCompletions(
                    words: commands,
                    range: inspectionResult.commandRange,
                    filteredAndSortedBy: commandString))
            }
        }
    }

    private func inspectCompletionLocation(_ location: Int, inString string: NSString) -> InspectionResult? {
        var scannerHead = location
        var scannerTail = location
        var result = InspectionResult(commandRange: NSRange(), argumentRange: nil)

        while true {
            scannerHead -= 1

            guard scannerHead >= 0 else {
                return nil
            }

            let char = Character(UnicodeScalar(string.character(at: scannerHead))!)
            if [" ", "\n"].index(of: char) != nil {
                return nil
            }

            if char == "\\" {
                result.commandRange = NSRange(location: scannerHead, length: scannerTail - scannerHead)
                return result
            } else if char == "{" {
                result.argumentRange = NSRange(location: scannerHead + 1, length: scannerTail - scannerHead - 1)
                scannerTail = scannerHead
            }
        }
    }

    private struct InspectionResult {
        var commandRange: NSRange

        var commandRangeWithoutBackslash: NSRange {
            return NSRange(location: commandRange.location + 1, length: commandRange.length - 1)
        }

        var argumentRange: NSRange?
    }

    required init() {}

    private func documentClass(of sourceCodeView: SourceCodeView) -> String? {
        let firstMatch = LaTeXLanguageDelegate.documentClassRegex.firstMatch(in: sourceCodeView.string, options: [], range: sourceCodeView.stringRange)

        guard let range = firstMatch?.range(at: 1) else {
            return nil
        }

        return sourceCodeView.nsString.substring(with: range)
    }

    private func documentStructure(of textStorage: NSTextStorage) -> DocumentStructureNode {
        let string = textStorage.string
        let range = NSRange(string.startIndex..<string.endIndex, in: string)
        var rootNode = LatexRootDocumentStructureNode(range: range, latexSubNodes: [])

        LaTeXLanguageDelegate.documentStructureRegex.enumerateMatches(in: string, options: [], range: range) { match, _, _ in
            if let match = match {
                _ = rootNode.recursiveCanHandleMatch(match.regularExpressionMatch(in: string))
            }
        }
        return rootNode
    }

    private func packages(usedIn latexCode: String) -> [String] {
        return LaTeXLanguageDelegate.packageRegex.matches(
            in: latexCode,
            options: [],
            range: NSRange(latexCode.startIndex..<latexCode.endIndex, in: latexCode)).map { rawMatch in
                let match = rawMatch.regularExpressionMatch(in: latexCode)
                return match.captureGroups[1].string
        }
    }

    private func scanPackages(in latexCode: String) {
        packages(usedIn: latexCode).forEach { packageName in
            if cachedPackages[packageName] == nil, let commands = scanCommands(in: packageName) {
                cachedPackages[packageName] = commands.map {
                    return LanguageCompletion(
                        displayString: $0,
                        completionString: $0.commandCompletionString,
                        image: LanguageCompletion.externalCommandImage)
                }
            }
        }
    }

    private func scanCommands(in packageName: String) -> [String]? {
        guard let process = Process.create(
                UserDefaults.latexdefPath.value,
                arguments: ["-lp", packageName],
                additionalEnvironmentPaths: [URL(fileURLWithPath: UserDefaults.latexPath.value).deletingLastPathComponent().path]) else {
                    return nil
        }

        let output = process.launchAndGetOutput()
        let matches = LaTeXLanguageDelegate.latexDefOutputRegex.matches(in: output, options: [], range: NSRange(output.startIndex..<output.endIndex, in: output))
        return matches.map {
            $0.regularExpressionMatch(in: output).captureGroups[1].string
        }
    }
}

extension LaTeXLanguageDelegate {
    private static let documentClassRegex = try! NSRegularExpression(pattern: "\\\\documentclass.*?\\{(\\w+)\\}", options: [])
    private static let documentStructureRegex = try! NSRegularExpression(pattern: "\\\\(begin|end|(?:part|section|subsection|subsubsection|paragraph|subparagraph)\\*?)\\{(.+?)\\}", options: [])

    private static let highlightingRules: [SourceCodeHighlightRule] = [
        SimpleHighlighter(pattern: "(\\d+)", colors: [.variable]),
        SimpleHighlighter(pattern: "(\\\\\\w*)", colors: [.keyword]),
        SimpleHighlighter(pattern: "(?:\\\\documentclass|usepackage|input)(?:\\[([^\\]]*)\\])?\\{([^}]*)\\}", colors: [.variable, .variable]),
        SimpleHighlighter(pattern: "(?:\\\\(?:begin|end))\\{([^}]*)\\}", colors: [.variable]),
        SimpleHighlighter(pattern: "(\\$.*?\\$)", colors: [.inlineMath]),
        SimpleHighlighter(pattern: "(%.*)$", colors: [.comment]),
    ]

    private static let packageRegex = try! NSRegularExpression(pattern: "\\\\usepackage\\{(.*?)\\}", options: [])
    private static let latexDefOutputRegex = try! NSRegularExpression(pattern: "^\\\\(.*)", options: NSRegularExpression.Options.anchorsMatchLines)
    private static let includeRegex = try! NSRegularExpression(pattern: "\\\\(?:includegraphics|input)(?:\\[.*?\\])?\\{(.*?)\\}", options: [])

    private static let templates: [LanguageCompletion] = {
        return FileManager.default.applicationSupportDirectoryFileContent(withPath: "latex/templates")
            .map { url, content in
                return LanguageCompletion(displayString: url.lastPathComponent, completionString: content, image: LanguageCompletion.templateImage)
        }
    }()

    private static let knownCommands: [LanguageCompletion] = {
        return FileManager.default.applicationSupportDirectoryFileContent(withPath: "latex/commands")
            .flatMap { url, content in
                return content.nonEmptyLines.map { command in
                    return LanguageCompletion(
                        displayString: command,
                        completionString: command.commandCompletionString,
                        image: LanguageCompletion.internalCommandImage)
                }
        }
    }()

    private static let knownArguments: [String: [LanguageCompletion]] = {
        let argumentsByCommand: [(String, [LanguageCompletion])] = FileManager.default.applicationSupportDirectoryFileContent(withPath: "latex/parameters")
            .map { url, content in
                let name = url.lastPathComponent
                let arguments = content.nonEmptyLines.map { arument in
                    return LanguageCompletion(
                        completionString: arument,
                        image: LanguageCompletion.internalParameter)
                }
                return (name, arguments)
        }

        return Dictionary(uniqueKeysWithValues: argumentsByCommand)
    }()
}


extension String {
    fileprivate var commandCompletionString: String {
        return "\\\(self){\(EditorParameterPlaceholder)}"
    }

    fileprivate var nonEmptyLines: [String] {
        return components(separatedBy: "\n").filter {
            !$0.isEmpty
        }
    }
}

