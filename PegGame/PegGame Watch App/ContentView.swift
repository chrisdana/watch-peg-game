//
//  ContentView.swift
//  PegGame Watch App
//
//  Created by Christopher Dana on 4/20/24.
//

import SwiftUI

struct ContentView: View {
    @State private var boardReset = true
    @State private var pegs = initGameState(levels: 5)
    @State private var history: [MoveEntry] = []
    @State private var alreadyDisplayedWin = false

    var body: some View {
        VStack {
            GameBoardView(boardReset: $boardReset, 
                          pegs: $pegs,
                          history: $history,
                          alreadyDisplayedWin: $alreadyDisplayedWin)
            Divider().frame(height: 15)
            InfoControlView(boardReset: $boardReset, 
                            pegs: $pegs,
                            history: $history,
                            alreadyDisplayedWin: $alreadyDisplayedWin)
        }
        .padding()
    }

    /// Initialize the game board.
    /// The game state is stored as an array of StateEntry sctructs where the peg positions are indexed
    /// as pictured below.  The .id property of the state also uses this index.  Each state entry has a set
    /// containing its neighbors, which is used to calculate valid moves.
    ///
    ///
    ///            0
    ///          1   2
    ///        3   4    5
    ///     6    7    8   9
    ///  10   11   12   13  14
    ///
    ///
    static func initGameState(levels: Int) -> [StateEntry] {
        var state: [StateEntry] = []
        let numNodes = (levels * (levels + 1)) / 2

        // Add nodes
        for i in 0..<numNodes {
            state.append(StateEntry(id: i, hasPeg: true))
        }

        // Fill in state info
        for i in 0..<levels {
            for j in 0..<(i + 1) {
                let idxCurrNode = ((i * (i + 1)) / 2) + j

                // Save the node level
                state[idxCurrNode].level = i

                // Add edges
                if i < levels - 1 {
                    let idxBotLeftNode = idxCurrNode + i + 1
                    let idxBotRightNode = idxCurrNode + i + 2
                    addEdge(idx1: idxCurrNode, idx2: idxBotLeftNode, state: &state)
                    addEdge(idx1: idxCurrNode, idx2: idxBotRightNode, state: &state)
                }
                if j < i {
                    let idxRightNode = idxCurrNode + 1
                    addEdge(idx1: idxCurrNode, idx2: idxRightNode, state: &state)
                }
            }
        }

        return state
    }

    static func addEdge(idx1: Int, idx2: Int, state: inout [StateEntry]) {
        if !state[idx1].neighbors.contains(state[idx2].id) {
            state[idx1].neighbors.insert(state[idx2].id)
        }
        if !state[idx2].neighbors.contains(state[idx1].id) {
            state[idx2].neighbors.insert(state[idx1].id)
        }
    }

}


#Preview {
    ContentView()
}
