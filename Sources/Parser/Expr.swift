import Curry

public protocol Expr {}

public struct CharLiteralConstant: ParsableSyntax, Expr {
    let value: String
    static func parser() -> SyntaxParser<CharLiteralConstant> {
        return Self.init <^> (
            char("'") *> stringUntil(["'"]) <* char("'")
                <|> char("\"") *> stringUntil(["\""]) <* char("\"")
        )
    }
}

public struct IntLiteralConstant: ParsableSyntax, Expr {
    public let value: Int
    static func parser() -> SyntaxParser<IntLiteralConstant> {
        Self.init <^> number()
    }
}

func exprize<E: Expr>(_ expr: SyntaxParser<E>) -> SyntaxParser<Expr> {
    expr.map { $0 as Expr }
}

func primary() -> SyntaxParser<Expr> {

    return choice([
        exprize(CharLiteralConstant.parser()),
        exprize(IntLiteralConstant.parser()),
    ])
}

public struct DefinedUnary: ParsableSyntax, Expr {
    public let op: DefinedOpName
    public let expr: Expr
    static func parser() -> SyntaxParser<DefinedUnary> {
        curry(Self.init) <^> .parser() <*> primary()
    }
}

func level1Expr() -> SyntaxParser<Expr> {
    choice([
        primary(),
        exprize(DefinedUnary.parser()),
    ])
}

func expr() -> SyntaxParser<Expr> {
    level1Expr()
}
