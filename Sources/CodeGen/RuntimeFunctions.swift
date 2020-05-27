import LLVM

class RuntimeFunctions {
    let write: Function
    init(builder: IRBuilder) {
        write = builder.addFunction(
            "kfortran_write",
            type: FunctionType(
                [
                    PointerType(pointee: IntType.int8),
                ],
                VoidType()
            )
        )
    }
}
