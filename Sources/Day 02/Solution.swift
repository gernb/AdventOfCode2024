//
//  Solution.swift
//  Day 02
//
//  Copyright © 2024 peter bohac. All rights reserved.
//

// MARK: - Part 1

struct Report {
    let levels: [Int]
}
extension Report {
    init(_ line: any StringProtocol) {
        self.levels = line
            .components(separatedBy: .whitespaces)
            .compactMap(Int.init)
    }

    static func parse(input lines: [String]) -> [Report] {
        lines.map(Report.init)
    }
}

enum Part1 {
    static func reportIsSafe(_ report: Report) -> Bool {
        let levelDiffs = report.levels
            .dropLast()
            .enumerated()
            .map { index, level in
                level - report.levels[index + 1]
            }
        let sign = levelDiffs[0].signum()
        return levelDiffs.allSatisfy { diff in
            diff.signum() == sign && abs(diff) >= 1 && abs(diff) <= 3
        }
    }

    static func run(_ source: InputData) {
        let reports = Report.parse(input: source.lines)
        let safeReports = reports.filter(Part1.reportIsSafe)
        print("Part 1 (\(source)): \(safeReports.count)")
    }
}

// MARK: - Part 2

extension Report {
    func report(removing levelIndex: Int) -> Report {
        var levels = levels
        levels.remove(at: levelIndex)
        return .init(levels: levels)
    }
}

enum Part2 {
    static func reportCanBeFixed(_ report: Report) -> Bool {
        for (index, _) in report.levels.enumerated() {
            let fixedReport = report.report(removing: index)
            if Part1.reportIsSafe(fixedReport) {
                return true
            }
        }
        return false
    }

    static func run(_ source: InputData) {
        let reports = Report.parse(input: source.lines)
        let unsafeReports = reports.filter { Part1.reportIsSafe($0) == false }
        var safeReportsCount = reports.count - unsafeReports.count
        for report in unsafeReports where reportCanBeFixed(report) {
            safeReportsCount += 1
        }
        print("Part 2 (\(source)): \(safeReportsCount)")
    }
}
