//
//  InputData.swift
//  Day 13
//
//  Copyright © 2024 peter bohac. All rights reserved.
//

struct InputData: CustomStringConvertible {
    static let day = 13
    static func part1(_ challengeData: String?) -> [Self?] {[
        .example,
        challengeData.map { Self(name: "challenge", data: $0) }
    ]}
    static func part2(_ challengeData: String?) -> [Self?] {[
        .example,
        challengeData.map { Self(name: "challenge", data: $0) }
    ]}

    let name: String
    let data: String

    var lines: [String] { data.components(separatedBy: .newlines) }
    var description: String { name }

    static let example = Self(
        name: "example",
        data:
"""
Button A: X+94, Y+34
Button B: X+22, Y+67
Prize: X=8400, Y=5400

Button A: X+26, Y+66
Button B: X+67, Y+21
Prize: X=12748, Y=12176

Button A: X+17, Y+86
Button B: X+84, Y+37
Prize: X=7870, Y=6450

Button A: X+69, Y+23
Button B: X+27, Y+71
Prize: X=18641, Y=10279
""")
}
