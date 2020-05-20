

public struct MainProgram {
    public let executions: [SimpleExecution]
}

public struct ProgramStmt {
    public let name: String
}

public enum SimpleExecution: String, CaseIterable {
    case write
}

public class Parser {

    enum Error: Swift.Error {
        case consumeKeyword(expected: String, actual: Token?)
        case eof
        case invalidSimpleExecution(Token)
    }

    var tokens: [Token]
    var cursor: Int

    public init(tokens: [Token]) {
        self.tokens = tokens
        self.cursor = tokens.startIndex
    }

    func headToken(offset: Int = 0) -> Token? {
        tokens.count > (cursor + offset) ? tokens[cursor + offset] : nil
    }

    func consumeToken() {
        cursor += 1
    }

    func consumeKeyword(_ keyword: String) throws {
        guard case let .some(.identifier(id)) = headToken(),
            id.uppercased() == keyword else {
            throw Error.consumeKeyword(expected: keyword, actual: tokens.first)
        }
        consumeToken()
    }

    func parseMainProgram() throws -> MainProgram {
        try? consumeKeyword("PROGRAM")
        _ = parseDecls()
        var executions = [SimpleExecution]()
        while headToken() == .identifier("END") {
            executions.append(try parseSimpleExecution())
        }
        try consumeKeyword("END")
        try consumeKeyword("PROGRAM")
        return MainProgram(executions: executions)
    }

    func parseDecls() {
        // TODO:
    }
    func parseDecl() throws {
        // TODO:
    }

    func parseSimpleExecution() throws -> SimpleExecution {
        guard let head = headToken() else { throw Error.eof }
        switch head {
        case .identifier(let id):
            guard let execution = SimpleExecution.allCases
                .first(where: { $0.rawValue == id.lowercased() }) else {
                throw Error.invalidSimpleExecution(head)
            }
            consumeToken()
            return execution
        }
    }

    public func parse() throws -> MainProgram {
        return try parseMainProgram()
    }
}
