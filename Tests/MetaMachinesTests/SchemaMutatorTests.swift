// SchemaMutatorTests.swift
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

/// Test class for ``SchemaMutator``.
final class SchemaMutatorTests: XCTestCase {

    /// The trigger used in the schema.
    var trigger = MockTrigger<MetaMachine>()

    /// The validator used in the schema.
    var validator = NullValidator<MetaMachine>()

    /// A mock machine schema.
    lazy var schema = MockSchema(dependencyLayout: [], trigger: trigger, validator: validator)

    /// The mutator under test.
    lazy var mutator = SchemaMutator(schema: schema)

    /// A test machine.
    var machine = MetaMachine.initialMachine(forSemantics: .vhdl)

    /// A test dependency.
    var dependency = MachineDependency(relativePath: "dependency")

    /// Initialise the mutator under test.
    override func setUp() {
        self.trigger = MockTrigger()
        self.validator = NullValidator()
        self.schema = MockSchema(dependencyLayout: [], trigger: trigger, validator: validator)
        self.mutator = SchemaMutator(schema: schema)
        self.machine = MetaMachine.initialMachine(forSemantics: .vhdl)
        self.dependency = MachineDependency(relativePath: "dependency")
    }

    /// Test mutator sets stored properties correctly.
    func testInit() {
        let fields = [Field(name: "test", type: .line)]
        let schema = MockSchema(dependencyLayout: fields, trigger: trigger, validator: validator)
        let mutator = SchemaMutator(schema: schema)
        XCTAssertEqual(mutator.dependencyLayout, fields)
        XCTAssertIdentical(mutator.schema, schema)
    }

    /// Test the `didCreateDependency` function delegates to the schema.
    func testDidCreateDependencyDelegatesToSchema() throws {
        let expected = MockSchema.FunctionsCalled.didCreateDependency(
            machine: machine, dependency: dependency, index: 1
        )
        try self.performTest(
            expectedCall: expected,
            call: { mutator.didCreateDependency(machine: &machine, dependency: dependency, index: 1) },
            getFns: { schema.didCreateDependencyCalls }
        )
    }

    /// Test the `didCreateNewState` function delegates to the schema.
    func testDidCreateNewStateDelegatesToSchema() throws {
        let state = State(name: "Initial", actions: [], transitions: [])
        let expected = MockSchema.FunctionsCalled.didCreateNewState(machine: machine, state: state, index: 0)
        try self.performTest(
            expectedCall: expected,
            call: { mutator.didCreateNewState(machine: &machine, state: state, index: 0) },
            getFns: { schema.didCreateNewStateCalls }
        )
    }

    /// Test the `didChangStateName` function delegates to the schema.
    func testDidChangStateNameDelegatesToSchema() throws {
        let state = State(name: "Initial", actions: [], transitions: [])
        let expected = MockSchema.FunctionsCalled.didChangeStatesName(
            machine: machine, state: state, index: 0, oldName: "Old"
        )
        try self.performTest(
            expectedCall: expected,
            call: { mutator.didChangeStatesName(machine: &machine, state: state, index: 0, oldName: "Old") },
            getFns: { schema.didChangeStatesNameCalls }
        )
    }

    /// Test the `didCreateNewTransition` function delegates to the schema.
    func testDidCreateNewTransitionDelegatesToSchema() throws {
        let transition = Transition(target: "Initial")
        let expected = MockSchema.FunctionsCalled.didCreateNewTransition(
            machine: machine, transition: transition, stateIndex: 1, transitionIndex: 2
        )
        try self.performTest(
            expectedCall: expected,
            call: {
                mutator.didCreateNewTransition(
                    machine: &machine, transition: transition, stateIndex: 1, transitionIndex: 2
                )
            },
            getFns: { schema.didCreateNewTransitionCalls }
        )
    }

    /// Test the `didDeleteDependencies` function delegates to the schema.
    func testDidDeleteDependenciesDelegatesToSchema() throws {
        let indexes = IndexSet(0...1)
        let expected = MockSchema.FunctionsCalled.didDeleteDependencies(
            machine: machine, dependency: [dependency], at: indexes
        )
        try self.performTest(
            expectedCall: expected,
            call: { mutator.didDeleteDependencies(machine: &machine, dependency: [dependency], at: indexes) },
            getFns: { schema.didDeleteDependenciesCalls }
        )
    }

    /// Test the `didDeleteStates` function delegates to the schema.
    func testDidDeleteStatesDelegatesToSchema() throws {
        let indexes = IndexSet(0...1)
        let state = State(name: "Initial", actions: [], transitions: [])
        let expected = MockSchema.FunctionsCalled.didDeleteStates(
            machine: machine, state: [state], at: indexes
        )
        try self.performTest(
            expectedCall: expected,
            call: { mutator.didDeleteStates(machine: &machine, state: [state], at: indexes) },
            getFns: { schema.didDeleteStatesCalls }
        )
    }

    /// Test the `didDeleteTransitions` function delegates to the schema.
    func testDidDeleteTransitionsDelegatesToSchema() throws {
        let indexes = IndexSet(0...1)
        let transition = Transition(target: "Initial")
        let expected = MockSchema.FunctionsCalled.didDeleteTransitions(
            machine: machine, transition: [transition], stateIndex: 1, at: indexes
        )
        try self.performTest(
            expectedCall: expected,
            call: {
                mutator.didDeleteTransitions(
                    machine: &machine, transition: [transition], stateIndex: 1, at: indexes
                )
            },
            getFns: { schema.didDeleteTransitionsCalls }
        )
    }

    /// Test the `didDeleteDependency` function delegates to the schema.
    func testDidDeleteDependencyDelegatesToSchema() throws {
        let expected = MockSchema.FunctionsCalled.didDeleteDependency(
            machine: machine, dependency: dependency, at: 1
        )
        try self.performTest(
            expectedCall: expected,
            call: { mutator.didDeleteDependency(machine: &machine, dependency: dependency, at: 1) },
            getFns: { schema.didDeleteDependencyCalls }
        )
    }

    /// Test the `didDeleteState` function delegates to the schema.
    func testDidDeleteStateDelegatesToSchema() throws {
        let state = State(name: "Initial", actions: [], transitions: [])
        let expected = MockSchema.FunctionsCalled.didDeleteState(machine: machine, state: state, at: 1)
        try self.performTest(
            expectedCall: expected,
            call: { mutator.didDeleteState(machine: &machine, state: state, at: 1) },
            getFns: { schema.didDeleteStateCalls }
        )
    }

    /// Test the `didDeleteTransition` function delegates to the schema.
    func testDidDeleteTransitionDelegatesToSchema() throws {
        let transition = Transition(target: "Initial")
        let expected = MockSchema.FunctionsCalled.didDeleteTransition(
            machine: machine, transition: transition, stateIndex: 1, at: 2
        )
        try self.performTest(
            expectedCall: expected,
            call: {
                mutator.didDeleteTransition(machine: &machine, transition: transition, stateIndex: 1, at: 2)
            },
            getFns: { schema.didDeleteTransitionCalls }
        )
    }

    /// Test the `didAddItem` function delegates to the schema.
    func testDidAddItemDelegatesToSchema() throws {
        let state = State(name: "Initial", actions: [], transitions: [])
        let path = Path(MetaMachine.self).states
        let expected = MockSchema.FunctionsCalled.trigger
        try self.performTest(
            expectedCall: expected,
            call: { mutator.didAddItem(state, to: path, machine: &machine) },
            getFns: { schema.triggerCalls }
        )
        XCTAssertEqual(trigger.timesCalled, 1)
        XCTAssertEqual(trigger.pathPassed, AnyPath(path))
        XCTAssertEqual(trigger.rootPassed, machine)
    }

    /// Test the `didDeleteItem` function delegates to the schema.
    func testDidDeleteItemDelegatesToSchema() throws {
        let state = State(name: "Initial", actions: [], transitions: [])
        let path = Path(MetaMachine.self).states
        let expected = MockSchema.FunctionsCalled.trigger
        try self.performTest(
            expectedCall: expected,
            call: { mutator.didDeleteItem(attribute: path, atIndex: 1, machine: &machine, item: state) },
            getFns: { schema.triggerCalls }
        )
        XCTAssertEqual(trigger.timesCalled, 1)
        XCTAssertEqual(trigger.pathPassed, AnyPath(path))
        XCTAssertEqual(trigger.rootPassed, machine)
    }

    /// Test the `didDeleteItems` function delegates to the schema.
    func testDidDeleteItemsDelegatesToSchema() throws {
        let indexes = IndexSet(0...1)
        let state = State(name: "Initial", actions: [], transitions: [])
        let path = Path(MetaMachine.self).states
        let expected = MockSchema.FunctionsCalled.trigger
        try self.performTest(
            expectedCall: expected,
            call: {
                mutator.didDeleteItems(table: path, indices: indexes, machine: &machine, items: [state])
            },
            getFns: { schema.triggerCalls }
        )
        XCTAssertEqual(trigger.timesCalled, 1)
        XCTAssertEqual(trigger.pathPassed, AnyPath(path))
        XCTAssertEqual(trigger.rootPassed, machine)
    }

    /// Test the `didMoveItems` function delegates to the schema.
    func testDidMoveItemsDelegatesToSchema() throws {
        let indexes = IndexSet(0...1)
        let state = State(name: "Initial", actions: [], transitions: [])
        let path = Path(MetaMachine.self).states
        let expected = MockSchema.FunctionsCalled.trigger
        try self.performTest(
            expectedCall: expected,
            call: {
                mutator.didMoveItems(attribute: path, machine: &machine, from: indexes, to: 1, items: [state])
            },
            getFns: { schema.triggerCalls }
        )
        XCTAssertEqual(trigger.timesCalled, 1)
        XCTAssertEqual(trigger.pathPassed, AnyPath(path))
        XCTAssertEqual(trigger.rootPassed, machine)
    }

    /// Test the `didModify` function delegates to the schema.
    func testDidModifyDelegatesToSchema() throws {
        let path = Path(MetaMachine.self).states[0].name
        let expected = MockSchema.FunctionsCalled.trigger
        try self.performTest(
            expectedCall: expected,
            call: { mutator.didModify(attribute: path, oldValue: "", newValue: "", machine: &machine) },
            getFns: { schema.triggerCalls }
        )
        XCTAssertEqual(trigger.timesCalled, 1)
        XCTAssertEqual(trigger.pathPassed, AnyPath(path))
        XCTAssertEqual(trigger.rootPassed, machine)
    }

    /// Test mutator delegates to the schema for the `makeValidator` function.
    func testSchemaMutatorUsesSchemaValidator() throws {
        try mutator.validate(machine: machine)
        XCTAssertEqual(schema.functionsCalled.count, 1)
        guard let fn = schema.makeValidatorCalls.first else {
            XCTFail("Failed to get function.")
            return
        }
        XCTAssertEqual(fn, .makeValidator(root: machine))
        XCTAssertEqual(validator.timesCalled, 1)
        XCTAssertEqual(validator.lastParameter, machine)
    }

    /// Test that a call to the schema mutator delegates to the underlying schema.
    /// - Parameters:
    ///   - expectedCall: The expected result from the schema.
    ///   - call: A function that calls the mutator.
    ///   - getFns: All of the functions in the schema that were called.
    private func performTest(
        expectedCall: MockSchema.FunctionsCalled,
        call: () throws -> Result<Bool, AttributeError<MetaMachine>>,
        getFns: () -> [MockSchema.FunctionsCalled]
    ) throws {
        XCTAssertFalse(try call().get())
        XCTAssertEqual(schema.functionsCalled.count, 2)
        let fns = getFns()
        XCTAssertEqual(fns.count, 1)
        guard let fn = fns.first else {
            XCTFail("Failed to get function.")
            return
        }
        XCTAssertEqual(fn, expectedCall)
        let updateCalls = verifyUpdate()
        XCTAssertEqual(fns + updateCalls, schema.functionsCalled)
    }

    /// Verify that the update function is called once.
    /// - Returns: The calls to the update function.
    private func verifyUpdate() -> [MockSchema.FunctionsCalled] {
        let updateCalls = schema.updateCalls
        XCTAssertEqual(updateCalls.count, 1)
        guard
            let updateCall = updateCalls.first,
            case .update(let updateMachine) = updateCall
        else {
            XCTFail("Expected a call to update")
            return []
        }
        XCTAssertEqual(updateMachine, self.machine)
        return updateCalls
    }

}
