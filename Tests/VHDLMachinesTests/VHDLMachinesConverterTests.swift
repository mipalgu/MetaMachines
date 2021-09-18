//
//  File.swift
//  File
//
//  Created by Morgan McColl on 18/9/21.
//

import Foundation
import XCTest
@testable import MetaMachines

final class VHDLMachinesConverterTests: XCTestCase {
    
    var machine: MetaMachine?
    var converter: VHDLMachinesConverter?
    
    public override func setUp() {
        machine = MetaMachine.initialMachine(forSemantics: .vhdl)
        converter = VHDLMachinesConverter()
        super.setUp()
    }
    
    public static var allTests: [(String, (VHDLMachinesConverterTests) -> () throws -> Void)] {
        return [
            ("testConverterProducesMachine", testConverterProducesMachine)
        ]
    }
    
    func testConverterProducesMachine() {
        XCTAssertNotNil(machine)
        XCTAssertNotNil(converter)
        let vhdlMachine = try? converter?.convert(machine: machine!)
        XCTAssertNotNil(vhdlMachine)
    }
}
