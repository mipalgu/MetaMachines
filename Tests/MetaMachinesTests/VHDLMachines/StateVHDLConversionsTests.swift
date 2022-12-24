// StateVHDLConversionsTests.swift 
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

/// Test class for ``State`` VHDL conversions.
final class StateVHDLConversionsTests: XCTestCase {

    /// A test VHDL machine.
    let vhdlMachine = VHDLMachines.Machine.initial(
        path: URL(fileURLWithPath: "/path/to/Machine.machine", isDirectory: true)
    )

    /// A VHDL state to convert.
    var vhdlState: VHDLMachines.State {
        self.vhdlMachine.states[0]
    }

    /// The converted state under test.
    lazy var state = MetaMachines.State(vhdl: vhdlState, in: vhdlMachine)

    /// Create the converted state before every test.
    override func setUp() {
        super.setUp()
        state = MetaMachines.State(vhdl: vhdlState, in: vhdlMachine)
    }

    /// Test init creates state correctly.
    func testConversionInit() {
        let expected = MetaMachines.State(
            name: "Initial",
            actions: [
                Action(name: "OnResume", implementation: "", language: .vhdl),
                Action(name: "OnSuspend", implementation: "", language: .vhdl),
                Action(name: "OnEntry", implementation: "", language: .vhdl),
                Action(name: "OnExit", implementation: "", language: .vhdl),
                Action(name: "Internal", implementation: "", language: .vhdl)
            ],
            transitions: [],
            attributes: vhdlState.attributes(for: vhdlMachine),
            metaData: []
        )
        XCTAssertEqual(state, expected)
    }

    /// Test external variable getter works correctly.
    func testExternalVariables() {
        let validValues: Set<String> = ["a", "b", "c"]
        state.attributes[0].attributes["externals"] = .enumerableCollection(
            ["a", "b"], validValues: validValues
        )
        let expected = ["a", "b"]
        XCTAssertEqual(state.vhdlExternalVariables, expected)
    }

    /// Test stateSignals retrieve signals correctly.
    func testStateSignals() {
        guard var signals = state.attributes[0].attributes["state_signals"] else {
            XCTFail("Failed to get existing signals")
            return
        }
        signals.tableValue = [
            [
                .expression("std_logic", language: .vhdl),
                .line("x"),
                .expression("'1'", language: .vhdl),
                .line("Signal x")
            ],
            [
                .expression("std_logic", language: .vhdl),
                .line("y"),
                .expression("'0'", language: .vhdl),
                .line("Signal y")
            ]
        ]
        state.attributes[0].attributes["state_signals"] = signals
        let expected = [
            MachineSignal(type: "std_logic", name: "x", defaultValue: "'1'", comment: "Signal x"),
            MachineSignal(type: "std_logic", name: "y", defaultValue: "'0'", comment: "Signal y")
        ]
        XCTAssertEqual(state.vhdlStateSignals, expected)
    }

    /// Test state variables are created correctly.
    func testStateVariables() {
        guard var variables = state.attributes[0].attributes["state_variables"] else {
            XCTFail("Failed to get existing signals")
            return
        }
        variables.tableValue = [
            [
                .expression("integer", language: .vhdl),
                .line("0"),
                .line("255"),
                .line("x"),
                .expression("1", language: .vhdl),
                .line("Variable x")
            ],
            [
                .expression("integer", language: .vhdl),
                .line("0"),
                .line("128"),
                .line("y"),
                .expression("0", language: .vhdl),
                .line("Variable y")
            ]
        ]
        state.attributes[0].attributes["state_variables"] = variables
        let expected = [
            VHDLVariable(
                type: "integer", name: "x", defaultValue: "1", range: (0, 255), comment: "Variable x"
            ),
            VHDLVariable(
                type: "integer", name: "y", defaultValue: "0", range: (0, 128), comment: "Variable y"
            )
        ]
        XCTAssertEqual(state.vhdlStateVariables, expected)
    }

    /// Test action order is created correctly.
    func testActionOrder() {
        let expected = [["OnResume", "OnSuspend"], ["OnEntry"], ["OnExit", "Internal"]]
        XCTAssertEqual(state.vhdlActionOrder, expected)
    }

}
