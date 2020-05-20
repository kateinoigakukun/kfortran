import Curry

public struct MainProgram: ParsableSyntax {
    public let programStmt: ProgramStmt
    public let executions: [ExecutableConstruct]
    public let endProgramStmt: EndProgramStmt
    
    static func parser() -> SyntaxParser<Self> {
        curry(Self.init)
            <^> .parser()
            <*> many(skipSpaces() *> ExecutableConstruct.parser())
            <*> skipSpaces() *> .parser()
    }
}

public struct ProgramStmt: ParsableSyntax {
    public let name: String
    
    static func parser() -> SyntaxParser<Self> {
        curry(Self.init) <^> keyword("PROGRAM") *> identifier()
    }
}

public struct EndProgramStmt: ParsableSyntax {
    public let name: String?
    
    static func parser() -> SyntaxParser<Self> {
        curry(Self.init) <^> keyword("END PROGRAM") *> orNil(identifier())
    }
}
