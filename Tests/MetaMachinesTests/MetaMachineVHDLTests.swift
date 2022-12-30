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
        let actions = [
            "OnEntry": "",
            "OnExit": "",
            "Internal": "",
            "OnSuspend": "",
            "OnResume": ""
        ]
        let actionOrder = [["OnResume", "OnSuspend"], ["OnEntry"], ["OnExit", "Internal"]]
        var vhdlMachine = VHDLMachines.Machine(machine: machine)
        let expectedVHDLState = VHDLMachines.State(
            name: "State0",
            actions: actions,
            actionOrder: actionOrder,
            signals: [],
            variables: [],
            externalVariables: []
        )
        vhdlMachine.states.append(expectedVHDLState)
        let expectedState = MetaMachines.State(vhdl: expectedVHDLState, in: vhdlMachine)
        XCTAssertEqual(machine.states.last, expectedState)
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

}
