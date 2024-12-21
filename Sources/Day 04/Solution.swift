//
//  Solution.swift
//  Day 04
//
//  Copyright © 2024 peter bohac. All rights reserved.
//

// MARK: - Part 1

enum Direction: CaseIterable {
    case left, up, right, down
    case upLeft, upRight, downLeft, downRight
}

struct Coordinate: Hashable, CustomStringConvertible {
    var x: Int
    var y: Int

    var description: String { "(\(x), \(y))" }

    var up: Self { .init(x: x, y: y - 1) }
    var down: Self { .init(x: x, y: y + 1) }
    var left: Self { .init(x: x - 1, y: y) }
    var right: Self { .init(x: x + 1, y: y) }
    var upLeft: Self { .init(x: x - 1, y: y - 1) }
    var upRight: Self { .init(x: x + 1, y: y - 1) }
    var downLeft: Self { .init(x: x - 1, y: y + 1) }
    var downRight: Self { .init(x: x + 1, y: y + 1) }

    func next(_ direction: Direction) -> Self {
        switch direction {
        case .up: return up
        case .down: return down
        case .left: return left
        case .right: return right
        case .upLeft: return upLeft
        case .upRight: return upRight
        case .downLeft: return downLeft
        case .downRight: return downRight
        }
    }
}

enum Part1 {
    static func parse(_ lines: [String]) -> [Coordinate: Character] {
        lines.enumerated().reduce(into: [:]) { result, pair in
            let y = pair.offset
            result = pair.element.enumerated().reduce(into: result) { result, pair in
                let coord = Coordinate(x: pair.offset, y: y)
                result[coord] = pair.element
            }
        }
    }

    typealias FoundWord = [Coordinate]

    static func find(
        _ pattern: Array<Character>,
        in input: [Coordinate: Character],
        allowedDirections: [Direction] = Direction.allCases
    ) -> Set<FoundWord> {
        let length = pattern.count
        func word(from start: Coordinate, going direction: Direction) -> (word: Array<Character>, loc: FoundWord) {
            var coord = start
            var word: Array<Character?> = []
            var loc: FoundWord = []
            for _ in 0 ..< length {
                word.append(input[coord])
                loc.append(coord)
                coord = coord.next(direction)
            }
            return (word.compactMap { $0 }, loc)
        }
        var result: Set<FoundWord> = []
        for (start, char) in input where char == pattern.first {
            let words = allowedDirections.map { word(from: start, going: $0) }
            for possible in words where possible.word == pattern {
                result.insert(possible.loc)
            }
        }
        return result
    }

    static func run(_ source: InputData) {
        let input = parse(source.lines)
        let found = find(Array("XMAS"), in: input)
        print("Part 1 (\(source)): \(found.count)")
    }
}

// MARK: - Part 2

enum Part2 {
    static func run(_ source: InputData) {
        let input = Part1.parse(source.lines)
        let found = Part1.find(Array("MAS"), in: input, allowedDirections: [.upLeft, .upRight, .downLeft, .downRight])
        var count: [Coordinate: Int] = [:]
        for mas in found {
            let coordA = mas[1]
            count[coordA, default: 0] += 1
            assert(count[coordA] == 1 || count[coordA] == 2)
        }
        let result = count.filter { $0.value == 2 }.count
        print("Part 2 (\(source)): \(result)")
    }
}
