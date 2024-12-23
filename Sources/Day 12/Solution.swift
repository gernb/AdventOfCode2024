//
//  Solution.swift
//  Day 12
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

enum Part1 {
    static func findPlot(plant: Character, start: Coordinate, gardenMap: [Coordinate: Character]) -> (area: Int, perimeter: Int, coords: Set<Coordinate>) {
        var area = 0
        var perimeter = 0
        var coords: Set<Coordinate> = []
        var queue: Set<Coordinate> = [start]
        while let c = queue.popFirst() {
            area += 1
            coords.insert(c)
            for neighbor in c.adjacent {
                if gardenMap[neighbor] == plant {
                    if coords.contains(neighbor) == false {
                        queue.insert(neighbor)
                    }
                } else {
                    perimeter += 1
                }
            }
        }
        return (area, perimeter, coords)
    }

    static func run(_ source: InputData) {
        var gardenMap = parseMap(from: source.lines) { $1 }
        var cost = 0
        while let (coord, plant) = gardenMap.first {
            let (area, perimeter, coords) = findPlot(plant: plant, start: coord, gardenMap: gardenMap)
            for c in coords { gardenMap[c] = nil }
            let price = area * perimeter
            cost += price
        }
        print("Part 1 (\(source)): \(cost)")
    }
}

// MARK: - Part 2

enum Direction {
    case left, up, right, down
}
struct Side: Hashable {
    let location: Coordinate
    let direction: Direction
}

enum Part2 {
    static func sides(plot: Set<Coordinate>) -> Int {
        var sides: Set<Side> = []
        for c in plot {
            if plot.contains(c.left) == false {
                sides.insert(Side(location: c, direction: .left))
            }
            if plot.contains(c.up) == false {
                sides.insert(Side(location: c, direction: .up))
            }
            if plot.contains(c.right) == false {
                sides.insert(Side(location: c, direction: .right))
            }
            if plot.contains(c.down) == false {
                sides.insert(Side(location: c, direction: .down))
            }
        }
        var count = 0
        while let side = sides.popFirst() {
            count += 1
            switch side.direction {
            case .left, .right:
                var up = side.location.up
                while let next = sides.first(where: { $0 == .init(location: up, direction: side.direction) }) {
                    sides.remove(next)
                    up = next.location.up
                }
                var down = side.location.down
                while let next = sides.first(where: { $0 == .init(location: down, direction: side.direction) }) {
                    sides.remove(next)
                    down = next.location.down
                }
            case .up, .down:
                var left = side.location.left
                while let next = sides.first(where: { $0 == .init(location: left, direction: side.direction) }) {
                    sides.remove(next)
                    left = next.location.left
                }
                var right = side.location.right
                while let next = sides.first(where: { $0 == .init(location: right, direction: side.direction) }) {
                    sides.remove(next)
                    right = next.location.right
                }
            }
        }
        return count
    }

    static func run(_ source: InputData) {
        var gardenMap = parseMap(from: source.lines) { $1 }
        var cost = 0
        while let (coord, plant) = gardenMap.first {
            let (area, _, coords) = Part1.findPlot(plant: plant, start: coord, gardenMap: gardenMap)
            let sides = sides(plot: coords)
            for c in coords { gardenMap[c] = nil }
            let price = area * sides
            cost += price
        }
        print("Part 2 (\(source)): \(cost)")
    }
}
