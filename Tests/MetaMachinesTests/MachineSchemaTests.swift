// MachineSchemaTests.swift
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
import VHDLMachines
import XCTest

/// Test class for the default implementations of ``MachineSchema``.
final class MachineSchemaTests: XCTestCase {

    /// The state schemas trigger.
    var stateTrigger = MockTrigger<MetaMachine>()

    /// The state schemas validator.
    var stateValidator = NullValidator<MetaMachine>()

    /// The state schema.
    lazy var stateSchema = MockSchema(
        dependencyLayout: [], trigger: stateTrigger, validator: stateValidator
    )

    /// The transition schemas trigger.
    var transitionTrigger = MockTrigger<MetaMachine>()

    /// The transition schemas validator.
    var transitionValidator = NullValidator<MetaMachine>()

    /// The transition schema.
    lazy var transitionSchema = MockSchema(
        dependencyLayout: [], trigger: transitionTrigger, validator: transitionValidator
    )

    /// The group trigger.
    var groupTrigger = MockTrigger<MetaMachine>()

    /// The group validator.
    var groupValidator = NullValidator<AttributeGroup>()

    /// The group.
    lazy var group = MockGroup(mockTrigger: groupTrigger, mockValidator: groupValidator)

    /// The schema under test.
    lazy var schema = MockMachineSchema(
        stateSchema: stateSchema, transitionSchema: transitionSchema, group: group
    )

    /// The URL of the machine.
    let url = URL(fileURLWithPath: "Machine.machine", isDirectory: true)

    /// A meta machine to use as test data.
    lazy var machine = MetaMachine(vhdl: VHDLMachines.Machine.testMachine(path: url))

    /// Initialise all properties before every test.
    override func setUp() {
        self.stateTrigger = MockTrigger<MetaMachine>()
        self.stateValidator = NullValidator<MetaMachine>()
        self.stateSchema = MockSchema(
            dependencyLayout: [], trigger: stateTrigger, validator: stateValidator
        )
        self.transitionTrigger = MockTrigger<MetaMachine>()
        self.transitionValidator = NullValidator<MetaMachine>()
        self.transitionSchema = MockSchema(
            dependencyLayout: [], trigger: transitionTrigger, validator: transitionValidator
        )
        self.groupTrigger = MockTrigger<MetaMachine>()
        self.groupValidator = NullValidator<AttributeGroup>()
        self.group = MockGroup(mockTrigger: groupTrigger, mockValidator: groupValidator)
        self.schema = MockMachineSchema(
            stateSchema: stateSchema, transitionSchema: transitionSchema, group: group
        )
        self.machine = MetaMachine(vhdl: VHDLMachines.Machine.testMachine(path: url))
    }

    /// Test that the trigger properties uses all available triggers.
    func testTriggerCallsEveryTrigger() throws {
        let path = AnyPath(Path(MetaMachine.self).attributes[0])
        XCTAssertFalse(try schema.trigger.performTrigger(&machine, for: path).get())
        XCTAssertEqual(stateTrigger.timesCalled, 1)
        XCTAssertEqual(stateTrigger.pathPassed, path)
        XCTAssertEqual(stateTrigger.rootPassed, machine)
        XCTAssertEqual(transitionTrigger.timesCalled, 1)
        XCTAssertEqual(transitionTrigger.pathPassed, path)
        XCTAssertEqual(transitionTrigger.rootPassed, machine)
        XCTAssertEqual(groupTrigger.timesCalled, 1)
        XCTAssertEqual(groupTrigger.pathPassed, path)
        XCTAssertEqual(groupTrigger.rootPassed, machine)
    }

    /// Make sure that the delegation methods do nothing by default.
    func testDelegateMethodsDoNothing() throws {
        let before = machine
        let beforeSchema = schema
        try [
            schema.didCreateDependency(
                machine: &machine, dependency: MachineDependency(relativePath: ""), index: 0
            ),
            schema.didCreateNewState(machine: &machine, state: machine.states[0], index: 0),
            schema.didChangeStatesName(machine: &machine, state: machine.states[0], index: 0, oldName: ""),
            schema.didCreateNewTransition(
                machine: &machine,
                transition: MetaMachines.Transition(target: "Suspended"),
                stateIndex: 0,
                transitionIndex: 0
            ),
            schema.didDeleteDependency(
                machine: &machine, dependency: MachineDependency(relativePath: ""), at: 0
            ),
            schema.didDeleteState(machine: &machine, state: machine.states[0], at: 0),
            schema.didDeleteTransition(
                machine: &machine,
                transition: MetaMachines.Transition(target: "Suspended"),
                stateIndex: 0,
                at: 0
            ),
            schema.didDeleteDependencies(
                machine: &machine, dependency: [MachineDependency(relativePath: "")], at: IndexSet(0...0)
            ),
            schema.didDeleteStates(
                machine: &machine, state: machine.states, at: IndexSet(machine.states.indices)
            ),
            schema.didDeleteTransitions(
                machine: &machine,
                transition: [MetaMachines.Transition(target: "Suspended")],
                stateIndex: 0,
                at: IndexSet(0...0)
            )
        ].forEach {
            XCTAssertFalse(try $0.get())
        }
        schema.update(from: machine)
        XCTAssertEqual(before, machine)
        XCTAssertEqual(beforeSchema, schema)
    }

}
