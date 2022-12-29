// VHDLStateActionsTests.swift
// MetaMachines
// 
// Created by Morgan McColl.
// Copyright © 2022 Morgan McColl. All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above
//    copyright notice, this list of conditions and the following
//    disclaimer in the documentation and/or other materials
//    provided with the distribution.
// 
// 3. All advertising materials mentioning features or use of this
//    software must display the following acknowledgement:
// 
//    This product includes software developed by Morgan McColl.
// 
// 4. Neither the name of the author nor the names of contributors
//    may be used to endorse or promote products derived from this
//    software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// 
// -----------------------------------------------------------------------
// This program is free software; you can redistribute it and/or
// modify it under the above terms or under the terms of the GNU
// General Public License as published by the Free Software Foundation;
// either version 2 of the License, or (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, see http://www.gnu.org/licenses/
// or write to the Free Software Foundation, Inc., 51 Franklin Street,
// Fifth Floor, Boston, MA  02110-1301, USA.
// 

import Attributes
@testable import MetaMachines
import VHDLMachines
import XCTest

/// Test class for ``VHDLStateActions``.
final class VHDLStateActionsTests: XCTestCase {

    /// The URL of the machine.
    let url = URL(fileURLWithPath: "Machine.machine", isDirectory: true)

    /// A meta machine to use as test data.
    lazy var machine = MetaMachine(vhdl: VHDLMachines.Machine.testMachine(path: url))

    /// The action names in the states.
    let actionNames: Set<String> = ["OnEntry", "OnExit", "Internal", "OnSuspend", "OnResume"]

    /// The schema group under test.
    var actions: VHDLStateActions? {
        (machine.mutator as? SchemaMutator<VHDLSchema>)?.schema.stateSchema.actions
    }

    /// Initialise the test data.
    override func setUp() {
        self.machine = MetaMachine(vhdl: VHDLMachines.Machine.testMachine(path: url))
    }

    /// Test path points to correct attribute groups.
    func testPath() {
        let expected = [
            Path(MetaMachine.self).states[0].attributes[1],
            Path(MetaMachine.self).states[1].attributes[1]
        ]
        XCTAssertEqual(actions?.path.paths(in: machine), expected)
    }

    /// Test properties are setup correctly.
    func testProperties() {
        guard let actions = actions else {
            XCTFail("Failed to get group.")
            return
        }
        XCTAssertEqual(actions.actionNames.label, "action_names")
        XCTAssertEqual(actions.actionNames.type, .table(columns: [("name", .line)]))
        XCTAssertEqual(actions.actionOrder.label, "action_order")
        XCTAssertEqual(
            actions.actionOrder.type,
            .table(columns: [("timeslot", .integer), ("action", .enumerated(validValues: actionNames))])
        )
    }

    /// Check that the test machines states pass validation.
    func testStatesPassValidation() throws {
        guard let validator = actions?.propertiesValidator else {
            XCTFail("Could not get validator.")
            return
        }
        try machine.states.forEach {
            XCTAssertNoThrow(try validator.performValidation($0.attributes[1]))
            XCTAssertNoThrow(try validator.performValidation($0.attributes[1]))
        }
    }

    /// Test action names must not be a reserved word.
    func testNameValidationRules() throws {
        guard let validator = actions?.actionNames.validate else {
            XCTFail("Could not get validator.")
            return
        }
        try [
            nameTable(name: "a%^&"),
            nameTable(name: "std_logic"),
            nameTable(name: "integer"),
            nameTable(name: "abs"),
            nameTable(name: "")
        ]
        .forEach {
            XCTAssertThrowsError(try validator.performValidation($0))
        }
        try [
            nameTable(name: "x"),
            nameTable(name: "y"),
            nameTable(name: "x_1"),
            nameTable(name: "_x"),
            nameTable(name: "abs3")
        ]
        .forEach {
            XCTAssertNoThrow(try validator.performValidation($0))
        }
    }

    /// Test timeslot rules limit timeslot to a positive integer between 0 and 255 inclusive.
    func testOrderTimeslotRules() throws {
        guard let validator = actions?.actionOrder.validate else {
            XCTFail("Could not get validator.")
            return
        }
        try [
            orderTable(timeslot: 256),
            orderTable(timeslot: -1),
            orderTable(timeslot: -255),
            orderTable(timeslot: -500)
        ]
        .forEach {
            XCTAssertThrowsError(try validator.performValidation($0))
        }
        try [
            orderTable(timeslot: 0),
            orderTable(timeslot: 255),
            orderTable(timeslot: 100),
            orderTable(timeslot: 10),
            orderTable(timeslot: 254)
        ]
        .forEach {
            XCTAssertNoThrow(try validator.performValidation($0))
        }
    }

    /// Test action rules limit action to a valid action name.
    func testOrderActionRules() throws {
        guard let validator = actions?.actionOrder.validate else {
            XCTFail("Could not get validator.")
            return
        }
        try [
            orderTable(action: "OnInternal"),
            orderTable(action: "onentry"),
            orderTable(action: "internal"),
            orderTable(action: "on_entry"),
            orderTable(action: "_21345_"),
            orderTable(action: "OnExitAndInternal")
        ]
        .forEach {
            XCTAssertThrowsError(try validator.performValidation($0))
        }
        try [
            orderTable(action: "OnEntry"),
            orderTable(action: "OnExit"),
            orderTable(action: "Internal"),
            orderTable(action: "OnSuspend"),
            orderTable(action: "OnResume")
        ]
        .forEach {
            XCTAssertNoThrow(try validator.performValidation($0))
        }
    }

    /// Test that the action_order fails to validate when empty.
    func testOrderFailsValidationWhenEmpty() throws {
        guard let validator = actions?.actionOrder.validate else {
            XCTFail("Could not get validator.")
            return
        }
        XCTAssertThrowsError(
            try validator.performValidation(
                .table(
                    [], columns: [("timeslot", .integer), ("action", .enumerated(validValues: actionNames))]
                )
            )
        )
    }

    /// Create a table for a action names.
    private func nameTable(name: String) -> Attribute {
        let row: [LineAttribute] = [.line(name)]
        return .table([row], columns: [("name", .line)])
    }

    /// Create a table for a action order.
    private func orderTable(timeslot: Int = 0, action: String = "OnEntry") -> Attribute {
        let row: [LineAttribute] = [.integer(timeslot), .enumerated(action, validValues: actionNames)]
        return .table(
            [row], columns: [("timeslot", .integer), ("action", .enumerated(validValues: actionNames))]
        )
    }

}
