//
//  GameViewModel.swift
//  PegGame Watch App
//
//  Created by Christopher Dana on 4/20/24.
//

import SwiftUI

/// Draws the game board board and handles taps on the pegs
struct GameBoardView: View {
    @Binding var boardReset: Bool
    @Binding var pegs: [StateEntry]
    @Binding var history: [MoveEntry]
    @Binding var alreadyDisplayedWin: Bool

    @State private var moveTap1 = true
    @State private var showWinnerScreen = false
    @State private var validMoves: [MoveEntry] = []

    let numberOfRows = 5        // Number of levels in the triangle
    let circleRadius = 28.0     // Radius of each peg
    let foregroundColor = Color.white
    let backgroundColor = Color.black
    let highlightColor = Color.green

    var body: some View {
        VStack(spacing: 5) {
            ForEach(0..<numberOfRows, id: \.self) { row in
                HStack(spacing: spacing(for: row)) {
                    ForEach(0...row, id: \.self) { col in
                        let idx = (row * (row + 1) / 2) + col
                        Button(action: {
                            tapHandler(idx: idx, pegStates: &pegs)
                            if isWinner() && !alreadyDisplayedWin {
                                alreadyDisplayedWin = true
                                showWinnerScreen.toggle()
                            }
                        })
                        {
                            if pegs[idx].hasPeg {
                                drawPeg(highlight: pegs[idx].selected)
                            } else {
                                drawEmptyPeg(highlight: pegs[idx].selected)
                            }
                        }
                        .accessibilityIdentifier("peg\(pegs[idx].id)")
                        .buttonStyle(PegStyle())
                        .sheet(isPresented: $showWinnerScreen) {
                            WinScreenView()
                        }
                    }
                }
            }
        }
    }

    func spacing(for row: Int) -> CGFloat {
        let numberOfRows = CGFloat(self.numberOfRows)
        let numberOfCirclesInRow = CGFloat(row + 1)
        let totalWidth = 10 * numberOfCirclesInRow
        let remainingSpace = (10 * (numberOfRows - numberOfCirclesInRow)) / 2
        return (totalWidth + remainingSpace) / (numberOfRows - 1)
    }

    func drawPeg(highlight: Bool) -> some View {
        return Circle()
            .stroke(highlight ? highlightColor : backgroundColor,
                    lineWidth: highlight ? circleRadius * 0.1 : 0)
            .fill(RadialGradient(
                gradient: Gradient(colors: [foregroundColor, backgroundColor]),
                center: .center, startRadius: circleRadius * 0.1,
                endRadius: circleRadius * 0.7))
            .frame(width: circleRadius, height: circleRadius)
    }

    func drawEmptyPeg(highlight: Bool) -> some View {
        return Circle()
            .stroke(highlight ? highlightColor : foregroundColor,
                    lineWidth: circleRadius * 0.1)
            .fill(backgroundColor)
            .frame(width: circleRadius, height: circleRadius)
    }

    func tapHandler(idx: Int, pegStates: inout [StateEntry])
    {
        // The first tap to remove a peg
        if boardReset {
            pegStates[idx].hasPeg.toggle()
            boardReset = false
            return
        }

        // Reset all highlights
        for idx in 0..<pegStates.count {
            pegStates[idx].selected = false
        }

        if moveTap1 {
            getValidMoves(srcId: idx, moves: &validMoves)
            highlightMoves(idx: idx, pegStates: &pegStates, validMoves: &validMoves)
            moveTap1 = false
        }
        else {
            makeMove(idx: idx, pegStates: &pegStates, validMoves: &validMoves)
            moveTap1 = true
        }
    }

    func highlightMoves(idx: Int, pegStates: inout [StateEntry], validMoves: inout [MoveEntry])
    {
        // No valid moves -- return
        if validMoves.isEmpty {
            return
        }
        // Highlight valid moves
        pegStates[idx].selected.toggle()
        for move in validMoves {
            pegStates[move.dst].selected.toggle()
        }
    }

    func makeMove(idx: Int, pegStates: inout [StateEntry], validMoves: inout [MoveEntry])
    {
        // Find the move that was made (if any)
        for move in validMoves {
            if idx == move.dst {
                pegStates[move.src].hasPeg = false
                pegStates[move.jmp].hasPeg = false
                pegStates[move.dst].hasPeg = true
                history.append(move)
                break
            }
        }
    }

    func getValidMoves(srcId: Int, moves: inout [MoveEntry]) {
        moves = []
        let srcNode = pegs[srcId]

        if !srcNode.hasPeg {
            return
        }

        for jmpId in srcNode.neighbors {
            let jmpNode = pegs[jmpId]

            if jmpId == srcId { continue }     // Avoid cycles
            if !jmpNode.hasPeg { continue }    // Neighbor must have a peg

            // Find destination index
            var dstId = (2 * jmpId) - srcId
            if srcNode.level != jmpNode.level {
                dstId += 1
            }

            if !jmpNode.neighbors.contains(dstId) { continue } // Dest must be a neighbor of jmp
            if srcNode.neighbors.contains(dstId) { continue } // Dest cannot be a neighbor of src

            let dstNode = pegs[dstId]
            if dstNode.hasPeg { continue } // Dest must not already have a peg
            // Horizontal jumps must be contained to a single level
            if srcNode.level == jmpNode.level && jmpNode.level != dstNode.level {
                continue
            }

            moves.append(MoveEntry(src: srcId, jmp: jmpId, dst: dstId))
        }
    }

    func isWinner() -> Bool {
        let numPegs = pegs.filter({ $0.hasPeg }).count
        return numPegs == 1
    }
}


/// Override default button style
struct PegStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}


/// Handle the instructions for the first tap
struct InfoControlView: View {
    @Binding var boardReset: Bool
    @Binding var pegs: [StateEntry]
    @Binding var history: [MoveEntry]
    @Binding var alreadyDisplayedWin: Bool

    var body: some View {
        if self.boardReset {
            Text("Select initial peg to remove")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, .yellow, .yellow, .orange],
                        startPoint: .leading,
                        endPoint: .trailing))
                .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                .accessibilityIdentifier("instructions")
                .padding(4)
        } else {
            HStack {
                UndoView(pegs: $pegs, history: $history, alreadyDisplayedWin: $alreadyDisplayedWin)
                ResetView(boardReset: $boardReset, pegs: $pegs, history: $history)
            }.padding(10)
        }
    }
}


/// Allow players to undo the last move
struct UndoView: View {
    @Binding var pegs: [StateEntry]
    @Binding var history: [MoveEntry]
    @Binding var alreadyDisplayedWin: Bool

    var body: some View {
        Button("", systemImage: "arrow.uturn.backward",action: undoMove)
            .buttonStyle(.bordered)
            .controlSize(.mini)
            .accessibilityIdentifier("undo")
    }

    func undoMove() {
        if let move = history.popLast() {
            self.pegs[move.src].hasPeg = true
            self.pegs[move.jmp].hasPeg = true
            self.pegs[move.dst].hasPeg = false
        }
        alreadyDisplayedWin = false // Let them see the win screen again
    }
}


/// Allow players to reset the game board
struct ResetView: View {
    @Binding var boardReset: Bool
    @Binding var pegs: [StateEntry]
    @Binding var history: [MoveEntry]

    var body: some View {
        Button("Reset", action: doReset)
            .buttonStyle(.bordered)
            .controlSize(.mini)
            .accessibilityIdentifier("reset")
    }

    func doReset() {
        for idx in 0..<pegs.count {
            self.pegs[idx].hasPeg = true
        }
        self.history = []
        self.boardReset = true
    }
}


/// Present the win screen
struct WinScreenView: View {
    var body: some View {
        VStack() {
            Text("You Win!")
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, .yellow, .yellow, .orange],
                        startPoint: .leading,
                        endPoint: .trailing))
                .accessibilityIdentifier("wintext")

            Image(systemName: "rainbow")
                .resizable(resizingMode: .stretch)
                .renderingMode(.original)
                .symbolEffect(.variableColor, isActive: true)
                .accessibilityIdentifier("winimage")
        }
        .padding()
    }
}
