//
//  Solution.swift
//  Day 05
//
//  Copyright © 2024 peter bohac. All rights reserved.
//

// MARK: - Part 1

struct Rule {
    let before: Int
    let after: Int

    func isValid(for update: Update) -> Bool {
        let beforeIndex = update.pages.firstIndex(of: before)!
        guard let afterIndex = update.pages.firstIndex(of: after) else { return true }
        return beforeIndex < afterIndex
    }
}
extension Rule {
    init(_ line: any StringProtocol) {
        let values = line.components(separatedBy: "|").compactMap(Int.init)
        self.init(before: values[0], after: values[1])
    }
}
extension Array where Element == Rule {
    func rules(for page: Int) -> [Rule] {
        filter { $0.before == page }
    }
}

struct Update {
    var pages: [Int]
}
extension Update {
    init (_ line: any StringProtocol) {
        let values = line.components(separatedBy: ",").compactMap(Int.init)
        self.init(pages: values)
    }
}

func parse(_ input: [String]) -> (rules: [Rule], updates: [Update]) {
    let parts = input.split(separator: "")
    let rules = parts[0].map(Rule.init)
    let updates = parts[1].map(Update.init)
    return (rules, updates)
}

enum Part1 {
    static func validate(_ update: Update, with rules: [Rule]) -> Bool {
        for page in update.pages {
            let pageRules = rules.rules(for: page)
            for rule in pageRules {
                if rule.isValid(for: update) == false { return false }
            }
        }
        return true
    }

    static func run(_ source: InputData) {
        let (rules, updates) = parse(source.lines)
        let middlePages = updates.compactMap { update -> Int? in
            guard validate(update, with: rules) else { return nil }
            return update.pages[update.pages.count / 2]
        }
        let result = middlePages.reduce(0, +)
        print("Part 1 (\(source)): \(result)")
    }
}

// MARK: - Part 2

enum Part2 {
    static func fix(update: Update, using rules: [Rule]) -> Update {
        var update = update
        while Part1.validate(update, with: rules) == false {
            for page in update.pages {
                let pageRules = rules.rules(for: page)
                for rule in pageRules {
                    if rule.isValid(for: update) == false {
                        var index = update.pages.firstIndex(of: rule.before)!
                        update.pages.remove(at: index)
                        index = update.pages.firstIndex(of: rule.after)!
                        update.pages.insert(rule.before, at: index)
                    }
                }
            }
        }
        return update
    }

    static func run(_ source: InputData) {
        let (rules, updates) = parse(source.lines)
        let invalidUpdates = updates.filter { Part1.validate($0, with: rules) == false }
        let fixedUpdates = invalidUpdates.map { fix(update: $0, using: rules) }
        let middlePages = fixedUpdates.map { $0.pages[$0.pages.count / 2] }
        let result = middlePages.reduce(0, +)
        print("Part 2 (\(source)): \(result)")
    }
}
