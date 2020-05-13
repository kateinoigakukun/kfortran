public enum Token: Equatable {
    case identifier(String)
    
}

public func lex(_ input: String) throws -> [Token] {
    return input.split(separator: " ").map { Token.identifier(String($0)) }
}
