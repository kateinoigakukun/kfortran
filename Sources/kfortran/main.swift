import Parser
import CodeGen
import ArgumentParser
import Foundation
import LLVM

struct Kfortran: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "kfortran",
        subcommands: [Compile.self, Driver.self],
        defaultSubcommand: Driver.self
    )
}

Kfortran.main()
