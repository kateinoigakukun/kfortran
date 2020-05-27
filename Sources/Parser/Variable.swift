public struct ObjectName: ParsableSyntax {
    public let name: String
    static func parser() -> SyntaxParser<Self> {
        Self.init <^> identifier()
    }
    
    public func accept<V>(_ visitor: V) throws -> V.VisitResult where V : SyntaxVisitor {
        try visitor.visit(self)
    }
}

public enum Designator: ParsableSyntax {
    case objectName(ObjectName)
    static func parser() -> SyntaxParser<Self> {
        Designator.objectName <^> .parser()
    }
    
    public func accept<V>(_ visitor: V) throws -> V.VisitResult where V : SyntaxVisitor {
        try visitor.visit(self)
    }
}

public typealias Variable = Designator
