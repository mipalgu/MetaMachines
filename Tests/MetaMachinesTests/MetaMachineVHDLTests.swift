// MetaMachineMutationTests.swift
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

/// Test class for the mutation methods using VHDL machines.
final class MetaMachineVHDLTests: XCTestCase {

    /// The URL of the machine.
    let url = URL(fileURLWithPath: "Machine.machine", isDirectory: true)

    /// A meta machine under test.
    lazy var machine = MetaMachine(vhdl: VHDLMachines.Machine.testMachine(path: url))

    /// The default actions in a state.
    let actions = [
        "OnEntry": "",
        "OnExit": "",
        "Internal": "",
        "OnSuspend": "",
        "OnResume": ""
    ]

    /// The default action order in a state.
    let actionOrder = [["OnResume", "OnSuspend"], ["OnEntry"], ["OnExit", "Internal"]]

    /// Initialise the test data.
    override func setUp() {
        self.machine = MetaMachine(vhdl: VHDLMachines.Machine.testMachine(path: url))
    }

    /// Test that the newState function creates the state correctly.
    func testNewState() throws {
        let url = URL(fileURLWithPath: "Machine.machine", isDirectory: true)
        var machine = MetaMachine(vhdl: VHDLMachines.Machine.testMachine(path: url))
        XCTAssertTrue(try machine.newState().get())
        XCTAssertEqual(machine.states.count, 3)
        XCTAssertEqual(machine.states.last, newState())
    }

    /// Test the `newTransition` creates the new transition correctly.
    func testNewTransition() throws {
        XCTAssertFalse(
            try machine.newTransition(source: "Initial", target: "Suspended", condition: "true").get()
        )
        let newTransition = machine.states[0].transitions.last
        let expected = MetaMachines.Transition(
            condition: "true", target: "Suspended", attributes: [], metaData: []
        )
        XCTAssertEqual(newTransition, expected)
        XCTAssertEqual(machine.states.filter { !$0.transitions.isEmpty }.count, 1)
        XCTAssertEqual(machine.states[0].transitions.count, 2)
    }

    /// Test new dependency is added.
    func testNewDependency() throws {
        let oldDependencies = machine.dependencies
        let newDependency = MachineDependency(relativePath: "../NewMachine.machine")
        XCTAssertFalse(try machine.newDependency(newDependency).get())
        XCTAssertEqual(machine.dependencies, oldDependencies + [newDependency])
    }

    /// Test deletes state works correctly.
    func testDeleteStates() throws {
        var initialState = machine.states[0]
        initialState.transitions = []
        let indices = IndexSet(1...2)
        XCTAssertTrue(try machine.newState().get())
        XCTAssertTrue(try machine.delete(states: indices).get())
        XCTAssertEqual(machine.states, [initialState])
        XCTAssertEqual(
            machine.vhdlSchema?.settings.initialState.type, .line(.enumerated(validValues: ["Initial"]))
        )
        XCTAssertEqual(
            machine.vhdlSchema?.settings.suspendedState.type, .line(.enumerated(validValues: ["Initial", ""]))
        )
        XCTAssertEqual(
            machine.attributes[3].attributes["initial_state"],
            .enumerated("Initial", validValues: ["Initial"])
        )
        XCTAssertEqual(
            machine.attributes[3].attributes["suspended_state"], .enumerated("", validValues: ["Initial", ""])
        )
        XCTAssertEqual(
            machine.attributes[3].fields.first { $0.name == "initial_state" }?.type,
            .enumerated(validValues: ["Initial"])
        )
        XCTAssertEqual(
            machine.attributes[3].fields.first { $0.name == "suspended_state" }?.type,
            .enumerated(validValues: ["Initial", ""])
        )
    }

    /// Test deletes state works correctly.
    func testDeleteState() throws {
        var initialState = machine.states[0]
        initialState.transitions = []
        let newState = newState()
        let index = 1
        XCTAssertTrue(try machine.newState().get())
        XCTAssertTrue(try machine.deleteState(atIndex: index).get())
        XCTAssertEqual(machine.states, [initialState, newState])
        XCTAssertEqual(
            machine.vhdlSchema?.settings.initialState.type,
            .line(.enumerated(validValues: ["Initial", "State0"]))
        )
        XCTAssertEqual(
            machine.vhdlSchema?.settings.suspendedState.type,
            .line(.enumerated(validValues: ["Initial", "State0", ""]))
        )
        XCTAssertEqual(
            machine.attributes[3].attributes["initial_state"],
            .enumerated("Initial", validValues: ["Initial", "State0"])
        )
        XCTAssertEqual(
            machine.attributes[3].attributes["suspended_state"],
            .enumerated("", validValues: ["Initial", "State0", ""])
        )
        XCTAssertEqual(
            machine.attributes[3].fields.first { $0.name == "initial_state" }?.type,
            .enumerated(validValues: ["Initial", "State0"])
        )
        XCTAssertEqual(
            machine.attributes[3].fields.first { $0.name == "suspended_state" }?.type,
            .enumerated(validValues: ["Initial", "State0", ""])
        )
    }

    /// Test deleteTransition deletes correct transition.
    func testDeleteTransition() throws {
        var states = machine.states
        states[0].transitions = []
        XCTAssertFalse(try machine.deleteTransition(atIndex: 0, attachedTo: "Initial").get())
        XCTAssertEqual(machine.states, states)
    }

    /// Test changeStateName updates attributes correctly.
    func testChangeStateName() throws {
        var initialState = machine.states[0]
        let newName = "NewInitial"
        initialState.name = newName
        let state2 = machine.states[1]
        XCTAssertTrue(try machine.changeStateName(atIndex: 0, to: newName).get())
        XCTAssertEqual(machine.states, [initialState, state2])
        XCTAssertEqual(
            machine.vhdlSchema?.settings.initialState.type,
            .line(.enumerated(validValues: [newName, state2.name]))
        )
        XCTAssertEqual(
            machine.vhdlSchema?.settings.suspendedState.type,
            .line(.enumerated(validValues: [newName, state2.name, ""]))
        )
        XCTAssertEqual(
            machine.attributes[3].attributes["initial_state"],
            .enumerated(newName, validValues: [newName, state2.name])
        )
        XCTAssertEqual(
            machine.attributes[3].attributes["suspended_state"],
            .enumerated(state2.name, validValues: [newName, state2.name, ""])
        )
        XCTAssertEqual(
            machine.attributes[3].fields.first { $0.name == "initial_state" }?.type,
            .enumerated(validValues: [newName, state2.name])
        )
        XCTAssertEqual(
            machine.attributes[3].fields.first { $0.name == "suspended_state" }?.type,
            .enumerated(validValues: [newName, state2.name, ""])
        )
    }

    /// Test dependency is deleted correctly.
    func testDeleteDependency() throws {
        let dependencies = machine.dependencies
        XCTAssertFalse(try machine.deleteDependency(atIndex: 0).get())
        let newDependencies = Array(dependencies.dropFirst())
        XCTAssertEqual(machine.dependencies, newDependencies)
    }

    /// Test delete depeendencies work correctly.
    func testDeleteDependencies() throws {
        let dependencies = machine.dependencies
        XCTAssertFalse(try machine.delete(dependencies: IndexSet(0...0)).get())
        let newDependencies = Array(dependencies.dropFirst())
        XCTAssertEqual(machine.dependencies, newDependencies)
    }

    /// Test transitions are deleted correctly.
    func testDeleteTransitions() throws {
        let newTransition = MetaMachines.Transition(target: "Suspended")
        machine.states[0].transitions += [newTransition]
        XCTAssertFalse(try machine.delete(transitions: IndexSet(0...1), attachedTo: "Initial").get())
        XCTAssertTrue(machine.states[0].transitions.isEmpty)
    }

    /// Test validation passes.
    func testValidate() throws {
        XCTAssertNoThrow(try machine.validate())
    }

    /// Test addItem works correctly.
    func testAddItem() throws {
        let newItem: [LineAttribute] = [
            .enumerated("in", validValues: ["in", "out", "inout", "buffer"]),
            .expression("std_logic", language: .vhdl),
            .line("z"),
            .expression("'1'", language: .vhdl),
            .line("Signal z.")
        ]
        let path = Path(MetaMachine.self).attributes[0].attributes["external_signals"].wrappedValue.tableValue
        XCTAssertTrue(try machine.addItem(newItem, to: path).get())
        let newExternals: Set<String> = ["x", "y", "z"]
        XCTAssertEqual(
            machine.vhdlSchema?.stateSchema.variables.externals.type,
            .enumerableCollection(validValues: newExternals)
        )
        machine.states.forEach {
            let field = $0.attributes[0].fields.first { $0.name == "externals" }
            XCTAssertEqual(field?.type, .enumerableCollection(validValues: newExternals))
            XCTAssertEqual(
                newExternals, $0.attributes[0].attributes["externals"]?.enumerableCollectionValidValues
            )
        }
    }

    /// Test moveItems works correctly.
    func testMoveItems() throws {
        let path = Path(MetaMachine.self).attributes[0].attributes["external_signals"].wrappedValue.tableValue
        guard
            let firstSignal = machine.attributes[0].attributes["external_signals"]?.tableValue[0],
            let secondSignal = machine.attributes[0].attributes["external_signals"]?.tableValue[1]
        else {
            XCTFail("Failed to get signals.")
            return
        }
        XCTAssertTrue(try machine.moveItems(table: path, from: IndexSet(0...0), to: 2).get())
        let externals: Set<String> = ["x", "y"]
        XCTAssertEqual(
            machine.vhdlSchema?.stateSchema.variables.externals.type,
            .enumerableCollection(validValues: externals)
        )
        machine.states.forEach {
            let field = $0.attributes[0].fields.first { $0.name == "externals" }
            XCTAssertEqual(field?.type, .enumerableCollection(validValues: externals))
            XCTAssertEqual(
                externals, $0.attributes[0].attributes["externals"]?.enumerableCollectionValidValues
            )
        }
        XCTAssertEqual(
            machine.attributes[0].attributes["external_signals"]?.tableValue, [secondSignal, firstSignal]
        )
    }

    /// Test deleteItem works correctly.
    func testDeleteItem() throws {
        let path = Path(MetaMachine.self).attributes[0].attributes["external_signals"].wrappedValue.tableValue
        guard
            let firstSignal = machine.attributes[0].attributes["external_signals"]?.tableValue[0]
        else {
            XCTFail("Couldn't get signal.")
            return
        }
        XCTAssertTrue(try machine.deleteItem(table: path, atIndex: 1).get())
        let externals: Set<String> = ["x"]
        XCTAssertEqual(
            machine.vhdlSchema?.stateSchema.variables.externals.type,
            .enumerableCollection(validValues: externals)
        )
        machine.states.forEach {
            let field = $0.attributes[0].fields.first { $0.name == "externals" }
            XCTAssertEqual(field?.type, .enumerableCollection(validValues: externals))
            XCTAssertEqual(
                externals, $0.attributes[0].attributes["externals"]?.enumerableCollectionValidValues
            )
        }
        XCTAssertEqual(
            machine.attributes[0].attributes["external_signals"]?.tableValue, [firstSignal]
        )
    }

    /// Test deleteItems works correctly.
    func testDeleteItems() throws {
        let path = Path(MetaMachine.self).attributes[0].attributes["external_signals"].wrappedValue.tableValue
        XCTAssertTrue(try machine.deleteItems(table: path, items: IndexSet(0...1)).get())
        let externals: Set<String> = []
        XCTAssertEqual(
            machine.vhdlSchema?.stateSchema.variables.externals.type,
            .enumerableCollection(validValues: externals)
        )
        machine.states.forEach {
            let field = $0.attributes[0].fields.first { $0.name == "externals" }
            XCTAssertEqual(field?.type, .enumerableCollection(validValues: externals))
            XCTAssertEqual(
                externals, $0.attributes[0].attributes["externals"]?.enumerableCollectionValidValues
            )
        }
        XCTAssertEqual(
            machine.attributes[0].attributes["external_signals"]?.tableValue, []
        )
    }

    /// Create a new state.
    private func newState(name: String = "State0") -> MetaMachines.State {
        var vhdlMachine = VHDLMachines.Machine(machine: machine)
        let expectedVHDLState = VHDLMachines.State(
            name: name,
            actions: actions,
            actionOrder: actionOrder,
            signals: [],
            variables: [],
            externalVariables: []
        )
        vhdlMachine.states.append(expectedVHDLState)
        return MetaMachines.State(vhdl: expectedVHDLState, in: vhdlMachine)
    }

}
