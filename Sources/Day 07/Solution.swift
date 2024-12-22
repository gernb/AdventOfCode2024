//
//  Solution.swift
//  Day 07
//
//  Copyright © 2024 peter bohac. All rights reserved.
//

// MARK: - Part 1

struct Equation {
    typealias Operation = @Sendable (Int, Int) -> Int
    let testValue: Int
    let numbers: [Int]
    func solve(using operations: [Operation]) -> Int {
        zip(operations, numbers.dropFirst()).reduce(numbers[0]) { result, pair in
            pair.0(result, pair.1)
        }
    }
}
extension Equation {
    init(_ line: String) {
        let parts = line.components(separatedBy: ":")
        let testValue = Int(parts[0])!
        let numbers = parts[1].trimmingCharacters(in: .whitespaces)
            .components(separatedBy: " ")
            .compactMap(Int.init)
        self.init(testValue: testValue, numbers: numbers)
    }
}

final class CustomSequence<T>: Sequence, IteratorProtocol {
    let source: [T]
    let length: Int
    private var index: Int
    private var subiterator: CustomSequence<T>?
    init(source: [T], length: Int) {
        self.source = source
        self.length = length
        self.index = 0
        if length > 0 {
            self.subiterator = CustomSequence(source: source, length: length - 1)
        }
    }
    func next() -> [T]? {
        guard length > 0 else {
            defer { index += 1 }
            return index == 0 ? [] : nil
        }
        guard index < source.count else {
            return nil
        }
        if let subarray = subiterator?.next() {
            return [source[index]] + subarray
        } else {
            index += 1
            subiterator = CustomSequence(source: source, length: length - 1)
            return next()
        }
    }
}
func generateCombinations<T>(from source: [T], ofLength length: Int) -> CustomSequence<T> {
    CustomSequence(source: source, length: length)
}

enum Part1 {
    static let operations: [Equation.Operation] = [
        { $0 + $1 },
        { $0 * $1 },
    ]

    static func run(_ source: InputData) {
        let equations = source.lines.map(Equation.init)
        let trueEquations = equations.filter { equation in
            for solution in generateCombinations(from: operations, ofLength: equation.numbers.count - 1) {
                if equation.solve(using: solution) == equation.testValue {
                    return true
                }
            }
            return false
        }
        let result = trueEquations.map(\.testValue).reduce(0, +)
        print("Part 1 (\(source)): \(result)")
    }
}

// MARK: - Part 2

enum Part2 {
    static let operations: [Equation.Operation] = [
        { $0 + $1 },
        { $0 * $1 },
        { Int("\($0)\($1)")! },
    ]

    static func run(_ source: InputData) {
        let equations = source.lines.map(Equation.init)
        let trueEquations = equations.filter { equation in
            for solution in generateCombinations(from: operations, ofLength: equation.numbers.count - 1) {
                if equation.solve(using: solution) == equation.testValue {
                    return true
                }
            }
            return false
        }
        let result = trueEquations.map(\.testValue).reduce(0, +)
        print("Part 2 (\(source)): \(result)")
    }
}
