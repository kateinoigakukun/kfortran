import XCTest
import class Foundation.Bundle
@testable import Parser

final class kfortranTests: XCTestCase {
    
    func testParsers() throws {
        func success<S: ParsableSyntax>(_: S.Type, _ input: String, file: StaticString = #file, line: UInt = #line) {
            XCTAssertNoThrow(try S.parser().parse(.root(input)).0, file: file, line: line)
        }
        
        success(ProgramStmt.self, "PROGRAM hello")
        success(EndProgramStmt.self, "END PROGRAM hello")
        success(EndProgramStmt.self, "END PROGRAM")
        success(WriteStmt.self, "WRITE (*, *) 'Hello'")
        success(StopStmt.self, "STOP")
        success(AssignmentStmt.self, "a = 1")
        success(AssignmentStmt.self, "a =1")


        success(MainProgram.self, """
                PROGRAM hello
                WRITE (*, *) 'Hello'
                STOP
                END PROGRAM hello
                """
        )
    }
}
