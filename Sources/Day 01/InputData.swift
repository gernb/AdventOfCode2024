//
//  InputData.swift
//  Day 01
//
//  Copyright © 2024 peter bohac. All rights reserved.
//

struct InputData: CustomStringConvertible {
    static let day = 1
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
3   4
4   3
2   5
1   3
3   9
3   3
""")
}
