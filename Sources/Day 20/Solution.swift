//
//  Solution.swift
//  Day 20
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

func parseGrid<Tile>(from lines: [String], using builder: (Coordinate, Character) -> Tile?) -> [Coordinate: Tile] {
    lines.enumerated().reduce(into: [:]) { result, pair in
        let y = pair.offset
        result = pair.element.enumerated().reduce(into: result) { result, pair in
            let coord = Coordinate(x: pair.offset, y: y)
            result[coord] = builder(coord, pair.element)
        }
    }
}

enum Tile: Character {
    case wall = "#"
    case start = "S"
    case end = "E"
    case empty = "."
}

func findShortestDistance<Node: Hashable>(from start: Node, using getNextNodes: ((Node) -> [Node]?)) -> Int? {
    var visited: [Node: Int] = [:]
    var queue: [(node: Node, steps: Int)] = [(start, 0)]

    while queue.isEmpty == false {
        var (node, steps) = queue.removeFirst()
        guard let nextNodes = getNextNodes(node) else {
            return steps
        }
        steps += 1
        for nextNode in nextNodes {
            if let previousSteps = visited[nextNode], previousSteps <= steps {
                continue
            }
            if queue.contains(where: { $0.node == nextNode } ) {
                continue
            }
            queue.append((nextNode, steps))
        }
        visited[node] = steps
    }

    // No possible path exists
    return nil
}

enum Part1 {
    static func findPossibleCheats(_ racetrack: [Coordinate: Tile]) -> [Coordinate] {
        Array(
            racetrack.filter { key, value in
                guard value == .wall else { return false }
                return (racetrack[key.left] == .empty && racetrack[key.right] == .empty) ||
                (racetrack[key.up] == .empty && racetrack[key.down] == .empty)
            }.keys
        )
    }

    static func run(_ source: InputData) {
        var racetrack = parseGrid(from: source.lines) { Tile(rawValue: $1)! }
        let start = racetrack.first(where: { $0.value == .start })!.key
        let end = racetrack.first(where: { $0.value == .end })!.key
        racetrack[start] = .empty
        racetrack[end] = .empty
        let nonCheatTime = findShortestDistance(from: start) { coord in
            if coord == end { return nil }
            return coord.adjacent.filter { racetrack[$0] != .wall }
        }!
        let cheats = findPossibleCheats(racetrack)
        var timeSaved: [Int: Int] = [:]
        for cheat in cheats {
            racetrack[cheat] = .empty
            let time = findShortestDistance(from: start) { coord in
                if coord == end { return nil }
                return coord.adjacent.filter { racetrack[$0] != .wall }
            }!
            racetrack[cheat] = .wall
            let diff = nonCheatTime - time
            timeSaved[diff, default: 0] += 1
        }
        if source.name == "example" {
            print("Part 1 (\(source)):")
            for key in timeSaved.keys.sorted() {
                print("\(key): \(timeSaved[key]!)")
            }
        } else {
            let total = timeSaved.filter({ $0.key >= 100 }).values.reduce(0, +)
            print("Part 1 (\(source)): \(total)")
        }
    }
}

// MARK: - Part 2

extension Coordinate {
    func distance(to other: Self) -> Int {
        return abs(x - other.x) + abs(y - other.y)
    }
}

enum Part2 {
    static func findPath(from start: Coordinate, to end: Coordinate, racetrack: [Coordinate: Tile]) -> [Coordinate] {
        var path: [Coordinate] = []
        var coord = start
        while coord != end {
            let next = coord.adjacent.filter { racetrack[$0] != .wall && $0 != path.last }.first!
            path.append(coord)
            coord = next
        }
        path.append(end)
        return path
    }

    static func run(_ source: InputData) {
        let cheatTime = 20
        let savedTime = source.name == "challenge" ? 100 : 50

        let racetrack = parseGrid(from: source.lines) { Tile(rawValue: $1)! }
        let start = racetrack.first(where: { $0.value == .start })!.key
        let end = racetrack.first(where: { $0.value == .end })!.key
        let longestPath = findPath(from: start, to: end, racetrack: racetrack)
        var distances: [Coordinate: Int] = [:]
        let longestDistance = longestPath.count - 1
        for (index, tile) in longestPath.enumerated() {
            distances[tile] = longestDistance - index
        }
        var timeSaved: [Int: Int] = [:]
        for (index, tile) in longestPath.enumerated() {
            let cheats = longestPath.filter { $0.distance(to: tile) <= cheatTime }
            for cheat in cheats {
                let cheatDistance = index + distances[cheat]! + cheat.distance(to: tile)
                let diff = longestDistance - cheatDistance
                if diff > 0 {
                    timeSaved[diff, default: 0] += 1
                }
            }
        }
        let total = timeSaved.filter({ $0.key >= savedTime }).values.reduce(0, +)
        print("Part 2 (\(source)): \(total)")
    }
}
