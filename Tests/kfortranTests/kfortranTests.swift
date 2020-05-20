import XCTest
import class Foundation.Bundle
import Parser

final class kfortranTests: XCTestCase {
    func testLex() throws {
        let code = """
        program hello
        write (*, *) 'Hello'
        stop
        end program hello
        """
        let tokens = try lex(code)
        let parser = Parser(tokens: tokens)
        let program = try parser.parse()
        _ = program
    }
}
