//
//  Solution.swift
//  Day 23
//
//  Copyright © 2024 peter bohac. All rights reserved.
//

// MARK: - Part 1

extension Collection {
    func combinations(of size: Int) -> [[Element]] {
        func pick(_ count: Int, from: ArraySlice<Element>) -> [[Element]] {
            guard count > 0 else { return [] }
            guard count < from.count else { return [Array(from)] }
            if count == 1 {
                return from.map { [$0] }
            } else {
                return from.dropLast(count - 1)
                    .enumerated()
                    .flatMap { pair in
                        return pick(count - 1, from: from.dropFirst(pair.offset + 1)).map { [pair.element] + $0 }
                    }
            }
        }

        return pick(size, from: ArraySlice(self))
    }
}

func connections(for input: [String]) -> [String: Set<String>] {
    input.reduce(into: [:]) { result, line in
        let computers = line.components(separatedBy: "-")
        result[computers[0], default: []].insert(computers[1])
        result[computers[1], default: []].insert(computers[0])
    }
}

enum Part1 {
    static func parties(size: Int, connections: [String: Set<String>]) -> Set<Set<String>> {
        func computer(_ computer: String, isConnectedTo computers: [String]) -> Bool {
            computers.allSatisfy { $0 == computer || connections[$0]!.contains(computer) }
        }
        return connections.reduce(into: Set<Set<String>>()) { result, item in
            guard item.value.count >= 2 else { return }
            for combo in item.value.combinations(of: size - 1) {
                if combo.allSatisfy({ computer($0, isConnectedTo: combo) }) {
                    var party: Set<String> = [item.key]
                    party.formUnion(combo)
                    result.insert(party)
                }
            }
        }
    }

    static func run(_ source: InputData) {
        let connections = connections(for: source.lines)
        let partiesWithHistorian = parties(size: 3, connections: connections)
            .filter { $0.contains(where: { $0.hasPrefix("t") }) }
        print("Part 1 (\(source)): \(partiesWithHistorian.count)")
    }
}

// MARK: - Part 2

enum Part2 {
    static func run(_ source: InputData) {
        let connections = connections(for: source.lines)
        let maxSize = connections.max { $0.value.count < $1.value.count }!.value.count
        for size in (3 ... maxSize).reversed() {
            let parties = Part1.parties(size: size, connections: connections)
            if let party = parties.first {
                let result = party.sorted().joined(separator: ",")
                print("Part 2 (\(source)): \(result)")
                return
            }
        }
        print("Part 2 (\(source)): FAILED")
    }
}
