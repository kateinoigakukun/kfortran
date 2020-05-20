public struct ParserInput<C: Collection> {
    let collection: C
    let startIndex: C.Index

    fileprivate init(collection: C) {
        self.collection = collection
        self.startIndex = collection.startIndex
    }

    public static func root(_ collection: C) -> ParserInput<C> {
        return .init(collection: collection)
    }

    init(previous: ParserInput, newIndex: C.Index) {
        self.collection = previous.collection
        self.startIndex = newIndex
    }

    public var cursor: C.Element {
        return collection[startIndex]
    }
}

public protocol ParserPhase {
    associatedtype Collection: Swift.Collection
}

public struct Parser<Phase: ParserPhase, T> {
    public typealias Input = ParserInput<Phase.Collection>
    public let parse: (Input) throws -> (T, Input)

    public init(parse: @escaping (Input) throws -> (T, Input)) {
        self.parse = parse
    }

    @inline(__always)
    public func map<U>(_ transformer: @escaping (T) throws -> U) -> Parser<Phase, U> {
        return Parser<Phase, U> {
            let (result1, tail1) = try self.parse($0)
            return (try transformer(result1), tail1)
        }
    }

    @inline(__always)
    public func flatMap<U>(_ transformer: @escaping (T) throws -> Parser<Phase, U>) -> Parser<Phase, U> {
        return Parser<Phase, U> { input1 in
            let (result1, input2) = try self.parse(input1)
            return try transformer(result1).parse(input2)
        }
    }

    @inline(__always)
    public static func pure(_ value: T) -> Parser<Phase, T> {
        return Parser<Phase, T> { (value, $0) }
    }

    @inline(__always)
    public static func fail(_ error: Error) -> Parser<Phase, T> {
        return Parser<Phase, T> { _ in throw error }
    }
}

@inline(__always)
public func id<A>(a: A) -> A { return a }

@inline(__always)
public func const<A, B>(_ a: A) -> (B) -> A {
    return { _ in return a }
}

@inline(__always)
public func void<A>(_: A) -> Void {}

@inline(__always)
public func cons<E>(_ x: E) -> ([E]) -> [E] {
    return { xs in
        var xs = xs
        xs.insert(x, at: xs.startIndex)
        return xs
    }
}

precedencegroup MonadicPrecedenceLeft {
    associativity: left
    lowerThan: LogicalDisjunctionPrecedence
    higherThan: AssignmentPrecedence
}

precedencegroup AlternativePrecedence {
    associativity: left
    higherThan: LogicalConjunctionPrecedence
    lowerThan: ComparisonPrecedence
}

precedencegroup ApplicativePrecedence {
    associativity: left
    higherThan: AlternativePrecedence
    lowerThan: NilCoalescingPrecedence
}

precedencegroup ApplicativeSequencePrecedence {
    associativity: left
    higherThan: ApplicativePrecedence
    lowerThan: NilCoalescingPrecedence
}

infix operator <^> : ApplicativePrecedence
infix operator <*> : ApplicativePrecedence
infix operator <* : ApplicativeSequencePrecedence
infix operator *> : ApplicativeSequencePrecedence
infix operator <|> : AlternativePrecedence
infix operator >>- : MonadicPrecedenceLeft

@inline(__always)
public func <|> <Phase, T>(a: Parser<Phase, T>, b: @autoclosure @escaping () -> Parser<Phase, T>) -> Parser<Phase, T> {
    return Parser { input in
        do {
            return try a.parse(input)
        } catch {
            return try b().parse(input)
        }
    }
}

@inline(__always)
public func <*> <Phase, A, B>(a: Parser<Phase, (A) -> B>, b: @autoclosure @escaping () -> Parser<Phase, A>) -> Parser<Phase, B> {
    //    return a.flatMap { f in b().map { f($0) } }
    return Parser<Phase, B> { content in
        let (f, tailA) = try a.parse(content)
        let (arg, tailB) = try b().parse(tailA)
        return (f(arg), tailB)
    }
}

@inline(__always)
public func <^> <Phase, A, B>(f: @escaping (A) -> B, p: @autoclosure @escaping () -> Parser<Phase, A>) -> Parser<Phase, B> {
    return Parser { content in
        let (a, tailA) = try p().parse(content)
        return (f(a), tailA)
    }
}

@inline(__always)
public func >>- <Phase, A, B>(p: Parser<Phase, A>, f: @escaping (A) -> Parser<Phase, B>) -> Parser<Phase, B> {
    return p.flatMap(f)
}

@inline(__always)
public func *> <Phase, A, B>(a: Parser<Phase, A>, b: Parser<Phase, B>) -> Parser<Phase, B> {
    //    return const(id) <^> a <*> b
    return Parser<Phase, B> { content in
        let (_, tailA) = try a.parse(content)
        return try b.parse(tailA)
    }
}

@inline(__always)
public func <* <Phase, A, B>(a: Parser<Phase, A>, b: Parser<Phase, B>) -> Parser<Phase, A> {
    //    return const <^> a <*> b
    return Parser<Phase, A> { content in
        let (resultA, tailA) = try a.parse(content)
        let (_, tailB) = try b.parse(tailA)
        return (resultA, tailB)
    }
}

enum ChoiceError: Error { case noMatch }

public func choice<Phase, T>(_ ps: [Parser<Phase, T>]) -> Parser<Phase, T> {
    return Parser { content in
        for p in ps {
            guard let r = try? p.parse(content) else { continue }
            return r
        }
        throw ChoiceError.noMatch
    }
}

public func many<Phase, T>(_ p: Parser<Phase, T>, function: StaticString = #function) -> Parser<Phase, [T]> {
    return many1(p, function: function) <|> Parser.pure([])
}

public func many1<Phase, T>(_ p: Parser<Phase, T>, function: StaticString = #function) -> Parser<Phase, [T]> {
    return Parser<Phase, [T]> { content in
        let r_1 = try p.parse(content)
        var list: [T] = [r_1.0]
        var tail = r_1.1
        while let r_n = try? p.parse(tail) {
            tail = r_n.1
            list.append(r_n.0)
        }
        return (list, tail)
    }
}

enum SatisfyError<C: Collection>: Error {
    case invalid(head: C.Element, input: ParserInput<C>), empty
}

public func satisfy<Phase>(predicate: @escaping (Phase.Collection.Element) -> Bool) -> Parser<Phase, Phase.Collection.Element> {
    return Parser { input in
        guard input.startIndex != input.collection.endIndex  else {
            throw SatisfyError<Phase.Collection>.empty
        }

        let head = input.collection[input.startIndex]
        let index1 = input.collection.index(after: input.startIndex)
        let newInput = ParserInput(previous: input, newIndex: index1)
        guard predicate(head) else {
            throw SatisfyError<Phase.Collection>.invalid(head: head, input: input)
        }
        return (head, newInput)
    }
}

public func orNil<Phase, T>(_ p: Parser<Phase, T>) -> Parser<Phase, T?> {
    return (Optional.some <^> p) <|> .pure(nil)
}

public func satisfyString<Phase>(predicate: @escaping (Character) -> Bool) -> Parser<Phase, String> where Phase.Collection == String {
    return many(satisfy(predicate: { predicate($0) }))
        .map { String($0) }
}

public func stringUntil<Phase>(_ until: [Character]) -> Parser<Phase, String> where Phase.Collection == String {
    return notEmpty(
        satisfyString(predicate: {
            !until.contains($0)
        })
    )
}

struct NotEmptyError: Error {}

public func notEmpty<Phase, T: Collection>(_ p: Parser<Phase, T>) -> Parser<Phase, T> {
    return p.map {
        if $0.isEmpty {
            throw NotEmptyError()
        } else {
            return $0
        }
    }
}

public func char<Phase>(_ c: Phase.Collection.Element) -> Parser<Phase, Phase.Collection.Element> where Phase.Collection.Element: Equatable {
    return satisfy(predicate: { $0 == c })
}

public func skipSpaces<Phase>() -> Parser<Phase, Void> where Phase.Collection == String {
    return void <^> many(char(" ") <|> char("\n"))
}

public func digit<Phase>() -> Parser<Phase, Character> where Phase.Collection == String {
    return satisfy { "0"..."9" ~= $0 }
}

public func number<Phase>() -> Parser<Phase, Int> where Phase.Collection == String {
    return many1(digit()).map { Int(String($0))! }
}

enum TokenError: Error {
    case not(
        String,
        input: ParserInput<String>,
        text: String.SubSequence,
        file: StaticString, function: StaticString, line: Int
    ),
    outOfBounds
}

public func token<Phase>(_ string: String, file: StaticString = #file, function: StaticString = #function, line: Int = #line) -> Parser<Phase, String> where Phase.Collection == String {
    return Parser { input1 in
        guard let endIndex = input1.collection.index(input1.startIndex, offsetBy: string.count, limitedBy: input1.collection.endIndex) else {
            throw TokenError.outOfBounds
        }
        let prefix = input1.collection[input1.startIndex..<endIndex]
        guard prefix == string else {
            throw TokenError.not(
                string, input: input1,
                text: input1.collection[input1.startIndex...],
                file: file, function: function, line: line
            )
        }
        let newStartIndex = input1.collection.index(input1.startIndex, offsetBy: string.count)
        let input2 = ParserInput(
            previous: input1,
            newIndex: newStartIndex
        )
        return (String(prefix), input2)
    }
}

enum EofError: Error { case noMatch }

public func lexEof<Phase>() -> Parser<Phase ,Void> {
    return Parser { input in
        if input.collection.endIndex == input.startIndex {
            return ((), input)
        } else {
            throw EofError.noMatch
        }
    }
}

public func withOffset<Phase, T>(_ p: Parser<Phase, T>) -> Parser<Phase, (T, Phase.Collection.Index)> {
    return Parser { input in
        let (v, newInput) = try p.parse(input)
        return ((v, input.startIndex), newInput)
    }
}

enum MatchError: Error {
    case notMatch
}

public func consumeMap<Phase, U>(_ f: @escaping (Phase.Collection.Element) -> U?) -> Parser<Phase, U> {
    Parser { input in
        let head = input.collection[input.startIndex]
        guard let result = f(head) else {
            throw MatchError.notMatch
        }
        let newIndex = input.collection.index(after: input.startIndex)
        let newInput = Parser<Phase, U>.Input(previous: input, newIndex: newIndex)
        return (result, newInput)
    }
}


public func debugPrint<Phase>(_ message: String, file: StaticString = #file, line: Int = #line) -> Parser<Phase, Void> {
    return Parser { input in
        print("[\(message) \(file.description.split(separator: "/").last!):\(line)] \(input.cursor)")
        return ((), input)
    }
}
