//
//  Solution.swift
//  Day 11
//
//  Copyright © 2024 peter bohac. All rights reserved.
//

import Foundation

// MARK: - Part 1

final class Stone {
    var number: Int
    var next: Stone?

    init(_ number: Int) {
        self.number = number
    }

    func count() -> Int {
        var current: Stone? = self
        var count: Int = 0
        while current != nil {
            count += 1
            current = current!.next
        }
        return count
    }

    func change() {
        var current: Stone? = self
        while current != nil {
            let number = current!.number
            if number == 0 {
                current!.number = 1
            } else if "\(number)".count.isMultiple(of: 2) {
                let count = "\(number)".count / 2
                let powerOf10 = Int(pow(10, Double(count)))
                let first = number / powerOf10
                let second = number % powerOf10
                let stone = Stone(second)
                stone.next = current!.next
                current!.number = first
                current!.next = stone
                current = stone
            } else {
                current!.number = number * 2024
            }
            current = current?.next
        }
    }
}
extension Stone {
    convenience init(_ input: String) {
        let values = input.components(separatedBy: .whitespaces).compactMap(Int.init)
        self.init(values[0])
        var current = self
        for value in values.dropFirst() {
            let stone = Stone(value)
            current.next = stone
            current = stone
        }
    }
}
extension Stone: CustomStringConvertible {
    var description: String {
        var values: [String] = []
        var current: Stone? = self
        repeat {
            values.append(String(current!.number))
            current = current?.next
        } while current != nil
        return values.joined(separator: " ")
    }
}

enum Part1 {
    static func run(_ source: InputData) {
        let firstStone = Stone(source.lines[0])
        for _ in 1 ... 25 {
            firstStone.change()
        }
        print("Part 1 (\(source)): \(firstStone.count())")
    }
}

// MARK: - Part 2

enum Part2 {
    static func run(_ source: InputData) {
        var stones: [Int: Int] = [:]
        for number in source.lines[0].components(separatedBy: .whitespaces).compactMap(Int.init) {
            stones[number, default: 0] += 1
        }
        for _ in 1 ... 75 {
            var newStones: [Int: Int] = [:]
            for (number, count) in stones {
                if number == 0 {
                    newStones[1, default: 0] += count
                } else if "\(number)".count.isMultiple(of: 2) {
                    let powerOf10 = Int(pow(10, Double("\(number)".count / 2)))
                    let first = number / powerOf10
                    let second = number % powerOf10
                    newStones[first, default: 0] += count
                    newStones[second, default: 0] += count
                } else {
                    newStones[number * 2024, default: 0] += count
                }
            }
            stones = newStones
        }
        let result = stones.values.reduce(0, +)
        print("Part 2 (\(source)): \(result)")
    }
}
