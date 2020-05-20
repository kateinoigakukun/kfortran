import Parser
import ArgumentParser
import Foundation

struct KFrotran: ParsableCommand {
    @Argument()
    var inputFile: String

    func run() throws {
        let contents = try String(contentsOfFile: inputFile)
    }
}
