import LLVM
import Parser

public func irgen(program: MainProgram) throws -> Module {
    let igm = IRGenModule(moduleName: program.programStmt.name)
    try program.accept(igm)
    return igm.module
}

class IRGenModule {
    
    let builder: IRBuilder
    let module: Module
    let runtime: RuntimeFunctions
    
    init(moduleName: String) {
        module = Module(name: moduleName)
        builder = IRBuilder(module: module)
        runtime = RuntimeFunctions(builder: builder)
    }
}

extension IRGenModule: SyntaxVisitor {
    func visit(_ node: MainProgram) throws -> Void {
        let main = builder.addFunction("main", type: FunctionType([], IntType.int64))
        let entry = main.appendBasicBlock(named: "entry")
        builder.positionAtEnd(of: entry)
        
        for execution in node.executions {
            try execution.accept(self)
        }
    }

    func visit(_ node: ProgramStmt) throws -> Void {}
    func visit(_ node: EndProgramStmt) throws -> Void {}

    func visit(_ node: ExecutableConstruct) throws -> Void {
        switch node {
        case .action(let action): try action.accept(self)
        }
    }

    func visit(_ node: WriteStmt) throws -> Void {
        let value = try IRExprEmitter(igm: self).emit(node.outputItem)
        _ = builder.buildCall(runtime.write, args: [value])
    }
    
    func visit(_ node: StopStmt) throws -> Void {
        builder.buildRet(IntType.int64.constant(0))
    }
    
    func visit(_ node: DefinedOpName) throws -> Void { fatalError() }
    func visit(_ node: IoUnit) throws -> Void { fatalError() }
    func visit(_ node: Format) throws -> Void { fatalError() }
    func visit<E: Expr>(_ node: E) throws -> Void { fatalError() }
    
    typealias VisitResult = Void
}
