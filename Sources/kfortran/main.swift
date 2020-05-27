import Parser
import CodeGen
import ArgumentParser
import Foundation
import LLVM

struct Kfortran: ParsableCommand {
    
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
    
    struct Driver: ParsableCommand {
        @Argument()
        var inputFile: String
        
        @Option()
        var output: String

        func run() throws {
            let outputPath = URL(fileURLWithPath: output)
            var compile = Compile()
            compile.inputFile = inputFile
            compile.output = outputPath
                .deletingPathExtension()
                .appendingPathExtension("o")
                .path
            try compile.run()
            var (sdkPath, _) = try Process.exec(bin: "/usr/bin/xcrun", arguments: ["--show-sdk-path"])
            sdkPath = sdkPath.trimmingCharacters(in: .whitespacesAndNewlines)
            let sdkLibPath = URL(fileURLWithPath: sdkPath)
                .appendingPathComponent("usr")
                .appendingPathComponent("lib")
                .appendingPathComponent("swift")
                .path
            var (swiftcPath, _) = try Process.exec(bin: "/usr/bin/xcrun", arguments: ["--find", "swiftc"])
            swiftcPath = swiftcPath.trimmingCharacters(in: .whitespacesAndNewlines)
            let swiftLibPath = URL(fileURLWithPath: swiftcPath)
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .appendingPathComponent("lib")
                .appendingPathComponent("swift")
                .appendingPathComponent("macosx")
                .path
            let linkerArguments = [
                compile.output,
                runtimeLibrary().path,
                "-lSystem",
                "-L", swiftLibPath, "-L", sdkLibPath,
                "-o", output
            ]
            try Process.exec(bin: "/usr/bin/ld", arguments: linkerArguments)
        }
        
        func runtimeLibrary() -> URL {
            let libName = "libkfortran_Runtime.a"
            return Bundle.main.executableURL!.deletingLastPathComponent().appendingPathComponent(libName)
        }
    }

    static let configuration = CommandConfiguration(
        commandName: "kfortran",
        subcommands: [Compile.self, Driver.self],
        defaultSubcommand: Driver.self
    )
}

Kfortran.main()
