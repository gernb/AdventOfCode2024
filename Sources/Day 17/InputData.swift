//
//  InputData.swift
//  Day 17
//
//  Copyright © 2024 peter bohac. All rights reserved.
//

struct InputData: CustomStringConvertible {
    static let day = 17
    static func part1(_ challengeData: String?) -> [Self?] {[
        .example,
        challengeData.map { Self(name: "challenge", data: $0) }
    ]}
    static func part2(_ challengeData: String?) -> [Self?] {[
        .example2,
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
Register A: 729
Register B: 0
Register C: 0

Program: 0,1,5,4,3,0
""")

    static let example2 = Self(
        name: "example2",
        data:
"""
Register A: 2024
Register B: 0
Register C: 0

Program: 0,3,5,4,3,0
""")
}
