//
//  InputData.swift
//  Day 14
//
//  Copyright © 2024 peter bohac. All rights reserved.
//

struct InputData: CustomStringConvertible {
    static let day = 14
    static func part1(_ challengeData: String?) -> [Self?] {[
        .example,
        challengeData.map { Self(name: "challenge", size: (101, 103), data: $0) }
    ]}
    static func part2(_ challengeData: String?) -> [Self?] {[
        challengeData.map { Self(name: "challenge", size: (101, 103), data: $0) }
    ]}

    let name: String
    let size: (width: Int, height: Int)
    let data: String

    var lines: [String] { data.components(separatedBy: .newlines) }
    var description: String { name }

    static let example = Self(
        name: "example",
        size: (11, 7),
        data:
"""
p=0,4 v=3,-3
p=6,3 v=-1,-3
p=10,3 v=-1,2
p=2,0 v=2,-1
p=0,0 v=1,3
p=3,0 v=-2,-2
p=7,6 v=-1,-3
p=3,0 v=-1,-2
p=9,3 v=2,3
p=7,3 v=-1,2
p=2,4 v=2,-3
p=9,5 v=-3,-3
""")
}
