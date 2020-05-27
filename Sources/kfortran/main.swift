import Parser
import CodeGen
import ArgumentParser
import Foundation

struct KFortran: ParsableCommand {
    @Argument()
    var inputFile: String

    func run() throws {
        let contents = try String(contentsOfFile: inputFile)
        let programSyntax = try parseSyntax(contents)
        let llvmModule = try irgen(program: programSyntax)
        llvmModule.dump()
    }
}

KFortran.main()
