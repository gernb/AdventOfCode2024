//
//  Solution.swift
//  Day 25
//
//  Copyright © 2024 peter bohac. All rights reserved.
//

// MARK: - Part 1

struct Coordinate: Hashable, CustomStringConvertible {
    var x: Int
    var y: Int

    static let origin: Self = .init(x: 0, y: 0)
    var description: String { "(\(x), \(y))" }
}

func parseGrid<Tile>(from lines: [String].SubSequence, using builder: (Coordinate, Character) -> Tile?) -> [Coordinate: Tile] {
    lines.enumerated().reduce(into: [:]) { result, pair in
        let y = pair.offset
        result = pair.element.enumerated().reduce(into: result) { result, pair in
            let coord = Coordinate(x: pair.offset, y: y)
            result[coord] = builder(coord, pair.element)
        }
    }
}

enum Part1 {
    static func parse(_ lines: [String]) -> (locks: [Set<Coordinate>], keys: [Set<Coordinate>]) {
        var locks: [Set<Coordinate>] = []
        var keys: [Set<Coordinate>] = []
        lines.split(separator: "").forEach { input in
            let grid = parseGrid(from: input) { $1 == "#" ? true : nil }
            if grid[.origin] != nil {
                locks.append(Set(grid.keys))
            } else {
                keys.append(Set(grid.keys))
            }
        }
        return (locks, keys)
    }

    static func run(_ source: InputData) {
        let (locks, keys) = parse(source.lines)
        let result = locks.reduce(0) { sum, lock in
            sum + keys.reduce(0) { fitCount, key in
                fitCount + (lock.isDisjoint(with: key) ? 1 : 0)
            }
        }
        print("Part 1 (\(source)): \(result)")
    }
}

// MARK: - Part 2

enum Part2 {
    static func run(_ source: InputData) {}
}
