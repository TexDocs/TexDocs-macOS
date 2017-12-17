//
//  LaTeXLanguageDelegate.swift
//  TexDocs
//
//  Created by Noah Peeters on 07.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

class LaTeXLanguageDelegate: LanguageDelegate {
    private static var cachedPackages: [String: PackageInfo] = [:]
    private static let updateQueue = DispatchQueue(label: "LaTeXLanguageDelegate")
    private var rootStructureNode: DocumentStructureNode?
    private var annotations: [RulerAnnotation]?

    required init() {}

    func textStorageUpdated(_ textStorage: NSTextStorage) {
        let string = textStorage.string
        LaTeXLanguageDelegate.updateQueue.async { [weak self] in
            self?.scanPackages(in: string)
        }
    }

    func textStorageDocumentStructure(_ textStorage: NSTextStorage) -> DocumentStructureNode {
        if let rootStructureNode = rootStructureNode {
            return rootStructureNode
        }
        let newRootStructureNode = documentStructure(of: textStorage)
        self.rootStructureNode = newRootStructureNode
        return newRootStructureNode
    }

    func textStorageRulerAnnotations(_ textStorage: NSTextStorage) -> [RulerAnnotation] {
        return annotations(for: textStorage)
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

        LaTeXLanguageDelegate.updateQueue.async { [weak self] in
            self?.scanPackages(in: latexSource)

            var commands = LaTeXLanguageDelegate.cachedPackages.flatMap { $0.value.completions }

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

    private func annotations(for textStorage: NSTextStorage) -> [RulerAnnotation] {
        let string = textStorage.string
        let range = NSRange(string.startIndex..<string.endIndex, in: string)

        let files: [RulerAnnotation] = LaTeXLanguageDelegate.includeFilesRegex.matches(in: string, options: [], range: range).map {
            let match = $0.regularExpressionMatch(in: string)
            return RulerAnnotation(
                lineNumber: match.captureGroups[0].range.location,
                type: .file(relativePath: match.captureGroups[1].string))
        }

        let packageUses: [RulerAnnotation] = LaTeXLanguageDelegate.includePackageRegex.matches(in: string, options: [], range: range).flatMap {
            let match = $0.regularExpressionMatch(in: string)
            let packageName = match.captureGroups[1].string

            guard let packageInfo = LaTeXLanguageDelegate.cachedPackages[packageName] else {
                return nil
            }

            return RulerAnnotation(
                lineNumber: match.captureGroups[0].range.location,
                type: .helpFiles(packageInfo.helpFiles))
        }

        return files + packageUses
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
            if LaTeXLanguageDelegate.cachedPackages[packageName] == nil {
                let commands = scanCommands(in: packageName)
                let helpFiles = scanHelpfiles(for: packageName)

                let completions = commands.map {
                    return LanguageCompletion(
                        displayString: $0,
                        completionString: $0.commandCompletionString,
                        image: LanguageCompletion.externalCommandImage)
                }

                LaTeXLanguageDelegate.cachedPackages[packageName] = PackageInfo(completions: completions, helpFiles: helpFiles)
            }
        }
    }

    private func scanCommands(in packageName: String) -> [String] {
        guard let process = Process.create(
                UserDefaults.latexdefPath.value,
                arguments: ["-lp", packageName],
                additionalEnvironmentPaths: [URL(fileURLWithPath: UserDefaults.latexPath.value).deletingLastPathComponent().path]) else {
                    return []
        }

        let output = process.launchAndGetOutput()
        let matches = LaTeXLanguageDelegate.latexDefOutputRegex.matches(in: output, options: [], range: NSRange(output.startIndex..<output.endIndex, in: output))
        return matches.map {
            $0.regularExpressionMatch(in: output).captureGroups[1].string
        }
    }

    private func scanHelpfiles(for packageName: String) -> [HelpFile] {
        guard let process = Process.create(
            "/Library/TeX/texbin/texdoc",
            arguments: ["-l", "-M", packageName],
            additionalEnvironmentPaths: [URL(fileURLWithPath: UserDefaults.latexPath.value).deletingLastPathComponent().path],
            local: "en_US.UTF-8") else {
                return []
        }

        let output = process.launchAndGetOutput()
        return output.nonEmptyLines.flatMap {
            let components = $0.components(separatedBy: "\t")

            guard components.count == 5 else {
                return nil
            }

            let url = URL(fileURLWithPath: components[2])
            let lang = components[3]
            let description = components[4]

            let fullDescription: String?

            if description.count > 0 {
                if lang.count > 0 {
                    fullDescription = "\(description) + (\(lang)"
                } else {
                    fullDescription = description
                }
            } else {
                if lang.count > 0 {
                    fullDescription = lang
                } else {
                    fullDescription = nil
                }
            }

            return HelpFile(url: url, description: fullDescription)
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
    private static let includeFilesRegex = try! NSRegularExpression(pattern: "\\\\(?:includegraphics|input)(?:\\[.*?\\])?\\{(.*?)\\}", options: [])
    private static let includePackageRegex = try! NSRegularExpression(pattern: "\\\\usepackage(?:\\[.*?\\])?\\{(.*?)\\}", options: [])

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

private struct PackageInfo {
    let completions: [LanguageCompletion]
    let helpFiles: [HelpFile]
}

private struct InspectionResult {
    var commandRange: NSRange

    var commandRangeWithoutBackslash: NSRange {
        return NSRange(location: commandRange.location + 1, length: commandRange.length - 1)
    }

    var argumentRange: NSRange?
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

