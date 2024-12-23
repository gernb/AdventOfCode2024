//
//  Solution.swift
//  Day 10
//
//  Copyright © 2024 peter bohac. All rights reserved.
//

// MARK: - Part 1

struct Coordinate: Hashable, CustomStringConvertible {
    var x: Int
    var y: Int

    var description: String { "(\(x), \(y))" }

    var up: Self { .init(x: x, y: y - 1) }
    var down: Self { .init(x: x, y: y + 1) }
    var left: Self { .init(x: x - 1, y: y) }
    var right: Self { .init(x: x + 1, y: y) }
    var adjacent: [Self] { [up, left, right, down] }
}

func parseMap<Element>(from lines: [String], using builder: (Coordinate, Character) -> Element?) -> [Coordinate: Element] {
    lines.enumerated().reduce(into: [:]) { result, pair in
        let y = pair.offset
        result = pair.element.enumerated().reduce(into: result) { result, pair in
            let coord = Coordinate(x: pair.offset, y: y)
            result[coord] = builder(coord, pair.element)
        }
    }
}

extension Collection where Element: Comparable {
    func range() -> ClosedRange<Element> {
        precondition(count > 0)
        let sorted = self.sorted()
        return sorted.first! ... sorted.last!
    }
}
extension Dictionary where Key == Coordinate {
    var xRange: ClosedRange<Int> { keys.map { $0.x }.range() }
    var yRange: ClosedRange<Int> { keys.map { $0.y }.range() }
}
extension Dictionary where Key == Coordinate, Value == Int {
    func trailheads() -> [Coordinate] {
        Array(filter { $0.value == 0 }.keys)
    }
}

enum Part1 {
    static func peaks(from start: Coordinate, topoMap: [Coordinate: Int]) -> Set<Coordinate> {
        let height = topoMap[start]!
        if height == 9 { return [start] }
        let next = start.adjacent.filter {
            guard let nextHeight = topoMap[$0] else { return false }
            return nextHeight == height + 1
        }
        return next.reduce(into: []) { $0.formUnion(peaks(from: $1, topoMap: topoMap)) }
    }

    static func run(_ source: InputData) {
        let topoMap = parseMap(from: source.lines) { Int(String($1))! }
        let result = topoMap.trailheads().reduce(0) {
            let reachablePeaks = peaks(from: $1, topoMap: topoMap)
            return $0 + reachablePeaks.count
        }
        print("Part 1 (\(source)): \(result)")
    }
}

// MARK: - Part 2

enum Part2 {
    static func trails(from start: Coordinate, topoMap: [Coordinate: Int]) -> Int {
        let height = topoMap[start]!
        if height == 9 { return 1 }
        let next = start.adjacent.filter {
            guard let nextHeight = topoMap[$0] else { return false }
            return nextHeight == height + 1
        }
        return next.reduce(0) { $0 + trails(from: $1, topoMap: topoMap) }
    }

    static func run(_ source: InputData) {
        let topoMap = parseMap(from: source.lines) { Int(String($1))! }
        let result = topoMap.trailheads().reduce(0) { $0 + trails(from: $1, topoMap: topoMap) }
        print("Part 2 (\(source)): \(result)")
    }
}
