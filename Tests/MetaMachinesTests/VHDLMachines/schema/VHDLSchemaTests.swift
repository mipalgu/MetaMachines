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
        (machine.mutator as? SchemaMutator<VHDLSchema>)?.schema
    }

    /// Initialise the test data.
    override func setUp() {
        self.machine = MetaMachine(vhdl: VHDLMachines.Machine.testMachine(path: url))
    }

    /// Test isTriggerForPath tracks observed values oin machine.
    func testIsTriggerForPathMachine() {
        guard let trigger = schema?.trigger else {
            XCTFail("Failed to get trigger!")
            return
        }
        let path = Path(MetaMachine.self)
        XCTAssertFalse(trigger.isTriggerForPath(AnyPath(path), in: machine))
        XCTAssertFalse(trigger.isTriggerForPath(AnyPath(path.metaData), in: machine))
        XCTAssertFalse(trigger.isTriggerForPath(AnyPath(path.acceptingStates), in: machine))
        XCTAssertFalse(trigger.isTriggerForPath(AnyPath(path.dependencies), in: machine))
        XCTAssertFalse(trigger.isTriggerForPath(AnyPath(path.errorBag), in: machine))
        XCTAssertFalse(trigger.isTriggerForPath(AnyPath(path.initialState), in: machine))
        XCTAssertFalse(trigger.isTriggerForPath(AnyPath(path.mutator), in: machine))
        XCTAssertFalse(trigger.isTriggerForPath(AnyPath(path.name), in: machine))
        XCTAssertFalse(trigger.isTriggerForPath(AnyPath(path.semantics), in: machine))
        XCTAssertFalse(trigger.isTriggerForPath(AnyPath(path.attributes), in: machine))
        XCTAssertFalse(trigger.isTriggerForPath(AnyPath(path.attributes[0]), in: machine))
        XCTAssertFalse(trigger.isTriggerForPath(AnyPath(path.attributes[2]), in: machine))
        XCTAssertFalse(trigger.isTriggerForPath(AnyPath(path.attributes[3]), in: machine))
    }

    func testIsTriggerForPathMachineGroup1() {
        guard let trigger = schema?.trigger else {
            XCTFail("Failed to get trigger!")
            return
        }
        let path = Path(MetaMachine.self).attributes
        XCTAssertFalse(trigger.isTriggerForPath(AnyPath(path[1]), in: machine))
        XCTAssertFalse(trigger.isTriggerForPath(AnyPath(path[1].name), in: machine))
        XCTAssertFalse(trigger.isTriggerForPath(AnyPath(path[1].fields), in: machine))
        XCTAssertFalse(trigger.isTriggerForPath(AnyPath(path[1].metaData), in: machine))
        XCTAssertFalse(trigger.isTriggerForPath(AnyPath(path[1].attributes), in: machine))
        XCTAssertFalse(
            trigger.isTriggerForPath(AnyPath(path[1].attributes["is_parameterised"]), in: machine)
        )
        XCTAssertFalse(
            trigger.isTriggerForPath(AnyPath(path[1].attributes["parameter_signals"]), in: machine)
        )
        XCTAssertFalse(
            trigger.isTriggerForPath(AnyPath(path[1].attributes["returnable_signals"]), in: machine)
        )
        XCTAssertFalse(
            trigger.isTriggerForPath(
                AnyPath(path[1].attributes["is_parameterised"].wrappedValue), in: machine
            )
        )
        XCTAssertFalse(
            trigger.isTriggerForPath(
                AnyPath(path[1].attributes["parameter_signals"].wrappedValue), in: machine
            )
        )
        XCTAssertFalse(
            trigger.isTriggerForPath(
                AnyPath(path[1].attributes["returnable_signals"].wrappedValue), in: machine
            )
        )
        XCTAssertTrue(
            trigger.isTriggerForPath(
                AnyPath(path[1].attributes["is_parameterised"].wrappedValue.boolValue), in: machine
            )
        )
        XCTAssertFalse(
            trigger.isTriggerForPath(
                AnyPath(path[1].attributes["parameter_signals"].wrappedValue.tableValue), in: machine
            )
        )
        XCTAssertFalse(
            trigger.isTriggerForPath(
                AnyPath(path[1].attributes["returnable_signals"].wrappedValue.tableValue), in: machine
            )
        )
    }

    /// Test isTriggerForPath tracks observed values in state.
    func testIsTriggerForPathState() {
        guard let trigger = schema?.trigger else {
            XCTFail("Failed to get trigger!")
            return
        }
        let path = Path(MetaMachine.self)
        XCTAssertTrue(trigger.isTriggerForPath(AnyPath(path.states), in: machine))
        XCTAssertTrue(trigger.isTriggerForPath(AnyPath(path.states[0]), in: machine))
        XCTAssertTrue(trigger.isTriggerForPath(AnyPath(path.states[0].name), in: machine))
        XCTAssertFalse(trigger.isTriggerForPath(AnyPath(path.states[0].attributes), in: machine))
        XCTAssertFalse(trigger.isTriggerForPath(AnyPath(path.states[0].metaData), in: machine))
        XCTAssertFalse(trigger.isTriggerForPath(AnyPath(path.states[0].attributes[0]), in: machine))
        XCTAssertFalse(trigger.isTriggerForPath(AnyPath(path.states[0].attributes[1]), in: machine))
    }

}
