//
//  LanguageCompletions.swift
//  TexDocs
//
//  Created by Noah Peeters on 10.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

struct LanguageCompletions {
    let words: [LanguageCompletion]
    let rangeForUserCompletion: NSRange

    var count: Int {
        return words.count
    }

    init(words: [LanguageCompletion], range: NSRange, filteredAndSortedBy searchTerm: String) {
        self.rangeForUserCompletion = range

        let rankedWords: [(LanguageCompletion, Int)] = words.flatMap { word in
            guard let score = word.displayString.score(forSearchTerm: searchTerm) else {
                return nil
            }
            return (word, score)
        }

        self.words = rankedWords.sorted {
            return $0.1 > $1.1
        }.map { $0.0 }
    }
}

struct LanguageCompletion {
    let displayString: String
    let completionString: String
    let image: NSImage

    init(displayString: String? = nil, completionString: String, image: NSImage) {
        self.displayString = displayString ?? completionString
        self.completionString = completionString
        self.image = image
    }

    static let internalCommandImage = #imageLiteral(resourceName: "CommandInternal")
    static let internalParameter    = #imageLiteral(resourceName: "ParameterInternal")
    static let externalCommandImage = #imageLiteral(resourceName: "CommandExternal")
    static let templateImage        = #imageLiteral(resourceName: "TemplateInternal")
}

extension String {
    func score(forSearchTerm searchTerm: String) -> Int? {
        guard searchTerm.count > 0, self.count > 0 else {
            return 0
        }

        var prefixMatchingCharacters = 0
        var onlyFoundMatchingCharacters = true
        var searchTermHead = searchTerm.startIndex
        var stringHead = self.startIndex
        let searchTermEndIndex = searchTerm.endIndex
        let stringEndIndex = self.endIndex

        while true {
            if searchTerm[searchTermHead] == self[stringHead] {
                if onlyFoundMatchingCharacters {
                    prefixMatchingCharacters += 1
                }

                searchTermHead = searchTerm.index(after: searchTermHead)
                if searchTermHead == searchTermEndIndex {
                    return prefixMatchingCharacters
                }
            } else {
                onlyFoundMatchingCharacters = false
            }
            stringHead = self.index(after: stringHead)
            if stringHead == stringEndIndex {
                return nil
            }
        }
    }
}
