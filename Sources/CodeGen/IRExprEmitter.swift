import Parser
import cllvm
import LLVM

class IRExprEmitter: SyntaxVisitor {
    typealias VisitResult = IRValue
    
    let igm: IRGenModule
    init(igm: IRGenModule) {
        self.igm = igm
    }
    
    func emit(_ expr: Expr) throws -> IRValue {
        try self.doVisit(expr)
    }
    
    func visit(_ node: CharLiteralConstant) throws -> VisitResult {
        if let global = igm.module.global(named: node.value) {
            return global
        }
        let initializer = node.value.asLLVM()
        let global = igm.builder.addGlobal(node.value, type: initializer.type)
        var idxs = [0, 0].map { $0.asLLVM() as Optional }
        global.initializer = initializer
        return idxs.withUnsafeMutableBufferPointer { buf in
            LLVMConstGEP(global.asLLVM(), buf.baseAddress, UInt32(buf.count))
        }
    }


    func visit<T>(_ node: T) throws -> VisitResult {
        fatalError()
    }
}
