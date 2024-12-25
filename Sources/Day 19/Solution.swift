//
//  Solution.swift
//  Day 19
//
//  Copyright © 2024 peter bohac. All rights reserved.
//

// MARK: - Part 1

enum Part1 {
    static func parse(_ lines: [String]) -> (towels: [String], designs: [String]) {
        let towels = lines[0].components(separatedBy: ", ")
        let designs = Array(lines.dropFirst(2))
        return (towels, designs)
    }

    nonisolated(unsafe) static var memoized: [String: Bool] = ["": true]
    static func isPossible(_ design: String, towels: [String]) -> Bool {
        if let memoized = memoized[design] {
            return memoized
        }
        for towel in towels where design.hasPrefix(towel) {
            let partial = String(design.dropFirst(towel.count))
            if isPossible(partial, towels: towels) {
                memoized[design] = true
                return true
            }
        }
        memoized[design] = false
        return false
    }

    static func run(_ source: InputData) {
        memoized = ["": true]
        let (towels, designs) = parse(source.lines)
        let possible = designs.reduce(into: 0) { result, design in
            if isPossible(design, towels: towels) {
                result += 1
            }
        }
        print("Part 1 (\(source)): \(possible)")
    }
}

// MARK: - Part 2

enum Part2 {
    nonisolated(unsafe) static var memoized: [String: Int] = ["": 1]
    static func combinations(for design: String, towels: [String]) -> Int {
        if let memoized = memoized[design] {
            return memoized
        }
        var count = 0
        for towel in towels where design.hasPrefix(towel) {
            let partial = String(design.dropFirst(towel.count))
            count += combinations(for: partial, towels: towels)
        }
        memoized[design] = count
        return count
    }

    static func run(_ source: InputData) {
        memoized = ["": 1]
        let (towels, designs) = Part1.parse(source.lines)
        let count = designs.reduce(into: 0) { result, design in
            result += combinations(for: design, towels: towels)
        }
        print("Part 2 (\(source)): \(count)")
    }
}
