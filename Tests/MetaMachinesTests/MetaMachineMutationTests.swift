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
import AttributesTestUtils
@testable import MetaMachines
import XCTest

/// Test class for verifying that the ``MetaMachine`` calls the schema functions when using the mutating
/// functions.
final class MetaMachineMutationTests: XCTestCase {

    /// The schemas trigger.
    var trigger = MockTrigger<MetaMachine>()

    /// The schemas validator.
    var validator = NullValidator<MetaMachine>()

    /// The schema.
    lazy var schema = MockSchema(dependencyLayout: [], trigger: trigger, validator: validator)

    /// The machine under test.
    lazy var machine = MetaMachine(
        semantics: .other,
        mutator: SchemaMutator(schema: schema),
        name: "machine",
        initialState: "Initial",
        states: [
            State(name: "Initial", actions: [], transitions: []),
            State(name: "Suspended", actions: [], transitions: [])
        ],
        dependencies: [],
        attributes: [],
        metaData: []
    )

    /// Initialise the machine under test and reset the mocks before every test case.
    override func setUp() {
        self.trigger = MockTrigger()
        self.validator = NullValidator()
        self.schema = MockSchema(dependencyLayout: [], trigger: trigger, validator: validator)
        self.machine = MetaMachine(
            semantics: .other,
            mutator: SchemaMutator(schema: schema),
            name: "machine",
            initialState: "Initial",
            states: [
                State(name: "Initial", actions: [], transitions: []),
                State(name: "Suspended", actions: [], transitions: [])
            ],
            dependencies: [],
            attributes: [],
            metaData: []
        )
    }

    // func testNewStateCallsSchema() throws {
    //     XCTAssertFalse(try machine.newState().get())
    //     XCTAssertEqual(schema.didCreateNewStateTimesCalled, 1)
    //     let newState = State(name: "State0", actions: [], transitions: [], attributes: [], metaData: [])
    //     XCTAssertEqual(
    //         schema.didCreateNewStateCalls.first,
    //         .didCreateNewState(machine: machine, state: newState, index: 1)
    //     )
    // }

    /// Test that the schema is delegated to correctly when a new transition is created.
    func testNewTransitionCallsSchema() throws {
        XCTAssertFalse(
            try machine.newTransition(source: "Initial", target: "Initial", condition: "true").get()
        )
        let newTransition = Transition(condition: "true", target: "Initial", attributes: [], metaData: [])
        XCTAssertEqual(machine.states.first?.transitions, [newTransition])
        XCTAssertEqual(machine.states.count, 2)
        XCTAssertEqual(
            schema.functionsCalled,
            [
                .didCreateNewTransition(
                    machine: machine, transition: newTransition, stateIndex: 0, transitionIndex: 0
                ),
                .update(metaMachine: machine),
                .makeValidator(root: machine)
            ]
        )
        XCTAssertEqual(validator.parameters, [machine])
    }

    /// Test new dependency calls schema properly.
    func testNewDependency() throws {
        let newDependency = MachineDependency(relativePath: "../NewMachine.machine")
        XCTAssertFalse(try machine.newDependency(newDependency).get())
        XCTAssertEqual(machine.dependencies, [newDependency])
        XCTAssertEqual(
            schema.functionsCalled,
            self.functionsCalled(prefixed: [
                .didCreateDependency(machine: machine, dependency: newDependency, index: 0)
            ])
        )
        XCTAssertEqual(validator.parameters, [machine])
    }

    /// Test delete(states:) calls schema correctly.
    func testDeleteStates() throws {
        let indices = IndexSet(1...1)
        let initial = machine.states[0]
        let state = machine.states[1]
        XCTAssertFalse(try machine.delete(states: indices).get())
        XCTAssertEqual(machine.states, [initial])
        XCTAssertEqual(
            schema.functionsCalled,
            self.functionsCalled(prefixed: [.didDeleteStates(machine: machine, state: [state], at: indices)])
        )
        XCTAssertEqual(validator.parameters, [machine])
    }

    /// Test deleteState calls schema correctly.
    func testDeleteState() throws {
        let index = 1
        let initial = machine.states[0]
        let state = machine.states[1]
        XCTAssertFalse(try machine.deleteState(atIndex: index).get())
        XCTAssertEqual(machine.states, [initial])
        XCTAssertEqual(
            schema.functionsCalled,
            self.functionsCalled(prefixed: [.didDeleteState(machine: machine, state: state, at: index)])
        )
        XCTAssertEqual(validator.parameters, [machine])
    }

    /// Test deleteTransition calls schema correctly.
    func testDeleteTransition() throws {
        let index = 0
        let transition = Transition(target: "Initial")
        machine.states[0].transitions = [transition]
        XCTAssertFalse(try machine.deleteTransition(atIndex: index, attachedTo: "Initial").get())
        XCTAssertTrue(self.machine.states[0].transitions.isEmpty)
        XCTAssertEqual(schema.functionsCalled, self.functionsCalled(
            prefixed: [
                .didDeleteTransition(machine: machine, transition: transition, stateIndex: 0, at: index)
            ]
        ))
        XCTAssertEqual(validator.parameters, [machine])
    }

    /// Test changeStateName calls schema correctly.
    func testChangeStateName() throws {
        var initialState = machine.states[0]
        let newName = "NewInitial"
        initialState.name = newName
        let state2 = machine.states[1]
        XCTAssertFalse(try machine.changeStateName(atIndex: 0, to: newName).get())
        XCTAssertEqual(machine.states, [initialState, state2])
        XCTAssertEqual(schema.functionsCalled, self.functionsCalled(
            prefixed: [
                .didChangeStatesName(machine: machine, state: initialState, index: 0, oldName: "Initial")
            ]
        ))
        XCTAssertEqual(validator.parameters, [machine])
    }

    /// Test deleteDependency calls schema correctly.
    func testDeleteDependency() throws {
        let dependency = MachineDependency(relativePath: "../NewMachine.machine")
        machine.dependencies = [dependency]
        XCTAssertFalse(try machine.deleteDependency(atIndex: 0).get())
        XCTAssertTrue(machine.dependencies.isEmpty)
        XCTAssertEqual(schema.functionsCalled, self.functionsCalled(
            prefixed: [
                .didDeleteDependency(machine: machine, dependency: dependency, at: 0)
            ]
        ))
        XCTAssertEqual(validator.parameters, [machine])
    }

    /// Prefix the functions called to update and validate.
    private func functionsCalled(prefixed: [MockSchema.FunctionsCalled]) -> [MockSchema.FunctionsCalled] {
        prefixed + [.update(metaMachine: machine), .makeValidator(root: machine)]
    }

}
