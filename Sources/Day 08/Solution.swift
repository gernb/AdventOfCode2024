//
//  Solution.swift
//  Day 08
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
    var upLeft: Self { .init(x: x - 1, y: y - 1) }
    var upRight: Self { .init(x: x + 1, y: y - 1) }
    var downLeft: Self { .init(x: x - 1, y: y + 1) }
    var downRight: Self { .init(x: x + 1, y: y + 1) }

    func plus(x: Int, y: Int) -> Self {
        .init(x: self.x + x, y: self.y + y)
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

struct Antenna {
    let frequency: Character
    let location: Coordinate
    func antinodes(with other: Antenna) -> [Coordinate] {
        guard frequency == other.frequency else {
            assertionFailure()
            return []
        }
        let xDiff = other.location.x - location.x
        let yDiff = other.location.y - location.y
        return [
            location.plus(x: -xDiff, y: -yDiff),
            other.location.plus(x: xDiff, y: yDiff),
        ]
    }
}

extension Dictionary where Key == Coordinate, Value == Character {
    var antennas: [Character: [Antenna]] {
        let allAntennas = filter { $0.value != "." }.map { Antenna(frequency: $0.value, location: $0.key) }
        return .init(grouping: allAntennas) { $0.frequency }
    }
}

struct CustomSequence<T>: Sequence, IteratorProtocol {
    let source: [T]
    private var index1: Int
    private var index2: Int
    init(_ source: [T]) {
        self.source = source
        self.index1 = 0
        self.index2 = 1
    }
    mutating func next() -> (T, T)? {
        guard index1 < source.count else { return nil }
        guard index2 < source.count else {
            index1 += 1
            index2 = index1 + 1
            return next()
        }
        defer { index2 += 1 }
        return (source[index1], source[index2])
    }
}
extension Array {
    func pairs() -> CustomSequence<Element> {
        .init(self)
    }
}

enum Part1 {
    static func run(_ source: InputData) {
        let map = parseMap(from: source.lines) { $1 }
        var antinodes: Set<Coordinate> = []
        for antennas in map.antennas.values {
            for pair in antennas.pairs() {
                let nodes = pair.0.antinodes(with: pair.1).filter { map.keys.contains($0) }
                antinodes.formUnion(nodes)
            }
        }
        print("Part 1 (\(source)): \(antinodes.count)")
    }
}

// MARK: - Part 2

enum Part2 {
    static func run(_ source: InputData) {
        let map = parseMap(from: source.lines) { $1 }
        var antinodes: Set<Coordinate> = []
        for antennas in map.antennas.values {
            var antennaCount: [Coordinate: Int] = [:]
            for (a1, a2) in antennas.pairs() {
                antennaCount[a1.location, default: 0] += 1
                antennaCount[a2.location, default: 0] += 1
                let xDiff = a2.location.x - a1.location.x
                let yDiff = a2.location.y - a1.location.y
                var loc = a2.location.plus(x: xDiff, y: yDiff)
                while map.keys.contains(loc) {
                    antennaCount[loc, default: 0] += 2
                    loc = loc.plus(x: xDiff, y: yDiff)
                }
                loc = a1.location.plus(x: -xDiff, y: -yDiff)
                while map.keys.contains(loc) {
                    antennaCount[loc, default: 0] += 2
                    loc = loc.plus(x: -xDiff, y: -yDiff)
                }
            }
            let nodes = antennaCount.filter { $0.value >= 2 }.keys
            antinodes.formUnion(nodes)
        }
        print("Part 2 (\(source)): \(antinodes.count)")
    }
}
