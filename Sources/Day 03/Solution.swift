//
//  Solution.swift
//  Day 03
//
//  Copyright © 2024 peter bohac. All rights reserved.
//

// MARK: - Part 1

enum Part1 {
    static func execute(_ mul: any StringProtocol) -> Int {
        let values = mul.dropFirst(4).dropLast()
            .split(separator: ",")
            .compactMap { Int(String($0)) }
        return values[0] * values[1]
    }

    static func run(_ source: InputData) {
        let memory = source.lines.joined()
        let mulInstruction = try! Regex(#"mul\(\d{1,3},\d{1,3}\)"#)
        let result = memory.ranges(of: mulInstruction)
            .map { execute(memory[$0]) }
            .reduce(0, +)
        print("Part 1 (\(source)): \(result)")
    }
}

// MARK: - Part 2

enum Part2 {
    static func run(_ source: InputData) {
        let memory = source.lines.joined()
        let mulInstruction = try! Regex(#"mul\(\d{1,3},\d{1,3}\)"#)
        let doInstruction = try! Regex(#"do\(\)"#)
        let dontInstruction = try! Regex(#"don't\(\)"#)
        let multiplies = memory.ranges(of: mulInstruction)
        let enables = memory.ranges(of: doInstruction)
        let disables = memory.ranges(of: dontInstruction)
        let instructions = (multiplies + enables + disables)
            .sorted(by: { $0.lowerBound < $1.lowerBound })
            .map { memory[$0] }
        var sum = 0
        var enabled = true
        for instruction in instructions {
            switch instruction.prefix(3) {
            case "do(": enabled = true
            case "don": enabled = false
            case "mul": sum += enabled ? Part1.execute(instruction) : 0
            default: assertionFailure()
            }
        }
        print("Part 2 (\(source)): \(sum)")
    }
}
