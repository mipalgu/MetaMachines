// VHDLVariablesGroupValidationTests.swift
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

/// Tests for the ``VHDLVariablesGroup`` struct.
final class VHDLVariablesGroupValidationTests: XCTestCase {

    /// The URL of the machine.
    let url = URL(fileURLWithPath: "Machine.machine", isDirectory: true)

    /// A meta machine to use as test data.
    lazy var machine = MetaMachine(vhdl: VHDLMachines.Machine.testMachine(path: url))

    /// The schema containing the group.
    var schema: VHDLSchema? {
        (machine.mutator as? SchemaMutator<VHDLSchema>)?.schema
    }

    /// The schema group under test.
    var variables: VHDLVariablesGroup? {
        schema?.variables
    }

    /// Allowed external variable modes.
    let modes: Set<String> = ["in", "out", "inout", "buffer"]

    /// Initialise the test data.
    override func setUp() {
        self.machine = MetaMachine(vhdl: VHDLMachines.Machine.testMachine(path: url))
    }

    /// Test that the validator rules throw errors for an invalid name.
    func testExternalSignalModeValidatorRules() throws {
        try [
            externalSignalTable(mode: "IN"),
            externalSignalTable(mode: "OUT"),
            externalSignalTable(mode: "INOUT"),
            externalSignalTable(mode: "BUFFER"),
            externalSignalTable(mode: "TRISTATE"),
            externalSignalTable(mode: "PULLUP"),
            externalSignalTable(mode: "PULLDOWN"),
            externalSignalTable(mode: "OPEN_DRAIN"),
            externalSignalTable(mode: "OPEN_COLLECTOR"),
            externalSignalTable(mode: "POWER"),
            externalSignalTable(mode: "GROUND"),
            externalSignalTable(mode: "abc"),
            externalSignalTable(mode: "123"),
            externalSignalTable(mode: "in2"),
            externalSignalTable(mode: " out ")
        ]
        .forEach {
            XCTAssertThrowsError(try variables?.externalVariables.validate.performValidation($0))
        }
        try [
            externalSignalTable(mode: "in"),
            externalSignalTable(mode: "out"),
            externalSignalTable(mode: "inout"),
            externalSignalTable(mode: "buffer")
        ]
        .forEach {
            XCTAssertNoThrow(try variables?.externalVariables.validate.performValidation($0))
        }
    }

    /// Test that the validator rules throw errors for an invalid type.
    func testExternalSignalTypeValidatorRules() throws {
        try [
            externalSignalTable(type: "integer"),
            externalSignalTable(type: "boolean"),
            externalSignalTable(type: "all"),
            externalSignalTable(type: "my_integers")
        ]
        .forEach {
            XCTAssertThrowsError(try variables?.externalVariables.validate.performValidation($0))
        }
        try [
            externalSignalTable(type: "std_logic"),
            externalSignalTable(type: "std_logic_vector"),
            externalSignalTable(type: "signed"),
            externalSignalTable(type: "unsigned"),
            externalSignalTable(type: "bit"),
            externalSignalTable(type: "bit_vector")
        ]
        .forEach {
            XCTAssertNoThrow(try variables?.externalVariables.validate.performValidation($0))
        }
    }

    /// Test that the validator rules throw errors for an invalid name.
    func testExternalSignalNameValidatorRules() throws {
        try [
            externalSignalTable(name: "a%^&"),
            externalSignalTable(name: "std_logic"),
            externalSignalTable(name: "integer"),
            externalSignalTable(name: "abs"),
            externalSignalTable(name: "")
        ]
        .forEach {
            XCTAssertThrowsError(try variables?.externalVariables.validate.performValidation($0))
        }
        try [
            externalSignalTable(name: "x"),
            externalSignalTable(name: "y"),
            externalSignalTable(name: "x_1"),
            externalSignalTable(name: "_x"),
            externalSignalTable(name: "abs3")
        ]
        .forEach {
            XCTAssertNoThrow(try variables?.externalVariables.validate.performValidation($0))
        }
    }

    /// Test that the validator rules throw errors for an invalid type.
    func testGenericTypeValidatorRules() throws {
        try [
            variableTable(type: "std_logic"),
            variableTable(type: "std_logic_vector"),
            variableTable(type: "signed"),
            variableTable(type: "unsigned"),
            variableTable(type: "bit"),
            variableTable(type: "bit_vector"),
            variableTable(type: "all"),
            variableTable(type: "my_integers")
        ]
        .forEach {
            XCTAssertThrowsError(
                try variables?.generics.validate.performValidation($0), "Succeeded with \($0)"
            )
        }
        try [
            variableTable(type: "integer"),
            variableTable(type: "boolean"),
            variableTable(type: "natural"),
            variableTable(type: "positive"),
            variableTable(type: "real")
        ]
        .forEach {
            XCTAssertNoThrow(try variables?.generics.validate.performValidation($0))
        }
    }

    /// Test that the validator rules throw errors for an invalid name.
    func testGenericNameValidatorRules() throws {
        try [
            variableTable(name: "a%^&"),
            variableTable(name: "std_logic"),
            variableTable(name: "integer"),
            variableTable(name: "abs"),
            variableTable(name: "")
        ]
        .forEach {
            XCTAssertThrowsError(try variables?.generics.validate.performValidation($0))
        }
        try [
            variableTable(name: "x"),
            variableTable(name: "y"),
            variableTable(name: "x_1"),
            variableTable(name: "_x"),
            variableTable(name: "abs3")
        ]
        .forEach {
            XCTAssertNoThrow(try variables?.generics.validate.performValidation($0))
        }
    }

    /// Test that the validator rules throw errors for an invalid name.
    func testGenericRangeValidatorRules() throws {
        try [
            variableTable(lowerRange: "a%^&"),
            variableTable(lowerRange: "std_logic"),
            variableTable(lowerRange: "integer"),
            variableTable(lowerRange: "abs")
        ]
        .forEach {
            XCTAssertThrowsError(
                try variables?.generics.validate.performValidation($0), "Succeeded with \($0)"
            )
        }
        try [
            variableTable(lowerRange: "1"),
            variableTable(lowerRange: "200"),
            variableTable(lowerRange: "20000"),
            variableTable(lowerRange: "3000000000"),
            variableTable(lowerRange: "123456789")
        ]
        .forEach {
            XCTAssertNoThrow(try variables?.generics.validate.performValidation($0))
        }
    }

    /// Test that the validator rules throw errors for an invalid type.
    func testMachineTypeValidatorRules() throws {
        try [
            variableTable(type: "std_logic"),
            variableTable(type: "std_logic_vector"),
            variableTable(type: "signed"),
            variableTable(type: "unsigned"),
            variableTable(type: "bit"),
            variableTable(type: "bit_vector"),
            variableTable(type: "all"),
            variableTable(type: "my_integers")
        ]
        .forEach {
            XCTAssertThrowsError(
                try variables?.machineVariables.validate.performValidation($0), "Succeeded with \($0)"
            )
        }
        try [
            variableTable(type: "integer"),
            variableTable(type: "boolean"),
            variableTable(type: "natural"),
            variableTable(type: "positive"),
            variableTable(type: "real")
        ]
        .forEach {
            XCTAssertNoThrow(try variables?.machineVariables.validate.performValidation($0))
        }
    }

    /// Test that the validator rules throw errors for an invalid name.
    func testMachineNameValidatorRules() throws {
        try [
            variableTable(name: "a%^&"),
            variableTable(name: "std_logic"),
            variableTable(name: "integer"),
            variableTable(name: "abs"),
            variableTable(name: "")
        ]
        .forEach {
            XCTAssertThrowsError(try variables?.machineVariables.validate.performValidation($0))
        }
        try [
            variableTable(name: "x"),
            variableTable(name: "y"),
            variableTable(name: "x_1"),
            variableTable(name: "_x"),
            variableTable(name: "abs3")
        ]
        .forEach {
            XCTAssertNoThrow(try variables?.machineVariables.validate.performValidation($0))
        }
    }

    /// Test that the validator rules throw errors for an invalid name.
    func testMachineRangeValidatorRules() throws {
        try [
            variableTable(lowerRange: "a%^&"),
            variableTable(lowerRange: "std_logic"),
            variableTable(lowerRange: "integer"),
            variableTable(lowerRange: "abs")
        ]
        .forEach {
            XCTAssertThrowsError(
                try variables?.machineVariables.validate.performValidation($0), "Succeeded with \($0)"
            )
        }
        try [
            variableTable(lowerRange: "1"),
            variableTable(lowerRange: "200"),
            variableTable(lowerRange: "20000"),
            variableTable(lowerRange: "3000000000"),
            variableTable(lowerRange: "123456789")
        ]
        .forEach {
            XCTAssertNoThrow(try variables?.machineVariables.validate.performValidation($0))
        }
    }

    /// Test that the validator rules throw errors for an invalid name.
    func testMachineSignalNameValidatorRules() throws {
        try [
            signalTable(name: "a%^&"),
            signalTable(name: "std_logic"),
            signalTable(name: "integer"),
            signalTable(name: "abs"),
            signalTable(name: "")
        ]
        .forEach {
            XCTAssertThrowsError(try variables?.machineSignals.validate.performValidation($0))
        }
        try [
            signalTable(name: "x"),
            signalTable(name: "y"),
            signalTable(name: "x_1"),
            signalTable(name: "_x"),
            signalTable(name: "abs3")
        ]
        .forEach {
            XCTAssertNoThrow(try variables?.machineSignals.validate.performValidation($0))
        }
    }

    /// Test that the validator rules throw errors for an invalid type.
    func testMachineSignalTypeValidatorRules() throws {
        try [
            signalTable(type: "integer"),
            signalTable(type: "boolean"),
            signalTable(type: "all"),
            signalTable(type: "my_integers")
        ]
        .forEach {
            XCTAssertThrowsError(try variables?.machineSignals.validate.performValidation($0))
        }
        try [
            signalTable(type: "std_logic"),
            signalTable(type: "std_logic_vector"),
            signalTable(type: "signed"),
            signalTable(type: "unsigned"),
            signalTable(type: "bit"),
            signalTable(type: "bit_vector")
        ]
        .forEach {
            XCTAssertNoThrow(try variables?.machineSignals.validate.performValidation($0))
        }
    }

    /// Create a table for an external signal.
    private func externalSignalTable(
        mode: String = "in", type: String = "std_logic", name: String = "x"
    ) -> Attribute {
        let row: [LineAttribute] = [
            .enumerated(mode, validValues: modes),
            .expression(type, language: .vhdl),
            .line(name),
            .expression("", language: .vhdl),
            .line("")
        ]
        return .table(
            [row],
            columns: [
                ("mode", .enumerated(validValues: modes)),
                ("type", .expression(language: .vhdl)),
                ("name", .line),
                ("value", .expression(language: .vhdl)),
                ("comment", .line)
            ]
        )
    }

    /// Create a table for a variable.
    private func variableTable(
        type: String = "integer", name: String = "x", lowerRange: String = "", upperRange: String = ""
    ) -> Attribute {
        let row: [LineAttribute] = [
            .expression(type, language: .vhdl),
            .line(lowerRange),
            .line(upperRange),
            .line(name),
            .expression("", language: .vhdl),
            .line("")
        ]
        return .table(
            [row],
            columns: [
                ("type", .expression(language: .vhdl)),
                ("lower_range", .line),
                ("upper_range", .line),
                ("name", .line),
                ("value", .expression(language: .vhdl)),
                ("comment", .line)
            ]
        )
    }

    /// Create a table for a machine signal.
    private func signalTable(type: String = "std_logic", name: String = "x") -> Attribute {
        let row: [LineAttribute] = [
            .expression(type, language: .vhdl),
            .line(name),
            .expression("", language: .vhdl),
            .line("")
        ]
        return .table(
            [row],
            columns: [
                ("type", .expression(language: .vhdl)),
                ("name", .line),
                ("value", .expression(language: .vhdl)),
                ("comment", .line)
            ]
        )
    }

}
