//
//  Solution.swift
//  Day 18
//
//  Copyright © 2024 peter bohac. All rights reserved.
//

// MARK: - Part 1

struct Coordinate: Hashable, CustomStringConvertible {
    var x: Int
    var y: Int

    static let origin: Self = .init(x: 0, y: 0)

    var description: String { "(\(x), \(y))" }

    var up: Self { .init(x: x, y: y - 1) }
    var down: Self { .init(x: x, y: y + 1) }
    var left: Self { .init(x: x - 1, y: y) }
    var right: Self { .init(x: x + 1, y: y) }

    var adjacent: [Self] { [up, left, right, down] }
}
extension Coordinate {
    init(_ line: String) {
        let numbers = line.components(separatedBy: ",").compactMap(Int.init)
        self.init(x: numbers[0], y: numbers[1])
    }
}

enum Tile {
    case empty, corrupted
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
    static func createMemorySpace(_ source: InputData) -> [Coordinate: Tile] {
        var memory: [Coordinate: Tile] = [:]
        for x in 0 ... source.exit.x {
            for y in 0 ... source.exit.y {
                memory[Coordinate(x: x, y: y)] = .empty
            }
        }
        for index in 0 ..< source.bytes {
            let coord = Coordinate(source.lines[index])
            memory[coord] = .corrupted
        }
        return memory
    }

    static func run(_ source: InputData) {
        let memory = createMemorySpace(source)
        let exit = Coordinate(x: source.exit.x, y: source.exit.y)
        let steps = findShortestDistance(from: Coordinate.origin) { node in
            if node == exit { return nil }
            return node.adjacent.filter { memory[$0] == .empty }
        }!
        print("Part 1 (\(source)): \(steps)")
    }
}

// MARK: - Part 2

enum Part2 {
    static func run(_ source: InputData) {
        var memory = Part1.createMemorySpace(source)
        let exit = Coordinate(x: source.exit.x, y: source.exit.y)
        for index in source.bytes ..< source.lines.count {
            let coord = Coordinate(source.lines[index])
            memory[coord] = .corrupted
            let steps = findShortestDistance(from: Coordinate.origin) { node in
                if node == exit { return nil }
                return node.adjacent.filter { memory[$0] == .empty }
            }
            if steps == nil {
                print("Part 2 (\(source)): \(source.lines[index])")
                return
            }
        }
        print("Part 2 (\(source)): FAILED")
    }
}
