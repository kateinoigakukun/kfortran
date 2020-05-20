import Curry

protocol ParsableSyntax {
    static func parser() -> SyntaxParser<Self>
}

enum SyntaxParserPhase: ParserPhase {
    typealias Collection = String
}

typealias SyntaxParser<T> = Parser<SyntaxParserPhase, T>

extension SyntaxParser {
    static func parser<U>() -> SyntaxParser<U> where U: ParsableSyntax {
        U.parser()
    }
}

fileprivate func toString(_ chars: [Character]) -> String { String(chars) }

func identifier() -> SyntaxParser<String> {
    skipSpaces() *> (toString <^> (
        cons <^> letter() <*> many(letter() <|> digit())
    ))
}

func keyword(_ name: String) -> SyntaxParser<Void> {
    token(name).map { _ in }
}

func letter() -> SyntaxParser<Character> {
    return satisfy { "A"..."Z" ~= $0 || "a"..."z" ~= $0 }
}

public struct DefinedOpName: ParsableSyntax {
    public let name: String
    static func parser() -> SyntaxParser<DefinedOpName> {
        skipSpaces() *>
            (
                DefinedOpName.init <^>
                    (char(".") *> (toString <^> many(letter())))
        )
    }
}
