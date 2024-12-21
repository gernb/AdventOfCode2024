//
//  Solution.swift
//  Day 06
//
//  Copyright © 2024 peter bohac. All rights reserved.
//

// MARK: - Part 1

enum Direction {
    case left, up, right, down

    func turnRight() -> Direction {
        switch self {
        case .left: return .up
        case .up: return .right
        case .right: return .down
        case .down: return .left
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

    func next(_ direction: Direction) -> Self {
        switch direction {
        case .up: return up
        case .down: return down
        case .left: return left
        case .right: return right
        }
    }

    mutating func move(_ direction: Direction) {
        self = next(direction)
    }
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

enum Tile: Character {
    case empty = "."
    case obstruction = "#"
    case `guard` = "^"
}

enum Part1 {
    static func run(_ source: InputData) {
        var lab = parseMap(from: source.lines) { Tile(rawValue: $1)! }
        var guardHeading: Direction = .up
        var guardLoc = lab.first(where: { $0.value == .guard })!.key
        var allGuardLocs: Set<Coordinate> = [guardLoc]
        lab[guardLoc] = .empty
        while let tile = lab[guardLoc.next(guardHeading)] {
            switch tile {
            case .empty:
                guardLoc.move(guardHeading)
                allGuardLocs.insert(guardLoc)
            case .obstruction:
                guardHeading = guardHeading.turnRight()
            case .guard:
                assertionFailure()
            }
        }
        print("Part 1 (\(source)): \(allGuardLocs.count)")
    }
}

// MARK: - Part 2

struct PathStep: Hashable {
    let direction: Direction
    let location: Coordinate
}

enum Part2 {
    static func findPath(in lab: [Coordinate: Tile], from start: PathStep) -> (path: Set<PathStep>, isLoop: Bool) {
        var heading: Direction = start.direction
        var loc = start.location
        var path: Set<PathStep> = [start]
        while let tile = lab[loc.next(heading)] {
            let nextStep = PathStep(direction: heading, location: loc.next(heading))
            guard path.contains(nextStep) == false else {
                return (path, true)
            }
            switch tile {
            case .empty:
                loc.move(heading)
                path.insert(.init(direction: heading, location: loc))
            case .obstruction:
                heading = heading.turnRight()
            case .guard:
                assertionFailure()
            }
        }
        return (path, false)
    }

    static func run(_ source: InputData) {
        var lab = parseMap(from: source.lines) { Tile(rawValue: $1)! }
        let guardStart = lab.first(where: { $0.value == .guard })!.key
        lab[guardStart] = .empty
        let start = PathStep(direction: .up, location: guardStart)
        let originalPath = findPath(in: lab, from: start).path
        var obstructionsForLoop: Set<Coordinate> = []
        for step in originalPath where step.location != guardStart && obstructionsForLoop.contains(step.location) == false {
            lab[step.location] = .obstruction
            if findPath(in: lab, from: start).isLoop {
                obstructionsForLoop.insert(step.location)
            }
            lab[step.location] = .empty
        }
        print("Part 2 (\(source)): \(obstructionsForLoop.count)")
    }
}
