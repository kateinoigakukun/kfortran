import ArgumentParser
import Foundation

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

        let linkerArguments = try [
            compile.output,
            runtimeLibrary().path,
            "-lSystem",
            "-L", swiftLibPath().path,
            "-L", sdkLibPath().path,
            "-o", output
        ]
        try Process.exec(bin: "/usr/bin/ld", arguments: linkerArguments)
    }
    
    func sdkLibPath() throws -> URL {
        var (sdkPath, _) = try Process.exec(bin: "/usr/bin/xcrun", arguments: ["--show-sdk-path"])
        sdkPath = sdkPath.trimmingCharacters(in: .whitespacesAndNewlines)
        return URL(fileURLWithPath: sdkPath)
            .appendingPathComponent("usr")
            .appendingPathComponent("lib")
            .appendingPathComponent("swift")
    }
    
    func swiftLibPath() throws -> URL {
        var (swiftcPath, _) = try Process.exec(bin: "/usr/bin/xcrun", arguments: ["--find", "swiftc"])
        swiftcPath = swiftcPath.trimmingCharacters(in: .whitespacesAndNewlines)
        return URL(fileURLWithPath: swiftcPath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("lib")
            .appendingPathComponent("swift")
            .appendingPathComponent("macosx")
    }
    
    func runtimeLibrary() -> URL {
        let libName = "libkfortran_Runtime.a"
        return Bundle.main.executableURL!.deletingLastPathComponent().appendingPathComponent(libName)
    }
}
