//
//  PegGame_Watch_AppUITests.swift
//  PegGame Watch AppUITests
//
//  Created by Christopher Dana on 4/20/24.
//

import XCTest

final class PegGame_Watch_AppUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here.
    }

    func testInitAppStartup() throws {
        // Pass criteria:
        // - Instructions are displayed and text is correct
        // - Controls (undo/reset) are not available
        let instructions = app.staticTexts["instructions"]
        XCTAssert(instructions.exists)
        XCTAssertEqual(instructions.label, "Select initial peg to remove")
        XCTAssert(app.buttons["undo"].isHittable == false)
        XCTAssert(app.buttons["reset"].isHittable == false)
    }

    func testFirstTap() throws {
        // Pass criteria:
        // - Instructions are not displayed
        // - Controls (undo/reset) are available
        app.buttons["peg0"].tap()
        let instructions = app.staticTexts["instructions"]
        XCTAssert(instructions.exists == false)
        XCTAssert(app.buttons["undo"].isHittable)
        XCTAssert(app.buttons["reset"].isHittable)
    }

    func testReset() throws {
        // Pass criteria:
        // - Instructions are displayed and text is correct
        // - Controls (undo/reset) are not available
        app.buttons["peg0"].tap()
        app.buttons["reset"].tap()
        let instructions = app.staticTexts["instructions"]
        XCTAssert(instructions.exists)
        XCTAssert(app.buttons["undo"].isHittable == false)
        XCTAssert(app.buttons["reset"].isHittable == false)
    }

    func testUndoMove() throws {
        // Pass criteria:
        // - Game board and controls remain available
        app.buttons["peg0"].tap()
        app.buttons["peg3"].tap()
        app.buttons["peg0"].tap()
        app.buttons["undo"].tap()
        XCTAssert(app.buttons["undo"].isHittable)
        XCTAssert(app.buttons["reset"].isHittable)
    }

    func testUndoPastFirstMove() throws {
        // Pass criteria:
        // - Game board and controls remain available
        // - Game board does not fully reset
        app.buttons["peg0"].tap()
        app.buttons["peg3"].tap()
        app.buttons["peg0"].tap()
        app.buttons["undo"].tap()
        app.buttons["undo"].tap()
        XCTAssert(app.buttons["undo"].isHittable)
        XCTAssert(app.buttons["reset"].isHittable)
    }

    func testWinScreen() throws {
        // Pass criteria:
        // - Win screen is displayed
        // - Able to dismiss win screen
        let moves = [(3, 0), (5, 3), (0, 5), (6, 1),
                     (9, 2), (11, 4), (12, 5), (1, 8),
                     (2, 9), (14, 5), (5, 12), (13, 11),
                     (10, 12)]
        
        // Solve the puzzle
        app.buttons["peg0"].tap()
        for (firstTap, secondTap) in moves {
            app.buttons["peg\(firstTap)"].tap()
            app.buttons["peg\(secondTap)"].tap()
        }

        // Check win screen contents
        let wintext = app.staticTexts["wintext"]
        XCTAssert(wintext.exists)
        XCTAssertEqual(wintext.label, "You Win!")
        XCTAssert(app.images["winimage"].exists)

        // Dismiss win screen (sheet)
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssert(app.buttons["undo"].isHittable)
        XCTAssert(app.buttons["reset"].isHittable)
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
