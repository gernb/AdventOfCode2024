//
//  InputData.swift
//  Day 22
//
//  Copyright © 2024 peter bohac. All rights reserved.
//

struct InputData: CustomStringConvertible {
    static let day = 22
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
1
10
100
2024
""")

    static let example2 = Self(
        name: "example2",
        data:
"""
1
2
3
2024
""")
}
