
@_cdecl("f_write")
public func f_write(_ string: UnsafePointer<CChar>) {
    let input = String(cString: string)
    print(input)
}
