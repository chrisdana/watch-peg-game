//
//  GameModel.swift
//  PegGame Watch App
//
//  Created by Christopher Dana on 4/20/24.
//

struct StateEntry: Identifiable {
    var id = -1  // Will be initialized with peg number when instantiated
    var neighbors: Set<Int> = []
    var level = -1
    var hasPeg = false
    var selected = false
}

struct MoveEntry: Equatable, Comparable {
    var src = -1
    var jmp = -1
    var dst = -1

    // Used to assist unit testing
    static func == (lhs: MoveEntry, rhs: MoveEntry) -> Bool {
        return lhs.src == rhs.src && lhs.jmp == rhs.jmp && lhs.dst == rhs.dst
    }

    // Used to assist unit testing
    static func < (lhs: MoveEntry, rhs: MoveEntry) -> Bool {
        if lhs.src != rhs.src {
            return lhs.src < rhs.src
        } else if lhs.jmp != rhs.jmp {
            return lhs.jmp < rhs.jmp
        } else {
            return lhs.dst < rhs.dst
        }
    }
}
