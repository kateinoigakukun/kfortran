import Curry

public enum ExecutableConstruct: ParsableSyntax {
    case action(ActionStmt)
    
    static func parser() -> SyntaxParser<Self> {
        Self.action <^> actionStmt()
    }
}

public protocol ActionStmt {}

func actionStmt() -> SyntaxParser<ActionStmt> {
    func transform<T: ActionStmt>(_ parser: SyntaxParser<T>) -> SyntaxParser<ActionStmt> {
        parser.map { $0 as ActionStmt }
    }
    return choice([
        transform(WriteStmt.parser()),
        transform(StopStmt.parser()),
    ])
}

public struct IoUnit: ParsableSyntax {
    static func parser() -> SyntaxParser<IoUnit> {
        const(.init()) <^> char("*")
    }
}

public struct Format: ParsableSyntax {
    static func parser() -> SyntaxParser<Format> {
        const(.init()) <^> char("*")
    }
}

public struct WriteStmt: ParsableSyntax, ActionStmt {


    public let unit: IoUnit
    public let format: IoUnit
    public let outputItem: Expr

    static func parser() -> SyntaxParser<WriteStmt> {
        curry(Self.init)
            <^> keyword("WRITE (") *> (orNil(keyword("UNIT=")) *> .parser())
            <*> skipSpaces() *> (char(",") *> skipSpaces() *> .parser()) <* char(")")
            <*> skipSpaces() *> expr()
    }
}

public struct StopStmt: ParsableSyntax, ActionStmt {
    static func parser() -> SyntaxParser<StopStmt> {
        .pure(Self()) <* keyword("STOP")
    }
}
