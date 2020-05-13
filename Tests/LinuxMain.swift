import XCTest

import kfortranTests

var tests = [XCTestCaseEntry]()
tests += kfortranTests.allTests()
XCTMain(tests)
