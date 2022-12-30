// VHDLSchemaTests.swift
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

/// Test class for ``VHDLSchema``.
final class VHDLSchemaTests: XCTestCase {

    /// The URL of the machine.
    let url = URL(fileURLWithPath: "Machine.machine", isDirectory: true)

    /// A meta machine to use as test data.
    lazy var machine = MetaMachine(vhdl: VHDLMachines.Machine.testMachine(path: url))

    /// The schema containing the group.
    var schema: VHDLSchema? {
        get {
            machine.vhdlSchema
        }
        set {
            machine.vhdlSchema = newValue
        }
    }

    /// Initialise the test data.
    override func setUp() {
        self.machine = MetaMachine(vhdl: VHDLMachines.Machine.testMachine(path: url))
    }

    /// Test that settings triggers are available in top-level schema.
    func testTriggersAddStatesCorrectlyManually() {
        let actions = machine.states[0].actions
        let transitions = machine.states[0].transitions
        let newState = MetaMachines.State(
            name: "State0",
            actions: actions,
            transitions: transitions,
            attributes: VHDLMachines.State.testAttributes(name: "State0")
        )
        machine.states.append(newState)
        let path = AnyPath(Path(MetaMachine.self).states[3])
        guard let trigger = schema?.trigger else {
            XCTFail("Failed to get trigger!")
            return
        }
        XCTAssertTrue(trigger.isTriggerForPath(path, in: machine))
        XCTAssertTrue(try trigger.performTrigger(&machine, for: path).get())
        let initialState = machine.attributes[3].attributes["initial_state"]
        let newValidValues: Set<String> = ["Initial", "Suspended", "State0"]
        XCTAssertEqual(initialState?.enumeratedValidValues, newValidValues)
        XCTAssertEqual(initialState?.enumeratedValue, "Initial")
        let suspendedState = machine.attributes[3].attributes["suspended_state"]
        XCTAssertEqual(suspendedState?.enumeratedValidValues, newValidValues)
        XCTAssertEqual(suspendedState?.enumeratedValue, "Suspended")
        guard let settings = schema?.settings else {
            XCTFail("Could not get settings from machine.")
            return
        }
        XCTAssertEqual(settings.initialState.type, .enumerated(validValues: newValidValues))
        XCTAssertEqual(settings.suspendedState.type, .enumerated(validValues: newValidValues))
    }

    /// Test that settings triggers are available using delegates.
    func testTriggersAddStatesCorrectly() throws {
        let actions = machine.states[0].actions
        let transitions = machine.states[0].transitions
        let newState = MetaMachines.State(
            name: "State0",
            actions: actions,
            transitions: transitions,
            attributes: VHDLMachines.State.testAttributes(name: "State0")
        )
        machine.states.append(newState)
        XCTAssertTrue(
            try schema?.didCreateNewState(machine: &machine, state: newState, index: 2).get() ?? false
        )
        let initialState = machine.attributes[3].attributes["initial_state"]
        let newValidValues: Set<String> = ["Initial", "Suspended", "State0"]
        XCTAssertEqual(initialState?.enumeratedValidValues, newValidValues)
        XCTAssertEqual(initialState?.enumeratedValue, "Initial")
        let suspendedState = machine.attributes[3].attributes["suspended_state"]
        XCTAssertEqual(suspendedState?.enumeratedValidValues, newValidValues)
        XCTAssertEqual(suspendedState?.enumeratedValue, "Suspended")
        guard let settings = self.schema?.settings else {
            XCTFail("Could not get settings from machine.")
            return
        }
        XCTAssertEqual(settings.initialState.type, .enumerated(validValues: newValidValues))
        XCTAssertEqual(settings.suspendedState.type, .enumerated(validValues: newValidValues))
        try schema?.makeValidator(root: machine).performValidation(machine)
    }

    /// Make sure triggers fire correctly when a state is deleted.
    func testInitialStateDeletion() throws {
        let removedState = machine.states.remove(at: 0)
        XCTAssertTrue(
            try schema?.didDeleteState(machine: &machine, state: removedState, at: 0).get() ?? false
        )
        let initialState = machine.attributes[3].attributes["initial_state"]
        let newValidValues: Set<String> = ["Suspended"]
        XCTAssertEqual(initialState?.enumeratedValidValues, newValidValues)
        XCTAssertEqual(initialState?.enumeratedValue, "Suspended")
        let suspendedState = machine.attributes[3].attributes["suspended_state"]
        XCTAssertEqual(suspendedState?.enumeratedValidValues, newValidValues)
        XCTAssertEqual(suspendedState?.enumeratedValue, "Suspended")
        guard let settings = self.schema?.settings else {
            XCTFail("Could not get settings from machine.")
            return
        }
        XCTAssertEqual(settings.initialState.type, .enumerated(validValues: newValidValues))
        XCTAssertEqual(settings.suspendedState.type, .enumerated(validValues: newValidValues))
        try schema?.makeValidator(root: machine).performValidation(machine)
    }

    /// Make sure triggers fire when an external variable is deleted.
    func testDeleteExternalVariables() throws {
        let path = Path(MetaMachine.self)
            .attributes[0].attributes["external_signals"].wrappedValue.tableValue
        guard
            let attribute = machine.attributes[0].attributes["external_signals"]?.tableValue.remove(at: 0)
        else {
            XCTFail("Didn't delete attribute.")
            return
        }
        var mutator = machine.mutator
        XCTAssertTrue(
            try mutator.didDeleteItem(attribute: path, atIndex: 0, machine: &machine, item: attribute).get()
        )
        guard let externals = machine.attributes[0].attributes["external_signals"]?.tableValue else {
            XCTFail("Cannot get externals!")
            return
        }
        XCTAssertEqual(externals.count, 1)
        let externalNames = Set(externals.map { $0[2].lineValue })
        machine.states.forEach {
            let stateExternals = $0.attributes[0].attributes["externals"]
            XCTAssertEqual(stateExternals?.enumerableCollectionValidValues, externalNames)
            XCTAssertTrue(
                stateExternals?.enumerableCollectionValue.allSatisfy { externalNames.contains($0) } ?? false
            )
        }
        XCTAssertEqual(
            schema?.stateSchema.variables.externals.type, .enumerableCollection(validValues: externalNames)
        )
        XCTAssertEqual(
            (mutator as? SchemaMutator<VHDLSchema>)?.schema.stateSchema.variables.externals.type,
            .enumerableCollection(validValues: externalNames)
        )
        try schema?.makeValidator(root: machine).performValidation(machine)
    }

    /// Make sure initial machine passes validation.
    func testInitialMachinePassesValidation() {
        let machine = MetaMachine.initialMachine(forSemantics: .vhdl)
        let validator = schema?.makeValidator(root: machine)
        XCTAssertNotNil(validator)
        XCTAssertNoThrow(try validator?.performValidation(machine))
    }

}
