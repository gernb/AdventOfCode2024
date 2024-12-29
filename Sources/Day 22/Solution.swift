//
//  Solution.swift
//  Day 22
//
//  Copyright © 2024 peter bohac. All rights reserved.
//

// MARK: - Part 1

extension Int {
    func mix(with other: Int) -> Int {
        self ^ other
    }
    func prune() -> Int {
        self % 16777216
    }
    func nextSecret() -> Int {
        let step1 = self.mix(with: self * 64).prune()
        let step2 = step1.mix(with: step1 / 32).prune()
        let step3 = step2.mix(with: step2 * 2048).prune()
        return step3
    }
}

enum Part1 {
    static func run(_ source: InputData) {
        let sum = source.lines.compactMap(Int.init)
            .reduce(0) { sum, initial in
                var secret = initial
                for _ in 1 ... 2000 {
                    secret = secret.nextSecret()
                }
                return sum + secret
            }
        print("Part 1 (\(source)): \(sum)")
    }
}

// MARK: - Part 2

enum Part2 {
    static func prices(for monkey: Int) -> [(price: Int, diff: Int?)] {
        let secrets = (1 ..< 2000).reduce(into: [monkey]) { secrets, _ in
            secrets.append(secrets.last!.nextSecret())
        }
        return [(monkey % 10, nil)] + secrets.enumerated().dropFirst().map { index, secret in
            (secret % 10, (secret % 10) - (secrets[index - 1] % 10))
        }
    }

    static func run(_ source: InputData) {
        let monkeys: [[[Int]: Int]] = source.lines.compactMap(Int.init).map(prices(for:)).map { list in
            return list.enumerated().dropFirst(4).reduce(into: [:]) { result, item in
                let key = [item.offset - 3, item.offset - 2, item.offset - 1, item.offset].map { list[$0].diff! }
                if result[key] == nil {
                    result[key] = item.element.price
                }
            }
        }
        var sums: [[Int]: Int] = [:]
        for a in -9 ... 9 {
            for b in -9 ... 9 {
                for c in -9 ... 9 {
                    for d in -9 ... 9 {
                        let sequence = [a, b, c, d]
                        let sum = monkeys.reduce(0) { $0 + $1[sequence, default: 0] }
                        sums[sequence] = sum
                    }
                }
            }
        }
        let result = sums.max { $0.value < $1.value }!
        print("Part 2 (\(source)): \(result)")
    }
}
