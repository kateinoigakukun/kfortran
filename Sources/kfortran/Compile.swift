import ArgumentParser
import Parser
import CodeGen
import LLVM

struct Compile: ParsableCommand {
    @Argument()
    var inputFile: String
    
    @Option()
    var output: String

    func run() throws {
        let contents = try String(contentsOfFile: inputFile)
        let programSyntax = try parseSyntax(contents)
        let llvmModule = try irgen(program: programSyntax)
        do {
            try llvmModule.verify()
        } catch {
            print(error)
        }
        llvmModule.dump()
        let target = try TargetMachine()
        try target.emitToFile(module: llvmModule, type: .object, path: output)
    }
}
