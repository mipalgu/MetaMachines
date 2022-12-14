@testable import MetaMachines
import XCTest

/// Test class for ``MetaMachine``.
final class MetaMachinesTests: XCTestCase {

    /// The machine under test.
    var machine = MetaMachine.initialMachine(forSemantics: .swiftfsm)

    /// Initialise the machine before every test.
    override func setUp() {
        machine = MetaMachine.initialMachine(forSemantics: .swiftfsm)
    }

    // /// Test new state creation.
    // func testNewStateCreatesState() throws {
    //     let stateLength = machine.states.count
    //     let result = machine.newState()
    //     let stateLengthAfterNewState = machine.states.count
    //     switch result {
    //     case .success:
    //         XCTAssertNotEqual(stateLength, stateLengthAfterNewState)
    //     case .failure(let error):
    //         print(error)
    //         XCTAssertTrue(false)
    //     }
    // }

}
