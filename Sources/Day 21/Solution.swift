//
//  Solution.swift
//  Day 21
//
//  Copyright © 2024 peter bohac. All rights reserved.
//

// MARK: - Part 1

struct Pair<T1: Hashable, T2: Hashable>: Hashable {
    let a: T1
    let b: T2
}
func memoize<T1: Hashable, T2: Hashable, Output>(_ function: @escaping @Sendable (T1, T2) -> Output) -> @Sendable (T1, T2) -> Output {
    nonisolated(unsafe) var cache: [Pair<T1, T2>: Output] = [:]
    return { input1, input2 in
        let pair = Pair(a: input1, b: input2)
        if let result = cache[pair] {
            return result
        }
        let result = function(input1, input2)
        cache[pair] = result
        return result
    }
}

/*
 +---+---+---+
 | 7 | 8 | 9 |
 +---+---+---+
 | 4 | 5 | 6 |
 +---+---+---+
 | 1 | 2 | 3 |
 +---+---+---+
     | 0 | A |
     +---+---+
*/
/*
     +---+---+
     | ^ | A |
 +---+---+---+
 | < | v | > |
 +---+---+---+
*/

struct Coordinate: Hashable {
    let x: Int
    let y: Int
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
    var up: Self { .init(x, y - 1) }
    var down: Self { .init(x, y + 1) }
    var left: Self { .init(x - 1, y) }
    var right: Self { .init(x + 1, y) }
    var adjacent: [Self] { [up, left, right, down] }
    static let numberToCoord: [Character: Coordinate] = [
        "7": Coordinate(0, 0),
        "8": Coordinate(1, 0),
        "9": Coordinate(2, 0),
        "4": Coordinate(0, 1),
        "5": Coordinate(1, 1),
        "6": Coordinate(2, 1),
        "1": Coordinate(0, 2),
        "2": Coordinate(1, 2),
        "3": Coordinate(2, 2),
        "0": Coordinate(1, 3),
        "A": Coordinate(2, 3),
    ]
    static let coordToNumber: [Coordinate: Character] = [
        Coordinate(0, 0): "7",
        Coordinate(1, 0): "8",
        Coordinate(2, 0): "9",
        Coordinate(0, 1): "4",
        Coordinate(1, 1): "5",
        Coordinate(2, 1): "6",
        Coordinate(0, 2): "1",
        Coordinate(1, 2): "2",
        Coordinate(2, 2): "3",
        Coordinate(1, 3): "0",
        Coordinate(2, 3): "A",
    ]
    nonisolated(unsafe) static let buttonsForArrows: [Pair<Character, Character>: String] = [
        .init(a: "A", b: "A"): "",
        .init(a: "A", b: "^"): "<",
        .init(a: "A", b: ">"): "v",
        .init(a: "A", b: "v"): "<v", // not "v<"
        .init(a: "A", b: "<"): "v<<",

        .init(a: "^", b: "^"): "",
        .init(a: "^", b: "A"): ">",
        .init(a: "^", b: "<"): "v<",
        .init(a: "^", b: "v"): "v",
        .init(a: "^", b: ">"): "v>",

        .init(a: ">", b: ">"): "",
        .init(a: ">", b: "A"): "^",
        .init(a: ">", b: "^"): "<^", // not "^<"
        .init(a: ">", b: "v"): "<",
        .init(a: ">", b: "<"): "<<",

        .init(a: "v", b: "v"): "",
        .init(a: "v", b: "A"): "^>", // not ">^"
        .init(a: "v", b: "^"): "^",
        .init(a: "v", b: ">"): ">",
        .init(a: "v", b: "<"): "<",

        .init(a: "<", b: "<"): "",
        .init(a: "<", b: "A"): ">>^",
        .init(a: "<", b: "^"): ">^",
        .init(a: "<", b: ">"): ">>",
        .init(a: "<", b: "v"): ">",
    ]
}

func paths(from startKey: Character, to endKey: Character) -> [String] {
    if startKey == endKey { return [""] }
    if "^v<>".contains(startKey) || "^v<>".contains(endKey) {
        return [Coordinate.buttonsForArrows[.init(a: startKey, b: endKey)]!]
    }
    var paths: [String] = []
    var queue: [[(key: Character, direction: String)]] = [[(startKey, "")]]
    while let path = queue.popLast() {
        let currentElement = path.last!
        if currentElement.key == endKey {
            paths.append(path.map(\.direction).joined())
            continue
        }
        let current = Coordinate.numberToCoord[currentElement.key]!
        for (coord, direction) in [(current.up, "^"), (current.down, "v"), (current.left, "<"), (current.right, ">")] {
            guard let keyAtCoord = Coordinate.coordToNumber[coord] else { continue }
            if path.contains(where: { $0.key == keyAtCoord }) == false {
                queue.append(path + [(keyAtCoord, direction)])
            }
        }
    }
    let sortedPaths = paths.sorted { $0.count < $1.count }
    let result = sortedPaths.filter { $0.count == sortedPaths[0].count }
    return result
}
let memoizedPaths = memoize(paths)

enum Part1 {
    static func buttonsToControlRobot(_ code: String) -> [String] {
        let keys = ["A"] + Array(code)
        let result: [String] = keys.enumerated().dropLast().reduce([""]) { buttons, item in
            let key1 = item.element
            let key2 = keys[item.offset + 1]
            let paths = memoizedPaths(key1, key2).map { $0 + "A" }
            var result: [String] = []
            for button in buttons {
                for path in paths {
                    result.append(button + path)
                }
            }
            return result
        }
        let sorted = result.sorted { $0.count < $1.count }
        return sorted.filter { $0.count == sorted[0].count }
    }
    static func arrowsForArrows(_ codes: String) -> String {
        var lastKey: Character = "A"
        return codes.map { key in
            let keys = Coordinate.buttonsForArrows[.init(a: lastKey, b: key)]! + "A"
            lastKey = key
            return keys
        }.joined()
    }
    static func buttonsForSecondRobot(_ codes: [String]) -> String {
        return codes.map(arrowsForArrows)
            .map { (second: $0, third: arrowsForArrows($0)) }
            .sorted { $0.third.count < $1.third.count }[0].second
    }

    static func run(_ source: InputData) {
        let sum = source.lines.reduce(into: 0) { sum, code in
            let arrowsForNumbers = buttonsToControlRobot(code)
            let secondRobot = buttonsForSecondRobot(arrowsForNumbers)
            let thirdRobot = arrowsForArrows(secondRobot)
            let complexity = thirdRobot.count * Int(code.dropLast())!
            sum += complexity
        }
        print("Part 1 (\(source)): \(sum)")
    }
}

// MARK: - Part 2

extension Collection where Element: Hashable {
    var allPairs: [Pair<Element, Element>] {
        flatMap { a in
            map { b in Pair(a: a, b: b) }
        }
    }
}
extension Dictionary where Key == Coordinate, Value == Character {
    func allPaths() -> [Pair<Character, Character>: [String]] {
        keys.allPairs.reduce(into: [:]) { result, pair in
            let a = self[pair.a]!
            let b = self[pair.b]!
            result[Pair(a: a, b: b)] = memoizedPaths(a, b)
        }
    }
}
extension Coordinate {
    static let coordToArrow: [Coordinate: Character] = [
        Coordinate(1, 0): "^",
        Coordinate(2, 0): "A",
        Coordinate(0, 1): "<",
        Coordinate(1, 1): "v",
        Coordinate(2, 1): ">",
    ]
    nonisolated(unsafe) static let numberPaths = coordToNumber.allPaths()
    nonisolated(unsafe) static let arrowPaths = coordToArrow.allPaths()
}

enum Part2 {
    static let memoizedFindCost = memoize { findCost(for: $0, robot: $1, paths: Coordinate.arrowPaths) }
    static func findCost(
        for code: String,
        robot: Int,
        paths: [Pair<Character, Character>: [String]] = Coordinate.numberPaths
    ) -> Int {
        var lastKey: Character = "A"
        return code.reduce(into: 0) { sum, key in
            let possibilities = paths[.init(a: lastKey, b: key)]!
            if robot == 0 {
                sum += possibilities.map(\.count).min()! + 1 // + 1 for the "A"
            } else {
                sum += possibilities.map { memoizedFindCost($0 + "A", robot - 1) }.min()!
            }
            lastKey = key
        }
    }

    static func run(_ source: InputData) {
        let sum = source.lines.reduce(0) {
            $0 + findCost(for: $1, robot: 25) * Int($1.dropLast())!
        }
        print("Part 2 (\(source)): \(sum)")
    }
}
