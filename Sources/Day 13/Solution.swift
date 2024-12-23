//
//  Solution.swift
//  Day 13
//
//  Copyright © 2024 peter bohac. All rights reserved.
//

// MARK: - Part 1

struct Point {
    var x: Int
    var y: Int
}
struct ClawMachine {
    let a: Point
    let b: Point
    var prize: Point

    /*
     N*Ax + M*Bx = Px
     N = (Px - M*Bx)/Ax
     M = (Px - N*Ax)/Bx

     N*Ay + M*By = Py
     N = (Py - M*By)/Ay
     M = (Py - N*Ay)/By

     (Px - M*Bx)/Ax = (Py - M*By)/Ay
     Px/Ax - M*Bx/Ax = Py/Ay - M*By/Ay
     M*By/Ay - M*Bx/Ax = Py/Ay - Px/Ax
     M(By/Ay - Bx/Ax) = Py/Ay - Px/Ax
     M = (Py/Ay - Px/Ax)/(By/Ay - Bx/Ax)
     */
    func solve(maxPresses: Int = 100) -> (a: Int, b: Int)? {
        // M = (Py/Ay - Px/Ax)/(By/Ay - Bx/Ax)
        let Ax = Double(a.x)
        let Ay = Double(a.y)
        let Bx = Double(b.x)
        let By = Double(b.y)
        let Px = Double(prize.x)
        let Py = Double(prize.y)
        let M = (Py / Ay - Px / Ax) / (By / Ay - Bx / Ax)
        // N = (Px - M*Bx)/Ax
        let N = (Px - M * Bx) / Ax
        let buttonA = Int(N.rounded())
        let buttonB = Int(M.rounded())
        if buttonA <= maxPresses && buttonB <= maxPresses &&
            buttonA * a.x + buttonB * b.x == prize.x &&
            buttonA * a.y + buttonB * b.y == prize.y {
            return (buttonA, buttonB)
        } else {
            return nil
        }
    }
}
extension ClawMachine {
    init(_ lines: [String]) {
        let number = try! Regex(#"\d+"#)
        var values = lines[0].ranges(of: number)
            .map { Int(lines[0][$0])! }
        let a = Point(x: values[0], y: values[1])
        values = lines[1].ranges(of: number)
            .map { Int(lines[1][$0])! }
        let b = Point(x: values[0], y: values[1])
        values = lines[2].ranges(of: number)
            .map { Int(lines[2][$0])! }
        let prize = Point(x: values[0], y: values[1])
        self.init(a: a, b: b, prize: prize)
    }
    static func parse(_ lines: [String]) -> [ClawMachine] {
        lines.split(separator: "").map { ClawMachine(Array($0)) }
    }
}

enum Part1 {
    static func run(_ source: InputData) {
        let machines = ClawMachine.parse(source.lines)
        var tokens = 0
        for machine in machines {
            if let presses = machine.solve() {
                tokens += 3 * presses.a + presses.b
            }
        }
        print("Part 1 (\(source)): \(tokens)")
    }
}

// MARK: - Part 2

enum Part2 {
    static func run(_ source: InputData) {
        let machines = ClawMachine.parse(source.lines)
        var tokens = 0
        for var machine in machines {
            machine.prize.x += 10_000_000_000_000
            machine.prize.y += 10_000_000_000_000
            if let presses = machine.solve(maxPresses: .max) {
                tokens += 3 * presses.a + presses.b
            }
        }
        print("Part 2 (\(source)): \(tokens)")
    }
}
