//
//  UIRegexLibTests.swift
//  UIRegexLibTests
//
//  Created by Noah Peeters on 11.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import XCTest
@testable import UIRegexLib

class UIRegexLibTests: XCTestCase {
    func testNexLineRegex() {
        let testString = """
            Hello World
            This is a test
            Bla

        """
        XCTAssertEqual(testString.numberOfLine(in: NSRange(location: 0, length: testString.count)), 3)
    }
}
