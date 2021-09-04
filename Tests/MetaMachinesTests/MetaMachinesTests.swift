import XCTest
@testable import MetaMachines

final class MetaMachinesTests: XCTestCase {
    
    var machine: MetaMachine?
    
    public override func setUp() {
        machine = MetaMachine.initialMachine(forSemantics: .swiftfsm)
        super.setUp()
    }
    
    public static var allTests: [(String, (MetaMachinesTests) -> () throws -> Void)] {
        return [
            ("test_newStateCreatesState", testNewStateCreatesState)
        ]
    }
    
    func testNewStateCreatesState() throws {
        let stateLength = machine?.states.count
        let result = machine?.newState()
        let stateLengthAfterNewState = machine?.states.count
        switch result {
        case .success:
            XCTAssertNotEqual(stateLength, stateLengthAfterNewState)
        case .failure(let error):
            print(error)
            XCTAssertTrue(false)
        default:
            XCTAssertTrue(false)
        }
    }
}
