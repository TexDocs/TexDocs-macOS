//
//  LanguageCompletions.swift
//  TexDocs
//
//  Created by Noah Peeters on 10.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

struct LanguageCompletions {
    let words: [LanguageCompletion]
    let rangeForUserCompletion: NSRange

    init(words: [LanguageCompletion], range: NSRange) {
        self.words = words
        self.rangeForUserCompletion = range
    }

    var completionProposals: [String] {
        return words.enumerated().map({ "\($0): \($1.displayString)" })
    }

    func filteredAndSortedBy(searchTerm: String) -> LanguageCompletions {
        let rankedWords: [(LanguageCompletion, Int)] = words.flatMap { word in
            guard let score = word.displayString.score(forSearchTerm: searchTerm) else {
                return nil
            }
            return (word, score)
        }

        let newWords = rankedWords.sorted {
            return $0.1 > $1.1
        }

        return LanguageCompletions(words: newWords.map { $0.0 }, range: rangeForUserCompletion)
    }
}


struct LanguageCompletion {
    let displayString: String
    let completionString: String

    init(displayString: String, completionString: String) {
        self.displayString = displayString
        self.completionString = completionString
    }

    init(string: String) {
        self.init(displayString: string, completionString: string)
    }
}

extension String {
    func score(forSearchTerm searchTerm: String) -> Int? {
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
