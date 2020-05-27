import LLVM
import Parser

public func irgen(program: MainProgram) {
    let igm = IRGenModule(moduleName: program.programStmt.name)
}


class IRGenModule {
    
    let builder: IRBuilder
    let module: Module
    
    init(moduleName: String) {
        module = Module(name: moduleName)
        builder = IRBuilder(module: module)
    }
    
    
    func emitMainProgram(program: MainProgram) {
        let main = builder.addFunction("main", type: FunctionType([], IntType.int64))
        let entry = main.appendBasicBlock(named: "entry")
        builder.positionAtEnd(of: entry)
        
        for execution in program.executions {
            emitExecutableConstruct(executable: execution)
        }
    }
    
    func emitExecutableConstruct(executable: ExecutableConstruct) {
    }
    
    func emitWriteStmt(stmt: WriteStmt) {
        
    }
}
