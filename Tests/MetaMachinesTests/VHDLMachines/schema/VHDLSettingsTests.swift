// VHDLSettingsTests.swift
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

/// Test class for ``VHDLSettings``.
final class VHDLSettingsTests: XCTestCase {

    /// The URL of the machine.
    let url = URL(fileURLWithPath: "Machine.machine", isDirectory: true)

    /// A meta machine to use as test data.
    lazy var machine = MetaMachine(vhdl: VHDLMachines.Machine.testMachine(path: url))

    /// The schema group under test.
    let settings = VHDLSettings()

    /// The expected group.
    var expected: AttributeGroup {
        machine.attributes[3]
    }

    /// Initialise the test data.
    override func setUp() {
        self.machine = MetaMachine(vhdl: VHDLMachines.Machine.testMachine(path: url))
    }

    /// Test that the path is correct.
    func testPathIsCorrect() {
        XCTAssertEqual(machine[keyPath: settings.path.keyPath], expected)
    }

    /// Test properties are correct type.
    func testInitialPropertiesAreCorrect() {
        XCTAssertEqual(settings.suspendedState.label, "suspended_state")
        XCTAssertEqual(settings.suspendedState.type, .enumerated(validValues: []))
        XCTAssertEqual(settings.initialState.label, "initial_state")
        XCTAssertEqual(settings.initialState.type, .enumerated(validValues: []))
    }

    /// Test the group is set up correctly when loaded from a machine.
    func testInitialPropertiesAreUpdatedFromMachine() {
        guard let settings = (machine.mutator as? SchemaMutator<VHDLSchema>)?.schema.settings else {
            XCTFail("Could not get settings from machine.")
            return
        }
        let states: Set<String> = ["Initial", "Suspended"]
        let suspendedStates: Set<String> = ["Initial", "Suspended", ""]
        XCTAssertEqual(settings.suspendedState.label, "suspended_state")
        XCTAssertEqual(settings.suspendedState.type, .enumerated(validValues: suspendedStates))
        XCTAssertEqual(settings.initialState.label, "initial_state")
        XCTAssertEqual(settings.initialState.type, .enumerated(validValues: states))
    }

    // /// Test initial schema fails validation.
    // func testInitialSchemaFailsValidation() throws {
    //     XCTAssertThrowsError(try settings.propertiesValidator.performValidation(expected))
    // }

    /// Test the validation passes for correct machine.
    func testValidationPasses() throws {
        guard let settings = (machine.mutator as? SchemaMutator<VHDLSchema>)?.schema.settings else {
            XCTFail("Could not get settings from machine.")
            return
        }
        XCTAssertNoThrow(try settings.propertiesValidator.performValidation(expected))
    }

    /// Test that the validation fails for empty initial state.
    func testValidationFailsForEmptyInitialState() {
        var expected = expected
        guard var values = expected.attributes["initial_state"]?.enumeratedValidValues else {
            XCTFail("Could not get valid values in initial_state.")
            return
        }
        values.remove("") // Make sure this is not in the valid values.
        expected.attributes["initial_state"] = .enumerated("", validValues: values)
        XCTAssertThrowsError(try settings.propertiesValidator.performValidation(expected))
    }

    /// Test trigger only fires for correct paths.
    func testTriggerPaths() {
        guard
            let trigger = (machine.mutator as? SchemaMutator<VHDLSchema>)?.schema.settings.allTriggers
        else {
            XCTFail("Could not get settings from machine.")
            return
        }
        let path = Path(MetaMachine.self)
        XCTAssertFalse(trigger.isTriggerForPath(AnyPath(path), in: machine))
        XCTAssertTrue(trigger.isTriggerForPath(AnyPath(path.states), in: machine))
    }

    /// Test that the initial and suspended state settings are updated when a new state is added.
    func testValidValuesAreUpdatedOnNewState() throws {
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
        guard
            let trigger = (machine.mutator as? SchemaMutator<VHDLSchema>)?.schema.settings.allTriggers
        else {
            XCTFail("Could not get settings from machine.")
            return
        }
        XCTAssertTrue(trigger.isTriggerForPath(path, in: machine))
        XCTAssertTrue(try trigger.performTrigger(&machine, for: path).get())
        let initialState = machine.attributes[3].attributes["initial_state"]
        let newValidValues: Set<String> = ["Initial", "Suspended", "State0"]
        let suspendedValidValues: Set<String> = ["Initial", "Suspended", "State0", ""]
        XCTAssertEqual(initialState?.enumeratedValidValues, newValidValues)
        XCTAssertEqual(initialState?.enumeratedValue, "Initial")
        let fields = machine.attributes[3].fields
        let initialField = fields.first { $0.name == "initial_state" }
        let suspendedField = fields.first { $0.name == "suspended_state" }
        XCTAssertEqual(initialField?.type, .enumerated(validValues: newValidValues))
        XCTAssertEqual(suspendedField?.type, .enumerated(validValues: suspendedValidValues))
        let suspendedState = machine.attributes[3].attributes["suspended_state"]
        XCTAssertEqual(suspendedState?.enumeratedValidValues, suspendedValidValues)
        XCTAssertEqual(suspendedState?.enumeratedValue, "Suspended")
        guard let settings = (machine.mutator as? SchemaMutator<VHDLSchema>)?.schema.settings else {
            XCTFail("Could not get settings from machine.")
            return
        }
        XCTAssertEqual(settings.initialState.type, .enumerated(validValues: newValidValues))
        XCTAssertEqual(settings.suspendedState.type, .enumerated(validValues: suspendedValidValues))
    }

    /// Test that the initial and suspended state settings are updated when a state is deleted.
    func testValidValuesAreUpdatedOnDeletedState() throws {
        _ = machine.states.remove(at: 0)
        let path = AnyPath(Path(MetaMachine.self).states[0])
        guard
            let trigger = (machine.mutator as? SchemaMutator<VHDLSchema>)?.schema.settings.allTriggers
        else {
            XCTFail("Could not get settings from machine.")
            return
        }
        XCTAssertTrue(trigger.isTriggerForPath(path, in: machine))
        XCTAssertTrue(try trigger.performTrigger(&machine, for: path).get())
        let initialState = machine.attributes[3].attributes["initial_state"]
        let newValidValues: Set<String> = ["Suspended"]
        let suspendedValidValues: Set<String> = ["Suspended", ""]
        XCTAssertEqual(initialState?.enumeratedValidValues, newValidValues)
        XCTAssertEqual(initialState?.enumeratedValue, "Suspended")
        let fields = machine.attributes[3].fields
        let initialField = fields.first { $0.name == "initial_state" }
        let suspendedField = fields.first { $0.name == "suspended_state" }
        XCTAssertEqual(initialField?.type, .enumerated(validValues: newValidValues))
        XCTAssertEqual(suspendedField?.type, .enumerated(validValues: suspendedValidValues))
        let suspendedState = machine.attributes[3].attributes["suspended_state"]
        XCTAssertEqual(suspendedState?.enumeratedValidValues, suspendedValidValues)
        XCTAssertEqual(suspendedState?.enumeratedValue, "Suspended")
        guard let settings = (machine.mutator as? SchemaMutator<VHDLSchema>)?.schema.settings else {
            XCTFail("Could not get settings from machine.")
            return
        }
        XCTAssertEqual(settings.initialState.type, .enumerated(validValues: newValidValues))
        XCTAssertEqual(settings.suspendedState.type, .enumerated(validValues: suspendedValidValues))
    }

    /// Test that the initial and suspended state settings are updated when a state is renamed.
    func testValidValuesAreUpdatedOnRenamedState() throws {
        machine.states[0].name = "zState0"
        let path = AnyPath(Path(MetaMachine.self).states[0].name)
        guard
            let trigger = (machine.mutator as? SchemaMutator<VHDLSchema>)?.schema.settings.allTriggers
        else {
            XCTFail("Could not get settings from machine.")
            return
        }
        XCTAssertTrue(trigger.isTriggerForPath(path, in: machine))
        XCTAssertTrue(try trigger.performTrigger(&machine, for: path).get())
        let initialState = machine.attributes[3].attributes["initial_state"]
        let newValidValues: Set<String> = ["zState0", "Suspended"]
        let suspendedValidValues: Set<String> = ["zState0", "Suspended", ""]
        XCTAssertEqual(initialState?.enumeratedValidValues, newValidValues)
        XCTAssertEqual(initialState?.enumeratedValue, "zState0")
        let fields = machine.attributes[3].fields
        let initialField = fields.first { $0.name == "initial_state" }
        let suspendedField = fields.first { $0.name == "suspended_state" }
        XCTAssertEqual(initialField?.type, .enumerated(validValues: newValidValues))
        XCTAssertEqual(suspendedField?.type, .enumerated(validValues: suspendedValidValues))
        let suspendedState = machine.attributes[3].attributes["suspended_state"]
        XCTAssertEqual(suspendedState?.enumeratedValidValues, suspendedValidValues)
        XCTAssertEqual(suspendedState?.enumeratedValue, "Suspended")
        guard let settings = (machine.mutator as? SchemaMutator<VHDLSchema>)?.schema.settings else {
            XCTFail("Could not get settings from machine.")
            return
        }
        XCTAssertEqual(settings.initialState.type, .enumerated(validValues: newValidValues))
        XCTAssertEqual(settings.suspendedState.type, .enumerated(validValues: suspendedValidValues))
    }

}
