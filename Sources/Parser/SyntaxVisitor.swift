public protocol Syntax {
    func accept<V: SyntaxVisitor>(_ visitor: V) throws -> V.VisitResult
}

public protocol SyntaxVisitor {
    associatedtype VisitResult
    func visit(_ node: MainProgram) throws -> VisitResult
    func visit(_ node: ProgramStmt) throws -> VisitResult
    func visit(_ node: EndProgramStmt) throws -> VisitResult
    func visit(_ node: WriteStmt) throws -> VisitResult
    func visit(_ node: StopStmt) throws -> VisitResult
    func visit(_ node: DefinedOpName) throws -> VisitResult
    func visit(_ node: ExecutableConstruct) throws -> VisitResult
    func visit(_ node: IoUnit) throws -> VisitResult
    func visit(_ node: Format) throws -> VisitResult
    func visit(_ node: CharLiteralConstant) throws -> VisitResult
    func visit(_ node: IntLiteralConstant) throws -> VisitResult
    func visit(_ node: DefinedUnary) throws -> VisitResult
    
}

extension MainProgram: Syntax {
    public func accept<V>(_ visitor: V) throws -> V.VisitResult where V : SyntaxVisitor {
        try visitor.visit(self)
    }
}

