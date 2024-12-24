//
//  Solution.swift
//  Day 16
//
//  Copyright © 2024 peter bohac. All rights reserved.
//

// MARK: - Part 1

enum Heading: CaseIterable {
    case west, north, east, south

    var left: Self {
        switch self {
        case .west: return .south
        case .north: return .west
        case .east: return .north
        case .south: return .east
        }
    }

    var right: Self {
        switch self {
        case .west: return .north
        case .north: return .east
        case .east: return .south
        case .south: return .west
        }
    }
}

struct Coordinate: Hashable, CustomStringConvertible {
    var x: Int
    var y: Int

    var description: String { "(\(x), \(y))" }

    var up: Self { .init(x: x, y: y - 1) }
    var down: Self { .init(x: x, y: y + 1) }
    var left: Self { .init(x: x - 1, y: y) }
    var right: Self { .init(x: x + 1, y: y) }

    var adjacent: [Self] { [up, left, right, down] }

    func next(_ heading: Heading) -> Self {
        switch heading {
        case .west: left
        case .north: up
        case .east: right
        case .south: down
        }
    }
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

func findShortestDistance<Node: Hashable>(from start: Node, using getNextNodes: ((Node) -> [(node: Node, cost: Int)]?)) -> Int? {
    var visited: [Node: Int] = [:]
    var queue: [Node: Int] = [start: 0]

    while let (node, currentCost) = queue.min(by: { $0.value < $1.value }) {
        queue.removeValue(forKey: node)
        guard let nextNodes = getNextNodes(node) else {
            return currentCost
        }
        for (nextNode, cost) in nextNodes {
            let newCost = currentCost + cost
            if let previousCost = visited[nextNode], previousCost <= newCost {
                continue
            }
            if let queuedCost = queue[nextNode], queuedCost <= newCost {
                continue
            }
            queue[nextNode] = newCost
        }
        visited[node] = currentCost
    }

    // No possible path exists
    return nil
}

struct Location: Hashable {
    let coord: Coordinate
    let heading: Heading
}

enum Part1 {
    static func run(_ source: InputData) {
        let maze = parseGrid(from: source.lines) { Tile(rawValue: $1)! }
        let start = maze.first(where: { $0.value == .start })!.key
        let score = findShortestDistance(from: Location(coord: start, heading: .east)) { loc in
            if maze[loc.coord] == .end { return nil }
            let left = loc.heading.left
            let right = loc.heading.right
            return [
                (Location(coord: loc.coord.next(loc.heading), heading: loc.heading), 1),
                (Location(coord: loc.coord.next(left), heading: left), 1001),
                (Location(coord: loc.coord.next(right), heading: right), 1001),
            ]
            .filter { maze[$0.node.coord] != .wall }
        }
        print("Part 1 (\(source)): \(score!)")
    }
}

// MARK: - Part 2

final class Path {
    var score: Int
    var tiles: [Coordinate]
    var heading: Heading

    init(score: Int = 0, tiles: [Coordinate], heading: Heading = .east) {
        self.score = score
        self.tiles = tiles
        self.heading = heading
    }

    func duplicate() -> Path {
        .init(score: score, tiles: tiles, heading: heading)
    }
}

enum Part2 {
    static func run(_ source: InputData) {
        let maze = parseGrid(from: source.lines) { Tile(rawValue: $1)! }
        let start = maze.first(where: { $0.value == .start })!.key
        let end = maze.first(where: { $0.value == .end })!.key
        var tileScores: [Coordinate: Int] = [start: 0]
        var paths: [Int: [Path]] = [:]
        var queue = [Path(tiles: [start])]
        while let path = queue.popLast() {
            var coord = path.tiles.last!
            let heading = path.heading
            while true {
                var next = coord.next(heading.left)
                if maze[next] != .wall && path.tiles.contains(next) == false && path.score + 1000 <= tileScores[next, default: .max] {
                    let newPath = path.duplicate()
                    newPath.score += 1000
                    newPath.heading = heading.left
                    queue.append(newPath)
                }
                next = coord.next(heading.right)
                if maze[next] != .wall && path.tiles.contains(next) == false && path.score + 1000 <= tileScores[next, default: .max] {
                    let newPath = path.duplicate()
                    newPath.score += 1000
                    newPath.heading = heading.right
                    queue.append(newPath)
                }
                next = coord.next(path.heading)
                if maze[next] == .wall || path.tiles.contains(next) {
                    break
                }
                coord = next
                tileScores[coord] = path.score
                path.tiles.append(coord)
                path.score += 1
                if coord == end {
                    paths[path.score, default: []].append(path)
                    break
                }
            }
        }
        let bestScore = paths.keys.min()!
        let tiles: Set<Coordinate> = paths[bestScore]!.map(\.tiles).reduce(into: []) { $0.formUnion($1) }
        print("Part 2 (\(source)): \(tiles.count)")
    }
}
