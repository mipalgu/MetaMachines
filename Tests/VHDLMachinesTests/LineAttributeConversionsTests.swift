// LineAttributeConversionsTests.swift 
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

/// Test class for ``LineAttributeConversions``.
final class LineAttributeConversionsTests: XCTestCase {

    /// Test ReturnableVariable implementation.
    func testReturnable() {
        let returnable = ReturnableVariable(type: "std_logic", name: "y", comment: "The output.")
        let expected: [LineAttribute] = [
            .expression("std_logic", language: .vhdl), .line("y"), .line("The output.")
        ]
        XCTAssertEqual(returnable.toLineAttribute, expected)
    }

    /// Test variable implementation.
    func testVHDLVariable() {
        let variable = VHDLMachines.VHDLVariable(
            type: "std_logic", name: "x", defaultValue: "'1'", range: nil, comment: "Variable x."
        )
        let expected: [LineAttribute] = [
            .expression("std_logic", language: .vhdl),
            .line(""),
            .line(""),
            .line("x"),
            .expression("'1'", language: .vhdl),
            .line("Variable x.")
        ]
        XCTAssertEqual(variable.toLineAttribute, expected)
        let variable2 = VHDLMachines.VHDLVariable(
            type: "integer", name: "y", defaultValue: "1", range: (0, 255), comment: "Variable y."
        )
        let expected2: [LineAttribute] = [
            .expression("integer", language: .vhdl),
            .line("0"),
            .line("255"),
            .line("y"),
            .expression("1", language: .vhdl),
            .line("Variable y.")
        ]
        XCTAssertEqual(variable2.toLineAttribute, expected2)
    }

    /// Test machine signal.
    func testMachineSignal() {
        let signal = VHDLMachines.MachineSignal(
            type: "std_logic", name: "x", defaultValue: "'1'", comment: "Signal x"
        )
        let expected: [LineAttribute] = [
            .expression("std_logic", language: .vhdl),
            .line("x"),
            .expression("'1'", language: .vhdl),
            .line("Signal x")
        ]
        XCTAssertEqual(signal.toLineAttribute, expected)
    }

    /// Test external signal implementation.
    func testSignal() {
        let signal = ExternalSignal(
            type: "std_logic", name: "x", mode: .input, defaultValue: "'1'", comment: "Signal x."
        )
        let expected: [LineAttribute] = [
            .enumerated("in", validValues: ["in", "out", "inout", "buffer"]),
            .expression("std_logic", language: .vhdl),
            .line("x"),
            .expression("'1'", language: .vhdl),
            .line("Signal x.")
        ]
        XCTAssertEqual(signal.toLineAttribute, expected)
    }

    /// Test clock implementation.
    func testClock() {
        let clock = Clock(name: "clk", frequency: 50, unit: .MHz)
        let expected: [LineAttribute] = [
            .line("clk"),
            .integer(50),
            .enumerated("MHz", validValues: ["Hz", "kHz", "MHz", "GHz", "THz"])
        ]
        XCTAssertEqual(clock.toLineAttribute, expected)
    }

    /// Test actionOrder implementation.
    func testActionOrder() {
        let order = [["OnResume", "OnSuspend"], ["OnEntry"], ["OnExit", "Internal"]]
        let validValues: Set<String> = ["OnResume", "OnSuspend", "OnEntry", "OnExit", "Internal"]
        let expected: [[LineAttribute]] = [
            [.integer(0), .enumerated("OnResume", validValues: validValues)],
            [.integer(0), .enumerated("OnSuspend", validValues: validValues)],
            [.integer(1), .enumerated("OnEntry", validValues: validValues)],
            [.integer(2), .enumerated("OnExit", validValues: validValues)],
            [.integer(2), .enumerated("Internal", validValues: validValues)]
        ]
        XCTAssertEqual(order.toLineAttribute(validValues: validValues), expected)
    }

}
