//
//  InputData.swift
//  Day 12
//
//  Copyright © 2024 peter bohac. All rights reserved.
//

struct InputData: CustomStringConvertible {
    static let day = 12
    static func part1(_ challengeData: String?) -> [Self?] {[
        .example,
        .example2,
        .example3,
        challengeData.map { Self(name: "challenge", data: $0) }
    ]}
    static func part2(_ challengeData: String?) -> [Self?] {[
        .example,
        .example2,
        .example3,
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
AAAA
BBCD
BBCC
EEEC
""")

    static let example2 = Self(
        name: "example2",
        data:
"""
OOOOO
OXOXO
OOOOO
OXOXO
OOOOO
""")

    static let example3 = Self(
        name: "example3",
        data:
"""
RRRRIICCFF
RRRRIICCCF
VVRRRCCFFF
VVRCCCJFFF
VVVVCJJCFE
VVIVCCJJEE
VVIIICJJEE
MIIIIIJJEE
MIIISIJEEE
MMMISSJEEE
""")
}
