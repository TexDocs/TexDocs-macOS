//
//  LaTeXSourceCodeViewLanguageDelegate.swift
//  TexDocs
//
//  Created by Noah Peeters on 07.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

class LaTeXSourceCodeViewLanguageDelegate: SourceCodeViewLanguageDelegate {
    private var cachedPackages: [String: [String]] = [:]

    func prepareForSourceCodeView(_ sourceCodeView: SourceCodeView) {
        let latexSource = sourceCodeView.string
        DispatchQueue.main.async { [weak self] in
            self?.scanPackages(in: latexSource)
        }
    }

    func sourceCodeView(_ sourceCodeView: SourceCodeView, updateCodeHighlightingInRange editedRange: NSRange) {
        let range = sourceCodeView.nsString.lineRange(for: editedRange)

        sourceCodeView.textStorage?.addAttribute(NSAttributedStringKey.foregroundColor, value: ThemesHandler.default.color(for: .text), range: range)
        
        for rule in LaTeXSourceCodeViewLanguageDelegate.highlightingRules {
            rule.applyRule(to: sourceCodeView, range: range)
        }
    }

    func sourceCodeViewDocumentStructure(_ sourceCodeView: SourceCodeView) -> DocumentStructureNode {
        return documentStructure(of: sourceCodeView)
    }

    func sourceCodeView(_ sourceCodeView: SourceCodeView, completionsForLocation location: Int, completionBlock: @escaping (LanguageCompletions?) -> Void) {
        let latexSource = sourceCodeView.string
        let nslatexSource = NSString(string: latexSource)

        guard let inspectionResult = self.inspectCompletionLocation(location, inString: nslatexSource) else {
            completionBlock(nil)
            return
        }

        let commandString = nslatexSource.substring(with: inspectionResult.commandRange)

        if let argumentRange = inspectionResult.argumentRange {
            let argumentString = nslatexSource.substring(with: argumentRange)

            guard let completions = LaTeXSourceCodeViewLanguageDelegate.knownArguments[commandString] else {
                completionBlock(nil)
                return
            }

            completionBlock(LanguageCompletions(words: completions.map {
                return LanguageCompletion(completionString: $0, image: #imageLiteral(resourceName: "ParameterInternal"))
            }, range: argumentRange, filteredAndSortedBy: argumentString))
            return
        }

        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.scanPackages(in: latexSource)

            guard var commands = self?.cachedPackages.flatMap({ $0.value }).map({
                return LanguageCompletion(displayString: $0, completionString: "\($0){\(EditorParameterPlaceholder)}", image: #imageLiteral(resourceName: "CommandExternal"))
            }) else {
                completionBlock(nil)
                return
            }

            commands.append(contentsOf: LaTeXSourceCodeViewLanguageDelegate.knownCommands.map {
                return LanguageCompletion(displayString: $0, completionString: "\($0){\(EditorParameterPlaceholder)}", image: #imageLiteral(resourceName: "CommandInternal"))
            })

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
        var argumentRange: NSRange?
    }

    required init() {}

    private func documentClass(of sourceCodeView: SourceCodeView) -> String? {
        let firstMatch = LaTeXSourceCodeViewLanguageDelegate.documentClassRegex.firstMatch(in: sourceCodeView.string, options: [], range: sourceCodeView.stringRange)

        guard let range = firstMatch?.range(at: 1) else {
            return nil
        }

        return sourceCodeView.nsString.substring(with: range)
    }

    private func documentStructure(of sourceCodeView: SourceCodeView) -> DocumentStructureNode {
        var rootNode = LatexRootDocumentStructureNode(range: sourceCodeView.stringRange, latexSubNodes: [])

        LaTeXSourceCodeViewLanguageDelegate.documentStructureRegex.enumerateMatches(in: sourceCodeView.string, options: [], range: sourceCodeView.stringRange) { match, _, _ in
            if let match = match {
                _ = rootNode.recursiveCanHandleMatch(match.regularExpressionMatch(in: sourceCodeView.string))
            }
        }
        return rootNode
    }

    private func packages(usedIn latexCode: String) -> [String] {
        return LaTeXSourceCodeViewLanguageDelegate.packageRegex.matches(
            in: latexCode,
            options: [],
            range: NSRange(latexCode.startIndex..<latexCode.endIndex, in: latexCode)).map { rawMatch in
                let match = rawMatch.regularExpressionMatch(in: latexCode)
                return match.captureGroups[1].string
        }
    }

    private func scanPackages(in latexCode: String) {
        packages(usedIn: latexCode).forEach { packageName in
            if cachedPackages[packageName] == nil {
                cachedPackages[packageName] = scanCommands(in: packageName)
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
        let matches = LaTeXSourceCodeViewLanguageDelegate.latexDefOutputRegex.matches(in: output, options: [], range: NSRange(output.startIndex..<output.endIndex, in: output))
        return matches.map {
            $0.regularExpressionMatch(in: output).captureGroups[0].string
        }
    }
}

extension LaTeXSourceCodeViewLanguageDelegate {
    static let documentClassRegex = try! NSRegularExpression(pattern: "\\\\documentclass.*?\\{(\\w+)\\}", options: [])
    static let documentStructureRegex = try! NSRegularExpression(pattern: "\\\\(begin|end|(?:part|section|subsection|subsubsection|paragraph|subparagraph)\\*?)\\{(.+?)\\}", options: [])

    static let highlightingRules: [SourceCodeHighlightRule] = [
        SimpleHighlighter(pattern: "(\\d+)", colors: [.variable]),
        SimpleHighlighter(pattern: "(\\\\\\w*)", colors: [.keyword]),
        SimpleHighlighter(pattern: "(?:\\\\documentclass|usepackage|input)(?:\\[([^\\]]*)\\])?\\{([^}]*)\\}", colors: [.variable, .variable]),
        SimpleHighlighter(pattern: "(?:\\\\(?:begin|end))\\{([^}]*)\\}", colors: [.variable]),
        SimpleHighlighter(pattern: "(\\$.*?\\$)", colors: [.inlineMath]),
        SimpleHighlighter(pattern: "(%.*)$", colors: [.comment]),
    ]

    static let packageRegex = try! NSRegularExpression(pattern: "\\\\usepackage\\{(.*?)\\}", options: [])
    static let latexDefOutputRegex = try! NSRegularExpression(pattern: "^\\\\.*", options: NSRegularExpression.Options.anchorsMatchLines)

    static let knownArguments = [
        "\\begin": ["enumerate", "equation", "itemize", "list", "center"]
    ]

    static let knownCommands = ["\\begin", "\\def", "\\usepackage", "\\part", "\\chapter", "\\section", "\\subsection", "\\subsubsection", "\\paragraph", "\\subparagraph"]
}



