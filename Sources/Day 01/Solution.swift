//
//  Solution.swift
//  Day 01
//
//  Copyright © 2024 peter bohac. All rights reserved.
//

import Foundation

// MARK: - Part 1

enum Part1 {
    static func parseInput(_ input: [String]) -> [[Int]] {
        var one: [Int] = []
        var two: [Int] = []
        for line in input {
            let numbers = line
                .components(separatedBy: .whitespaces)
                .compactMap(Int.init)
            assert(numbers.count == 2)
            one.append(numbers[0])
            two.append(numbers[1])
        }
        return [one, two]
    }

    static func run(_ source: InputData) {
        let lists = parseInput(source.lines)
            .map { $0.sorted() }
        assert(lists[0].count == lists[1].count)
        let distances = zip(lists[0], lists[1])
            .map { abs($0.0 - $0.1) }
        let result = distances.reduce(0, +)
        print("Part 1 (\(source)): \(result)")
    }
}

// MARK: - Part 2

enum Part2 {
    static func run(_ source: InputData) {
        let lists = Part1.parseInput(source.lines)
        let list2 = NSCountedSet(array: lists[1])
        let score = lists[0].reduce(0) { $0 + $1 * list2.count(for: $1) }
        print("Part 2 (\(source)): \(score)")
    }
}
