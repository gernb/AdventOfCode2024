//
//  Solution.swift
//  Day 15
//
//  Copyright © 2024 peter bohac. All rights reserved.
//

// MARK: - Part 1

enum Heading: String {
    case left = "<"
    case up = "^"
    case right = ">"
    case down = "v"
}

struct Coordinate: Hashable, CustomStringConvertible {
    var x: Int
    var y: Int

    var description: String { "(\(x), \(y))" }

    var up: Self { .init(x: x, y: y - 1) }
    var down: Self { .init(x: x, y: y + 1) }
    var left: Self { .init(x: x - 1, y: y) }
    var right: Self { .init(x: x + 1, y: y) }

    var gps: Int { x + 100 * y }

    func next(_ heading: Heading) -> Self {
        switch heading {
        case .left: left
        case .up: up
        case .right: right
        case .down: down
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

    func draw(default: Value) {
        let xRange = self.xRange
        let yRange = self.yRange
        for y in yRange {
            for x in xRange {
                let pixel = self[Coordinate(x: x, y: y), default: `default`]
                print(pixel, terminator: "")
            }
            print("")
        }
    }
}

enum Tile: String, CustomStringConvertible {
    case wall = "#"
    case box = "O"
    case robot = "@"
    case empty = "."
    var description: String { rawValue }
}

extension Dictionary where Key == Coordinate, Value == Tile {
    mutating func move(_ tile: Coordinate, direction: Heading) -> Bool {
        let newCoord = tile.next(direction)
        let next = self[newCoord]!
        switch next {
        case .wall:
            return false
        case .empty:
            self[newCoord] = self[tile]!
            self[tile] = .empty
            return true
        case .box:
            if move(newCoord, direction: direction) {
                self[newCoord] = self[tile]!
                self[tile] = .empty
                return true
            } else {
                return false
            }
        case .robot:
            assertionFailure()
            return false
        }
    }
}

enum Part1 {
    static func parseInput(_ lines: [String]) -> (grid: [Coordinate: Tile], robot: Coordinate, moves: [Heading]) {
        let parts = lines.split(separator: "")
        var grid = parseGrid(from: Array(parts[0])) { Tile(rawValue: String($1))! }
        let robot = grid.first { $0.value == .robot }!.key
        grid[robot] = .empty
        let moves = parts[1].joined().map { Heading(rawValue: String($0))! }
        return (grid, robot, moves)
    }

    static func run(_ source: InputData) {
        var (grid, robot, moves) = parseInput(source.lines)
        for move in moves {
            if grid.move(robot, direction: move) {
                robot = robot.next(move)
            }
        }
        let result = grid.filter { $0.value == .box }.keys.map(\.gps).reduce(0, +)
        print("Part 1 (\(source)): \(result)")
    }
}

// MARK: - Part 2

enum Tile2: String, CustomStringConvertible {
    case wall = "#"
    case boxLeft = "["
    case boxRight = "]"
    case robot = "@"
    case empty = "."
    var description: String { rawValue }
}

extension Dictionary where Key == Coordinate, Value == Tile2 {
    func canMove(_ coord: Coordinate, direction: Heading) -> Bool {
        let tile = self[coord]!
        if tile == .robot {
            let ahead = coord.next(direction)
            let tileAhead = self[ahead]!
            switch tileAhead {
            case .wall: return false
            case .empty: return true
            case .boxLeft, .boxRight: return canMove(ahead, direction: direction)
            case .robot:
                assertionFailure()
                return false
            }
        }

        let ahead1: Coordinate
        let ahead2: Coordinate
        let tileAhead1: Tile2
        let tileAhead2: Tile2

        switch (tile, direction) {
        case (.boxLeft, .right), (.boxRight, .left):
            let ahead = coord.next(direction).next(direction)
            let tileAhead = self[ahead]!
            switch tileAhead {
            case .wall: return false
            case .empty: return true
            case .boxLeft, .boxRight: return canMove(ahead, direction: direction)
            case .robot:
                assertionFailure()
                return false
            }
        case (.boxLeft, .up), (.boxLeft, .down):
            ahead1 = coord.next(direction)
            tileAhead1 = self[ahead1]!
            ahead2 = ahead1.next(.right)
            tileAhead2 = self[ahead2]!
        case (.boxRight, .up), (.boxRight, .down):
            ahead1 = coord.next(direction)
            tileAhead1 = self[ahead1]!
            ahead2 = ahead1.next(.left)
            tileAhead2 = self[ahead2]!
        default:
            assertionFailure()
            return false
        }
        switch (tileAhead1, tileAhead2) {
        case (.wall, _), (_, .wall):
            return false
        case (.empty, .empty):
            return true
        case (.boxLeft, .empty), (.boxRight, .empty):
            return canMove(ahead1, direction: direction)
        case (.empty, .boxLeft), (.empty, .boxRight):
            return canMove(ahead2, direction: direction)
        default:
            return canMove(ahead1, direction: direction) && canMove(ahead2, direction: direction)
        }
    }

    @discardableResult
    mutating func move(_ coord: Coordinate, direction: Heading) -> Coordinate {
        guard canMove(coord, direction: direction) else { return coord }
        let tile = self[coord]!
        if tile == .robot {
            let ahead = coord.next(direction)
            let tileAhead = self[ahead]!
            if tileAhead != .empty {
                move(ahead, direction: direction)
            }
            self[ahead] = .robot
            self[coord] = .empty
            return ahead
        }

        let ahead1: Coordinate
        let ahead2: Coordinate
        let tileAhead1: Tile2
        var tileAhead2: Tile2

        switch (tile, direction) {
        case (.boxLeft, .right), (.boxRight, .left):
            let ahead = coord.next(direction).next(direction)
            let tileAhead = self[ahead]!
            if tileAhead != .empty {
                move(ahead, direction: direction)
            }
            self[ahead] = self[coord.next(direction)]
            self[coord.next(direction)] = tile
            self[coord] = .empty
            return ahead
        case (.boxLeft, .up), (.boxLeft, .down):
            ahead1 = coord.next(direction)
            tileAhead1 = self[ahead1]!
            ahead2 = ahead1.next(.right)
            tileAhead2 = self[ahead2]!
        case (.boxRight, .up), (.boxRight, .down):
            ahead1 = coord.next(direction)
            tileAhead1 = self[ahead1]!
            ahead2 = ahead1.next(.left)
            tileAhead2 = self[ahead2]!
        default:
            assertionFailure()
            return coord
        }

        if tileAhead1 != .empty {
            move(ahead1, direction: direction)
            tileAhead2 = self[ahead2]!
        }
        if tileAhead2 != .empty {
            move(ahead2, direction: direction)
        }

        if tile == .boxLeft {
            self[ahead1] = .boxLeft
            self[ahead2] = .boxRight
            self[coord] = .empty
            self[coord.next(.right)] = .empty
        } else {
            assert(tile == .boxRight)
            self[ahead1] = .boxRight
            self[ahead2] = .boxLeft
            self[coord] = .empty
            self[coord.next(.left)] = .empty
        }
        return ahead1
    }
}

enum Part2 {
    static func parseInput(_ lines: [String]) -> (grid: [Coordinate: Tile2], robot: Coordinate, moves: [Heading]) {
        let parts = lines.split(separator: "")
        var gridLines: [String] = []
        for var line in parts[0] {
            line = line.replacingOccurrences(of: "#", with: "##")
            line = line.replacingOccurrences(of: "O", with: "[]")
            line = line.replacingOccurrences(of: ".", with: "..")
            line = line.replacingOccurrences(of: "@", with: "@.")
            gridLines.append(line)
        }
        let grid = parseGrid(from: gridLines) { Tile2(rawValue: String($1))! }
        let robot = grid.first { $0.value == .robot }!.key
        let moves = parts[1].joined().map { Heading(rawValue: String($0))! }
        return (grid, robot, moves)
    }

    static func run(_ source: InputData) {
        var (grid, robot, moves) = parseInput(source.lines)
        for move in moves {
            robot = grid.move(robot, direction: move)
        }
        let result = grid.filter { $0.value == .boxLeft }.keys.map(\.gps).reduce(0, +)
        print("Part 2 (\(source)): \(result)")
    }
}
