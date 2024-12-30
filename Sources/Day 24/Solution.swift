//
//  Solution.swift
//  Day 24
//
//  Copyright © 2024 peter bohac. All rights reserved.
//

// MARK: - Part 1

enum Value {
    case literal(Bool)
    case gate(a: String, b: String, gate: String)
}

func parse(_ lines: [String]) -> [String: Value] {
    lines.reduce(into: [:]) { result, line in
        if line.contains(":") {
            let wire = line.components(separatedBy: ": ")
            result[wire[0]] = .literal(wire[1] == "1" ? true : false)
        } else if line.contains("->") {
            let wire = line.components(separatedBy: " -> ")
            let gate = wire[0].components(separatedBy: " ")
            result[wire[1]] = .gate(a: gate[0], b: gate[2], gate: gate[1])
        }
    }
}

enum Part1 {
    static func value(for wire: String, wires: inout [String: Value]) -> Int {
        switch wires[wire]! {
        case .literal(let bit):
            return bit ? 1 : 0
        case .gate(let a, let b, let gate):
            let bitA = value(for: a, wires: &wires) == 1
            let bitB = value(for: b, wires: &wires) == 1
            let bit = switch gate {
            case "AND": bitA && bitB
            case "OR": bitA || bitB
            case "XOR": bitA == bitB ? false : true
            default: fatalError()
            }
            wires[wire] = .literal(bit)
            return bit ? 1 : 0
        }
    }

    static func run(_ source: InputData) {
        var wires = parse(source.lines)
        let zWires = wires.keys.filter { $0.hasPrefix("z") }.sorted { $0 > $1 }
        let result = zWires.reduce(0) { result, wire in
            result << 1 | value(for: wire, wires: &wires)
        }
        print("Part 1 (\(source)): \(result)")
    }
}

// MARK: - Part 2

enum Part2 {
    static func run(_ source: InputData) {
        let wires = parse(source.lines)
        var bad: Set<String> = []

        for (output1, value1) in wires {
            guard case let .gate(a1, b1, gate1) = value1 else { continue }
            if output1.hasPrefix("z") && gate1 != "XOR" && output1 != "z45" {
                bad.insert(output1)
            }
            if gate1 == "XOR" &&
                ["x","y","z"].contains(output1.first!) == false &&
                ["x","y","z"].contains(a1.first!) == false &&
                ["x","y","z"].contains(b1.first!) == false {
                bad.insert(output1)
            }
            if gate1 == "AND" && [a1, b1].contains("x00") == false {
                for (_, value2) in wires {
                    guard case let .gate(a2, b2, gate2) = value2 else { continue }
                    if [a2, b2].contains(output1) && gate2 != "OR" {
                        bad.insert(output1)
                    }
                }
            }
            if gate1 == "XOR" {
                for (_, value2) in wires {
                    guard case let .gate(a2, b2, gate2) = value2 else { continue }
                    if [a2, b2].contains(output1) && gate2 == "OR" {
                        bad.insert(output1)
                    }
                }
            }
        }

        let result = bad.sorted().joined(separator: ",")
        print("Part 2 (\(source)): \(result)")
    }
}
