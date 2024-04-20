//
//  PegGame_Watch_AppTests.swift
//  PegGame Watch AppTests
//
//  Created by Christopher Dana on 4/20/24.
//

import XCTest
import SwiftUI
@testable import PegGame_Watch_App

final class PegGame_Watch_AppTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. 
    }

    func testinitGameStateNumPegs() throws {
        let nLevels = 3
        let expNumPegs = Int((nLevels * (nLevels + 1)) / 2)
        let initState = ContentView.initGameState(levels: nLevels)
        XCTAssert(initState.count == expNumPegs)
    }

    func testinitGameStateNoEmptyPegs() throws {
        let nLevels = 3
        let initState = ContentView.initGameState(levels: nLevels)
        for state in initState {
            XCTAssert(state.hasPeg)
        }
    }

    func testinitGameStateNeighbors() throws {
        // For the minimum case verify that all nodes are neighbors with each other
        let nLevels = 2
        let initState = ContentView.initGameState(levels: nLevels)
        for state in initState {
            let neighbor1 = (state.id + 1) % initState.count
            let neighbor2 = (state.id + 2) % initState.count
            XCTAssert(state.neighbors.contains(neighbor1))
            XCTAssert(state.neighbors.contains(neighbor2))
        }
    }
}


final class PegGame_Watch_App_TapHandlerTests: XCTestCase {
    // Set up variables to simulate the @State variables in ContentView
    var boardReset = true
    var pegs = ContentView.initGameState(levels: 5)
    var history: [MoveEntry] = []
    var alreadyDisplayedWin = false
    var gv: GameBoardView!

    // Variables used for testing
    var pegStates = ContentView.initGameState(levels: 5)
    var ft = true

    override func setUpWithError() throws {
        // Create @Binding variables to pass to the GameBoardView
        let brBinding = Binding(get: { self.boardReset }, set: { self.boardReset = $0 })
        let stateBinding = Binding(get: { self.pegs }, set: { self.pegs = $0 })
        let histBinding = Binding(get: { self.history }, set: { self.history = $0 })
        let winBinding = Binding(get: {self.alreadyDisplayedWin }, set: { self.alreadyDisplayedWin = $0 })
        gv = GameBoardView(boardReset: brBinding,
                           pegs: stateBinding,
                           history: histBinding,
                           alreadyDisplayedWin: winBinding)
    }

    override func tearDownWithError() throws {
        // Put teardown code here.
    }


    func testTapHandlerBoardReset() throws {
        XCTAssert(boardReset == true)
        gv.tapHandler(idx: 0, pegStates: &pegStates)
        XCTAssert(boardReset == false)
    }

    func testTapHandlerFirstTap() throws {
        XCTAssert(pegStates[0].hasPeg == true)
        gv.tapHandler(idx: 0, pegStates: &pegStates)
        XCTAssert(pegStates[0].hasPeg == false)
    }

    func testTapHandlerNoValidHighlight() throws {
        var validMoves: [MoveEntry] = []
        gv.highlightMoves(idx: 0, pegStates: &pegStates, validMoves: &validMoves)
        for peg in pegStates {
            XCTAssert(peg.selected == false)
        }
    }

    func testTapHandlerNoValidMove() throws {
        var validMoves: [MoveEntry] = []
        gv.makeMove(idx: 0, pegStates: &pegStates, validMoves: &validMoves)
        for peg in pegStates {
            XCTAssert(peg.hasPeg == true)
        }
    }

    func testTapHandlerHighlightMoves() throws {
        let validMove = MoveEntry(src: 3, jmp: 1, dst: 0)
        var validMoves = [validMove]

        gv.tapHandler(idx: 0, pegStates: &pegStates)
        gv.highlightMoves(idx: 3, pegStates: &pegStates, validMoves: &validMoves)
        for peg in pegStates {
            if [0, 3].contains(peg.id) {
                XCTAssert(peg.selected == true)
            } else{
                XCTAssert(peg.selected == false)
            }
        }
    }

    func testTapHandlerMakeMove() throws {
        let validMove = MoveEntry(src: 3, jmp: 1, dst: 0)
        var validMoves = [validMove]

        gv.tapHandler(idx: 0, pegStates: &pegStates)
        gv.makeMove(idx: 0, pegStates: &pegStates, validMoves: &validMoves)
        for peg in pegStates {
            if [1, 3].contains(peg.id) {
                XCTAssert(peg.hasPeg == false)
                XCTAssert(peg.selected == false)
            } else{
                XCTAssert(peg.hasPeg == true)
                XCTAssert(peg.selected == false)
            }
        }
    }
}


final class PegGame_Watch_App_GetValidMovesTests: XCTestCase {
    var boardReset = true
    var pegs = ContentView.initGameState(levels: 5)
    var history: [MoveEntry] = []
    var validMoves: [MoveEntry] = []
    var alreadyDisplayedWin = false
    var gv: GameBoardView!

    override func setUpWithError() throws {
        let brBinding = Binding(get: { self.boardReset }, set: { self.boardReset = $0 })
        let stateBinding = Binding(get: { self.pegs }, set: { self.pegs = $0 })
        let histBinding = Binding(get: { self.history }, set: { self.history = $0 })
        let winBinding = Binding(get: {self.alreadyDisplayedWin }, set: { self.alreadyDisplayedWin = $0 })
        gv = GameBoardView(boardReset: brBinding,
                           pegs: stateBinding,
                           history: histBinding,
                           alreadyDisplayedWin: winBinding)
    }

    override func tearDownWithError() throws {
        // Put teardown code here.
    }

    func testValidMovesOneMove() throws {
        pegs[0].hasPeg = false
        gv.getValidMoves(srcId: 3, moves: &validMoves)
        XCTAssertEqual(validMoves, [(MoveEntry)(src:3, jmp: 1, dst: 0)])
    }

    func testValidMovesNoSrcPeg() throws {
        pegs[0].hasPeg = false
        gv.getValidMoves(srcId: 0, moves: &validMoves)
        XCTAssertEqual(validMoves, [])
    }

    func testValidMovesNoJmpPeg() throws {
        pegs[0].hasPeg = false
        gv.getValidMoves(srcId: 0, moves: &validMoves)
        XCTAssertEqual(validMoves, [])
    }

    func testValidMovesDstPeg() throws {
        pegs[0].hasPeg = false
        gv.getValidMoves(srcId: 0, moves: &validMoves)
        XCTAssertEqual(validMoves, [])
    }

    func testValidMovesMultipleMove() throws {
        // Setup the following board with four moves from peg 3 (marked with X)
        //
        //          .
        //        O   O
        //      X   O   .
        //    O   O   O   O
        //  .   O   .   O   O
        //
        // Valid moves should be: (3 -> 0), (3 -> 5), (3 -> 10), (3 -> 12)

        pegs[0].hasPeg = false
        pegs[5].hasPeg = false
        pegs[10].hasPeg = false
        pegs[12].hasPeg = false
        gv.getValidMoves(srcId: 3, moves: &validMoves)
        validMoves = validMoves.sorted()
        XCTAssertEqual(validMoves.count, 4)
        XCTAssertEqual(validMoves, [(MoveEntry)(src:3, jmp: 1, dst: 0),
                                    (MoveEntry)(src:3, jmp: 4, dst: 5),
                                    (MoveEntry)(src:3, jmp: 6, dst: 10),
                                    (MoveEntry)(src:3, jmp: 7, dst: 12)])
    }
}


