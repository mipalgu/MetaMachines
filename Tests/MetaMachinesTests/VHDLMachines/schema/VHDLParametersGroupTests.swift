// VHDLParametersGroupTests.swift
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

/// Test class for ``VHDLParametersGroup``.
final class VHDLParametersGroupTests: XCTestCase {

    /// The URL of the machine.
    let url = URL(fileURLWithPath: "Machine.machine", isDirectory: true)

    /// A meta machine to use as test data.
    lazy var machine = MetaMachine(vhdl: VHDLMachines.Machine.testMachine(path: url))

    /// All of the fields in the group.
    let fields = [
        Field(name: "is_parameterised", type: .bool),
        Field(
            name: "parameter_signals",
            type: .table(
                columns: [
                    ("type", .expression(language: .vhdl)),
                    ("name", .line),
                    ("value", .expression(language: .vhdl)),
                    ("comment", .line)
                ]
            )
        ),
        Field(
            name: "returnable_signals",
            type: .table(
                columns: [
                    ("type", .expression(language: .vhdl)),
                    ("name", .line),
                    ("comment", .line)
                ]
            )
        )
    ]

    /// The schema containing the group.
    var schema: VHDLSchema? {
        (machine.mutator as? SchemaMutator<VHDLSchema>)?.schema
    }

    /// The schema group under test.
    var parameters: VHDLParametersGroup? {
        schema?.parameters
    }

    /// Initialise the test data.
    override func setUp() {
        self.machine = MetaMachine(vhdl: VHDLMachines.Machine.testMachine(path: url))
    }

    /// Test path points to correct attribute group.
    func testPath() {
        let expected = Path(MetaMachine.self).attributes[1]
        XCTAssertEqual(parameters?.path, expected)
    }

    /// Test properties match attributes definition.
    func testPropertiesAreCorrect() {
        XCTAssertEqual(parameters?.isParameterised.label, "is_parameterised")
        XCTAssertEqual(parameters?.isParameterised.type, .bool)
        XCTAssertEqual(parameters?.parameters.label, "parameter_signals")
        XCTAssertEqual(
            parameters?.parameters.type,
            .table(columns: [
                ("type", .expression(language: .vhdl)),
                ("name", .line),
                ("value", .expression(language: .vhdl)),
                ("comment", .line)
            ])
        )
        XCTAssertEqual(parameters?.returns.label, "returnable_signals")
        XCTAssertEqual(
            parameters?.returns.type,
            .table(columns: [
                ("type", .expression(language: .vhdl)),
                ("name", .line),
                ("comment", .line)
            ])
        )
    }

    /// Test that the validator rules throw errors for an invalid name.
    func testSignalNameParameterValidatorRules() throws {
        try [
            signalTable(name: "a%^&"),
            signalTable(name: "std_logic"),
            signalTable(name: "integer"),
            signalTable(name: "abs"),
            signalTable(name: "")
        ]
        .forEach {
            XCTAssertThrowsError(try parameters?.parameters.validate.performValidation($0))
        }
        try [
            signalTable(name: "x"),
            signalTable(name: "y"),
            signalTable(name: "x_1"),
            signalTable(name: "_x"),
            signalTable(name: "abs3")
        ]
        .forEach {
            XCTAssertNoThrow(try parameters?.parameters.validate.performValidation($0))
        }
    }

    /// Test that the validator rules throw errors for an invalid type.
    func testSignalTypeParameterValidatorRules() throws {
        try [
            signalTable(type: "integer"),
            signalTable(type: "boolean"),
            signalTable(type: "all"),
            signalTable(type: "my_integers")
        ]
        .forEach {
            XCTAssertThrowsError(try parameters?.parameters.validate.performValidation($0))
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
            XCTAssertNoThrow(try parameters?.parameters.validate.performValidation($0))
        }
    }

    /// Test that the validator rules throw errors for an invalid name.
    func testSignalNameReturnValidatorRules() throws {
        try [
            returnTable(name: "a%^&"),
            returnTable(name: "std_logic"),
            returnTable(name: "integer"),
            returnTable(name: "abs"),
            returnTable(name: "")
        ]
        .forEach {
            XCTAssertThrowsError(try parameters?.returns.validate.performValidation($0))
        }
        try [
            returnTable(name: "x"),
            returnTable(name: "y"),
            returnTable(name: "x_1"),
            returnTable(name: "_x"),
            returnTable(name: "abs3")
        ]
        .forEach {
            XCTAssertNoThrow(try parameters?.returns.validate.performValidation($0))
        }
    }

    /// Test that the validator rules throw errors for an invalid type.
    func testSignalTypeReturnValidatorRules() throws {
        try [
            returnTable(type: "integer"),
            returnTable(type: "boolean"),
            returnTable(type: "all"),
            returnTable(type: "my_integers")
        ]
        .forEach {
            XCTAssertThrowsError(try parameters?.returns.validate.performValidation($0))
        }
        try [
            returnTable(type: "std_logic"),
            returnTable(type: "std_logic_vector"),
            returnTable(type: "signed"),
            returnTable(type: "unsigned"),
            returnTable(type: "bit"),
            returnTable(type: "bit_vector")
        ]
        .forEach {
            XCTAssertNoThrow(try parameters?.returns.validate.performValidation($0))
        }
    }

    /// Test that parameters are available by default.
    func testParametersAreAvailableWhenParameterised() {
        XCTAssertEqual(machine.attributes[1].fields.count, 3)
        XCTAssertEqual(machine.attributes[1].fields, fields)
        XCTAssertEqual(machine.attributes[1].attributes["is_parameterised"], .bool(true))
    }

    /// Test triggers make fields unavailable when `isParameterised` is `false`.
    func testMakeFieldsUnavailable() throws {
        guard let trigger = parameters?.allTriggers else {
            XCTFail("failed to get trigger.")
            return
        }
        machine.attributes[1].attributes["is_parameterised"] = .bool(false)
        let path = AnyPath(
            Path(MetaMachine.self).attributes[1].attributes["is_parameterised"].wrappedValue.boolValue
        )
        XCTAssertTrue(trigger.isTriggerForPath(path, in: machine))
        XCTAssertTrue(try trigger.performTrigger(&machine, for: path).get())
        XCTAssertEqual(machine.attributes[1].fields.count, 1)
        XCTAssertEqual(machine.attributes[1].fields.first, Field(name: "is_parameterised", type: .bool))
    }

    /// Test triggers make parameters available when `isParameterised` is `true`.
    func testMakeFieldsAvailable() throws {
        guard let trigger = parameters?.allTriggers else {
            XCTFail("failed to get trigger.")
            return
        }
        machine.attributes[1].attributes["is_parameterised"] = .bool(false)
        let path = AnyPath(
            Path(MetaMachine.self).attributes[1].attributes["is_parameterised"].wrappedValue.boolValue
        )
        XCTAssertTrue(trigger.isTriggerForPath(path, in: machine))
        XCTAssertTrue(try trigger.performTrigger(&machine, for: path).get())
        XCTAssertEqual(machine.attributes[1].fields.count, 1)
        XCTAssertEqual(machine.attributes[1].fields.first, Field(name: "is_parameterised", type: .bool))
        machine.attributes[1].attributes["is_parameterised"] = .bool(true)
        XCTAssertTrue(try trigger.performTrigger(&machine, for: path).get())
        XCTAssertEqual(machine.attributes[1].fields.count, 3)
        XCTAssertEqual(machine.attributes[1].fields.sorted { $0.name < $1.name }, fields)
    }

    /// Create a table for a parameter signal.
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

    /// Create a table for a return signal.
    private func returnTable(type: String = "std_logic", name: String = "x") -> Attribute {
        let row: [LineAttribute] = [
            .expression(type, language: .vhdl),
            .line(name),
            .line("")
        ]
        return .table(
            [row],
            columns: [
                ("type", .expression(language: .vhdl)),
                ("name", .line),
                ("comment", .line)
            ]
        )
    }

}
