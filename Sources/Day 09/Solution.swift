//
//  Solution.swift
//  Day 09
//
//  Copyright © 2024 peter bohac. All rights reserved.
//

// MARK: - Part 1

struct Filesystem {
    var blocks: [Int: Int] = [:] // Position: FileID
    var end: Int { blocks.keys.max()! }
    var checksum: Int {
        blocks.reduce(0) { $0 + ($1.key * $1.value) }
    }

    mutating func move(from: Int, to: Int) {
        assert(blocks[to] == nil)
        let fileId = blocks[from]!
        blocks[from] = nil
        blocks[to] = fileId
    }

    func firstFreeBlock(after: Int = -1) -> Int {
        var index = after + 1
        while blocks[index] != nil {
            index += 1
        }
        return index
    }
}
extension Filesystem {
    init(_ diskMap: String) {
        let entries = diskMap.map(String.init).compactMap(Int.init)
        var blocks: [Int: Int] = [:]
        var nextIsFile = true
        var nextFileBlock = 0
        var nextFileID = 0
        for entry in entries {
            if nextIsFile {
                for _ in 0 ..< entry {
                    blocks[nextFileBlock] = nextFileID
                    nextFileBlock += 1
                }
                nextFileID += 1
            } else {
                nextFileBlock += entry
            }
            nextIsFile.toggle()
        }
        self.init(blocks: blocks)
    }
}
extension Filesystem: CustomStringConvertible {
    var description: String {
        return (0 ... end).map {
            if let block = blocks[$0] { "\(block)" }
            else { "." }
        }
        .joined()
    }
}

enum Part1 {
    static func run(_ source: InputData) {
        var filesystem = Filesystem(source.lines.first!)
        var nextFree = filesystem.firstFreeBlock()
        while (nextFree < filesystem.end) {
            filesystem.move(from: filesystem.end, to: nextFree)
            nextFree = filesystem.firstFreeBlock(after: nextFree)
        }
        print("Part 1 (\(source)): \(filesystem.checksum)")
    }
}

// MARK: - Part 2

struct Filesystem2 {
    struct File: CustomStringConvertible {
        let id: Int
        let length: Int
        var start: Int
        var end: Int { start + length }
        var checksum: Int { (start ..< start+length).reduce(0) { $0 + ($1 * id) } }
        var description: String { (1 ... length).map { _ in "\(id)" }.joined() }
    }

    var files: [File] = []
    var checksum: Int { files.reduce(0) { $0 + $1.checksum } }
    func file(with id: Int) -> File {
        files.first(where: { $0.id == id })!
    }
    mutating func move(_ file: File, to: Int) {
        let currentIndex = files.firstIndex(where: { $0.id == file.id })!
        var file = files.remove(at: currentIndex)
        file.start = to
        let newIndex = files.firstIndex(where: { $0.start > to })!
        files.insert(file, at: newIndex)
    }
}
extension Filesystem2 {
    init(_ diskMap: String) {
        let entries = diskMap.map(String.init).compactMap(Int.init)
        var files: [File] = []
        var nextIsFile = true
        var nextBlock = 0
        var nextFileID = 0
        for entry in entries {
            if nextIsFile {
                let file = File(id: nextFileID, length: entry, start: nextBlock)
                files.append(file)
                nextBlock += entry
                nextFileID += 1
            } else {
                nextBlock += entry
            }
            nextIsFile.toggle()
        }
        self.init(files: files)
    }
}
extension Filesystem2: CustomStringConvertible {
    var description: String {
        files.enumerated().dropFirst().reduce(files[0].description) { result, item in
            let previousEnd = files[item.offset - 1].end
            return result + (previousEnd ..< item.element.start).map { _ in "." }.joined() + item.element.description
        }
    }
}

enum Part2 {
    static func run(_ source: InputData) {
        var filesystem = Filesystem2(source.lines.first!)
        for fileId in (0 ... filesystem.files.last!.id).reversed() {
            let file = filesystem.file(with: fileId)
            for (index, otherFile1) in filesystem.files.enumerated().dropLast() {
                if otherFile1.end >= file.start { break }
                let otherFile2 = filesystem.files[index + 1]
                let emptySpace = otherFile2.start - otherFile1.end
                if emptySpace >= file.length {
                    filesystem.move(file, to: otherFile1.end)
                    break
                }
            }
        }
        print("Part 2 (\(source)): \(filesystem.checksum)")
    }
}
