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
    func visit(_ node: AssignmentStmt) throws -> VisitResult
    func visit(_ node: DefinedOpName) throws -> VisitResult
    func visit(_ node: ExecutableConstruct) throws -> VisitResult
    func visit(_ node: IoUnit) throws -> VisitResult
    func visit(_ node: Format) throws -> VisitResult
    func visit(_ node: CharLiteralConstant) throws -> VisitResult
    func visit(_ node: IntLiteralConstant) throws -> VisitResult
    func visit(_ node: DefinedUnary) throws -> VisitResult
    func visit(_ node: ObjectName) throws -> VisitResult
    func visit(_ node: Variable) throws -> VisitResult
}

extension SyntaxVisitor {
    public func doVisit(_ node: Syntax) throws -> VisitResult {
        try node.accept(self)
    }
}
