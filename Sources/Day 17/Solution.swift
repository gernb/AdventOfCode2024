//
//  Solution.swift
//  Day 17
//
//  Copyright © 2024 peter bohac. All rights reserved.
//

// MARK: - Part 1

final class Computer {
    var regA: Int
    var regB: Int
    var regC: Int
    var ip: Int
    var output: [Int]
    let program: [Int]

    init(regA: Int = 0, regB: Int = 0, regC: Int = 0, program: [Int]) {
        self.regA = regA
        self.regB = regB
        self.regC = regC
        self.ip = 0
        self.output = []
        self.program = program
    }

    func run() -> [Int] {
        output = []
        ip = 0
        while ip < program.count {
            execute(opcode: program[ip], operand: program[ip + 1])
        }
        return output
    }

    private func execute(opcode: Int, operand: Int) {
        switch opcode {
        case 0: // adv: division
            let result = regA / (2 << (value(for: operand) - 1))
            regA = result
            ip += 2
        case 1: // bxl: bitwise XOR
            let result = regB ^ operand
            regB = result
            ip += 2
        case 2: // bst: modulo 8
            let result = value(for: operand) % 8
            regB = result
            ip += 2
        case 3: // jnz: jump
            if regA != 0 {
                ip = operand
            } else {
                ip += 2
            }
        case 4: // bxc: bitwise XOR
            let result = regB ^ regC
            regB = result
            ip += 2
        case 5: // out: output
            let result = value(for: operand) % 8
            output.append(result)
            ip += 2
        case 6: // bdv: division
            let result = regA / (2 << (value(for: operand) - 1))
            regB = result
            ip += 2
        case 7: // cdv: division
            let result = regA / (2 << (value(for: operand) - 1))
            regC = result
            ip += 2
        default:
            fatalError()
        }
    }

    private func value(for operand: Int) -> Int {
        switch operand {
        case 0: 0
        case 1: 1
        case 2: 2
        case 3: 3
        case 4: regA
        case 5: regB
        case 6: regC
        default: fatalError()
        }
    }
}
extension Computer {
    convenience init(_ lines: [String]) {
        let a = Int(lines[0].components(separatedBy: ": ")[1])!
        let b = Int(lines[1].components(separatedBy: ": ")[1])!
        let c = Int(lines[2].components(separatedBy: ": ")[1])!
        let program = lines.last!.components(separatedBy: ": ")[1]
            .components(separatedBy: ",")
            .compactMap(Int.init)
        self.init(regA: a, regB: b, regC: c, program: program)
    }
}

enum Part1 {
    static func run(_ source: InputData) {
        let computer = Computer(source.lines)
        let result = computer.run().map(String.init).joined(separator: ",")
        print("Part 1 (\(source)): \(result)")
    }
}

// MARK: - Part 2

extension Computer {
    func run(a: Int, b: Int, c: Int) -> [Int] {
        regA = a
        regB = b
        regC = c
        return run()
    }
}

enum Part2 {
    static func run(_ source: InputData) {
        let computer = Computer(source.lines)
        let regB = computer.regB
        let regC = computer.regC
        let result = computer.program
            .reversed()
            .reduce([0]) { candidates, instruction in
                candidates.flatMap {
                    let shifted = $0 << 3
                    return (shifted ..< shifted + 8).compactMap { regA in
                        computer.run(a: regA, b: regB, c: regC).first! == instruction ? regA : nil
                    }
                }
            }
            .first!
        print("Part 2 (\(source)): \(result)")
    }
}
