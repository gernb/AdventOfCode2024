//
//  Solution.swift
//  Day 14
//
//  Copyright © 2024 peter bohac. All rights reserved.
//

// MARK: - Part 1

struct Pair: Hashable {
    var x: Int
    var y: Int
}
struct Robot {
    var position: Pair
    let velocity: Pair

    mutating func move(in area: Pair) {
        position.x = (position.x + velocity.x) % area.x
        position.y = (position.y + velocity.y) % area.y
        if position.x < 0 { position.x += area.x }
        if position.y < 0 { position.y += area.y }
    }
}
extension Robot {
    init(_ line: String) {
        let numbers = line.components(separatedBy: " ")
            .flatMap { $0.components(separatedBy: "=") }
            .flatMap { $0.components(separatedBy: ",") }
            .compactMap(Int.init)
        self.init(
            position: .init(x: numbers[0], y: numbers[1]),
            velocity: .init(x: numbers[2], y: numbers[3])
        )
    }
}
struct Quad: Hashable {
    let xRange: Range<Int>
    let yRange: Range<Int>
    func contains(_ point: Pair) -> Bool {
        xRange.contains(point.x) && yRange.contains(point.y)
    }
}

enum Part1 {
    static func run(_ source: InputData) {
        let area = Pair(x: source.size.width, y: source.size.height)
        var robots = source.lines.map(Robot.init)
        for _ in 1 ... 100 {
            for (index, _) in robots.enumerated() {
                robots[index].move(in: area)
            }
        }
        let halfX = area.x / 2
        let halfY = area.y / 2
        var quads = [
            Quad(xRange: 0..<halfX, yRange: 0..<halfY): 0,
            Quad(xRange: halfX+1..<area.x, yRange: 0..<halfY): 0,
            Quad(xRange: 0..<halfX, yRange: halfY+1..<area.y): 0,
            Quad(xRange: halfX+1..<area.x, yRange: halfY+1..<area.y): 0,
        ]
        for robot in robots {
            for quad in quads.keys where quad.contains(robot.position) {
                quads[quad]! += 1
            }
        }
        let safetyFactor = quads.values.reduce(1, *)
        print("Part 1 (\(source)): \(safetyFactor)")
    }
}

// MARK: - Part 2

extension Collection where Element: Comparable {
    func range() -> ClosedRange<Element> {
        precondition(count > 0)
        let sorted = self.sorted()
        return sorted.first! ... sorted.last!
    }
}
extension Dictionary where Key == Pair {
    var xRange: ClosedRange<Int> { keys.map { $0.x }.range() }
    var yRange: ClosedRange<Int> { keys.map { $0.y }.range() }

    func draw(default: Value) {
        let xRange = self.xRange
        let yRange = self.yRange
        for y in yRange {
            for x in xRange {
                let pixel = self[Pair(x: x, y: y), default: `default`]
                print(pixel, terminator: "")
            }
            print("")
        }
    }
}

enum Part2 {
    static func run(_ source: InputData) {
        let area = Pair(x: source.size.width, y: source.size.height)
        var robots = source.lines.map(Robot.init)
        var seconds = 0
        var image: [Pair: String] = [:]
        while true {
            for (index, _) in robots.enumerated() {
                robots[index].move(in: area)
            }
            seconds += 1
            image = robots.map(\.position).reduce(into: [:]) { result, coord in
                result[coord] = "*"
            }
            if image.count == robots.count {
                break
            }
        }
        print("Part 2 (\(source)): \(seconds)")
        image.draw(default: " ")
    }
}
