
@_cdecl("kfortran_write")
public func kfortran_write(_ string: UnsafePointer<CChar>) {
    let input = String(cString: string)
    print(input)
}
