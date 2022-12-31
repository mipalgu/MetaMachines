// VHDLVariablesGroupTests.swift
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

// swiftlint:disable file_length
// swiftlint:disable type_body_length

/// Tests for the ``VHDLVariablesGroup`` struct.
final class VHDLVariablesGroupTests: XCTestCase {

    /// The URL of the machine.
    let url = URL(fileURLWithPath: "Machine.machine", isDirectory: true)

    /// A meta machine to use as test data.
    lazy var machine = MetaMachine(vhdl: VHDLMachines.Machine.testMachine(path: url))

    /// The schema containing the group.
    var schema: VHDLSchema? {
        (machine.mutator as? SchemaMutator<VHDLSchema>)?.schema
    }

    /// Allowed external variable modes.
    let modes: Set<String> = ["in", "out", "inout", "buffer"]

    /// The schema group under test.
    var variables: VHDLVariablesGroup? {
        schema?.variables
    }

    /// Allowed clock frequencies.
    let frequencies: Set<String> = ["Hz", "kHz", "MHz", "GHz", "THz"]

    /// Initialise the test data.
    override func setUp() {
        self.machine = MetaMachine(vhdl: VHDLMachines.Machine.testMachine(path: url))
    }

    /// Test that the path matches the correct group in the meta machine.
    func testPath() {
        let expected = Path(MetaMachine.self).attributes[0]
        XCTAssertEqual(variables?.path, expected)
    }

    /// Test the properties match the attributes in meta machine.
    func testProperties() {
        XCTAssertEqual(variables?.clocks.label, "clocks")
        XCTAssertEqual(variables?.clocks.type, .table( columns: [
            ("name", .line),
            ("frequency", .integer),
            ("unit", .enumerated(validValues: frequencies))
        ]))
        XCTAssertEqual(variables?.externalVariables.label, "external_signals")
        XCTAssertEqual(variables?.externalVariables.type, .table(columns: [
            ("mode", .enumerated(validValues: modes)),
            ("type", .expression(language: .vhdl)),
            ("name", .line),
            ("value", .expression(language: .vhdl)),
            ("comment", .line)
        ]))
        XCTAssertEqual(variables?.generics.label, "generics")
        XCTAssertEqual(variables?.generics.type, .table(columns: [
            ("type", .expression(language: .vhdl)),
            ("lower_range", .line),
            ("upper_range", .line),
            ("name", .line),
            ("value", .expression(language: .vhdl)),
            ("comment", .line)
        ]))
        XCTAssertEqual(variables?.machineSignals.label, "machine_signals")
        XCTAssertEqual(variables?.machineSignals.type, .table(columns: [
            ("type", .expression(language: .vhdl)),
            ("name", .line),
            ("value", .expression(language: .vhdl)),
            ("comment", .line)
        ]))
        XCTAssertEqual(variables?.machineVariables.label, "machine_variables")
        XCTAssertEqual(variables?.machineVariables.type, .table(columns: [
            ("type", .expression(language: .vhdl)),
            ("lower_range", .line),
            ("upper_range", .line),
            ("name", .line),
            ("value", .expression(language: .vhdl)),
            ("comment", .line)
        ]))
        XCTAssertEqual(variables?.drivingClock.label, "driving_clock")
        XCTAssertEqual(variables?.drivingClock.type, .enumerated(validValues: ["clk", "clk1"]))
        XCTAssertEqual(variables?.properties.count, 6)
    }

    /// Test trigger only fires for correct path.
    func testTriggersForPath() {
        guard let trigger = variables?.allTriggers else {
            XCTFail("Failed to get triggers.")
            return
        }
        let attributesPath = Path(MetaMachine.self).attributes
        XCTAssertFalse(trigger.isTriggerForPath(AnyPath(attributesPath), in: machine))
        XCTAssertFalse(trigger.isTriggerForPath(AnyPath(attributesPath[0]), in: machine))
        XCTAssertFalse(trigger.isTriggerForPath(AnyPath(attributesPath[0].attributes), in: machine))
        XCTAssertFalse(trigger.isTriggerForPath(AnyPath(attributesPath[0].attributes["clocks"]), in: machine))
        XCTAssertFalse(trigger.isTriggerForPath(
            AnyPath(attributesPath[0].attributes["external_signals"]), in: machine
        ))
        XCTAssertTrue(trigger.isTriggerForPath(
            AnyPath(attributesPath[0].attributes["clocks"].wrappedValue), in: machine
        ))
        XCTAssertTrue(trigger.isTriggerForPath(
            AnyPath(attributesPath[0].attributes["external_signals"].wrappedValue), in: machine
        ))
    }

    /// Test the valid values of the driving clock are updated when a new clock is added.
    func testNewClockTriggerUpdatesDrivingClock() {
        guard let trigger = variables?.allTriggers else {
            XCTFail("Failed to get triggers.")
            return
        }
        guard let existingClocks = machine.attributes[0].attributes["clocks"]?.tableValue else {
            XCTFail("Failed to get clocks.")
            return
        }
        let newClock = [
            LineAttribute.line("clk2"),
            LineAttribute.integer(1),
            LineAttribute.enumerated("MHz", validValues: frequencies)
        ]
        let newClocks = Attribute.table(existingClocks + [newClock], columns: [
            ("name", .line),
            ("frequency", .integer),
            ("unit", .enumerated(validValues: frequencies))
        ])
        machine.attributes[0].attributes["clocks"] = newClocks
        let path = AnyPath(Path(MetaMachine.self).attributes[0].attributes["clocks"].wrappedValue.tableValue)
        XCTAssertTrue(trigger.isTriggerForPath(path, in: machine))
        XCTAssertTrue(try trigger.performTrigger(&machine, for: path).get())
        let validValues: Set<String> = ["clk", "clk1", "clk2"]
        let fields = machine.attributes[0].fields
        let clockField = fields.first { $0.name == "driving_clock" }
        XCTAssertEqual(clockField?.type, .enumerated(validValues: validValues))
        XCTAssertEqual(variables?.drivingClock.type, .enumerated(validValues: validValues))
        XCTAssertEqual(machine.attributes[0].attributes["driving_clock"]?.enumeratedValue, "clk")
        XCTAssertEqual(machine.attributes[0].attributes["driving_clock"]?.enumeratedValidValues, validValues)
    }

    /// Test the valid values of the driving clock are updated when a clock is deleted.
    func testDeletedClockTriggerUpdatesDrivingClock() {
        guard let trigger = variables?.allTriggers else {
            XCTFail("Failed to get triggers.")
            return
        }
        guard let existingClocks = machine.attributes[0].attributes["clocks"]?.tableValue else {
            XCTFail("Failed to get clocks.")
            return
        }
        let newClocks = Attribute.table(Array(existingClocks.dropFirst()), columns: [
            ("name", .line),
            ("frequency", .integer),
            ("unit", .enumerated(validValues: frequencies))
        ])
        machine.attributes[0].attributes["clocks"] = newClocks
        let path = AnyPath(Path(MetaMachine.self).attributes[0].attributes["clocks"].wrappedValue.tableValue)
        XCTAssertTrue(trigger.isTriggerForPath(path, in: machine))
        XCTAssertTrue(try trigger.performTrigger(&machine, for: path).get())
        let validValues: Set<String> = ["clk1"]
        let fields = machine.attributes[0].fields
        let clockField = fields.first { $0.name == "driving_clock" }
        XCTAssertEqual(clockField?.type, .enumerated(validValues: validValues))
        XCTAssertEqual(variables?.drivingClock.type, .enumerated(validValues: validValues))
        XCTAssertEqual(machine.attributes[0].attributes["driving_clock"]?.enumeratedValue, "clk1")
        XCTAssertEqual(machine.attributes[0].attributes["driving_clock"]?.enumeratedValidValues, validValues)
    }

    /// Test the valid values of the driving clock are updated when a clock is renamed.
    func testRenameClockTriggerUpdatesDrivingClock() {
        guard let trigger = variables?.allTriggers else {
            XCTFail("Failed to get triggers.")
            return
        }
        guard
            let existingClock = machine.attributes[0].attributes["clocks"]?.tableValue.first,
            existingClock.count == 3
        else {
            XCTFail("Failed to get clocks.")
            return
        }
        machine.attributes[0].attributes["clocks"].wrappedValue.tableValue[0][0] = .line("new_clock")
        let path = AnyPath(
            Path(MetaMachine.self).attributes[0].attributes["clocks"].wrappedValue.tableValue[0][0].lineValue
        )
        XCTAssertTrue(trigger.isTriggerForPath(path, in: machine))
        XCTAssertTrue(try trigger.performTrigger(&machine, for: path).get())
        let validValues: Set<String> = ["new_clock", "clk1"]
        let fields = machine.attributes[0].fields
        let clockField = fields.first { $0.name == "driving_clock" }
        XCTAssertEqual(clockField?.type, .enumerated(validValues: validValues))
        XCTAssertEqual(variables?.drivingClock.type, .enumerated(validValues: validValues))
        XCTAssertEqual(machine.attributes[0].attributes["driving_clock"]?.enumeratedValue, "new_clock")
        XCTAssertEqual(machine.attributes[0].attributes["driving_clock"]?.enumeratedValidValues, validValues)
    }

    /// Test the external variables are available in every state.
    func testStateExternalVariablesMatchMachineExternalVariables() {
        guard
            let externalSignals = (machine.attributes[0].attributes["external_signals"]?.tableValue.map {
                $0[2].lineValue
            })
        else {
            XCTFail("Failed to retrieve external signals in machine.")
            return
        }
        let externalSet = Set(externalSignals)
        XCTAssertEqual(
            schema?.stateSchema.variables.externals.type, .enumerableCollection(validValues: externalSet)
        )
        machine.states.forEach {
            XCTAssertEqual(
                externalSet, $0.attributes[0].attributes["externals"]?.enumerableCollectionValidValues
            )
        }
    }

    /// Test that creating a new external variables updates the states and the schema.
    func testTriggersAddNewExternalVariablesToStates() {
        guard
            let trigger = variables?.allTriggers,
            let externals = machine.attributes[0].attributes["external_signals"]?.tableValue
        else {
            XCTFail("Failed to retrieve trigger in group.")
            return
        }
        let newSignal: [LineAttribute] = [
            .enumerated("in", validValues: modes),
            .expression("std_logic", language: .vhdl),
            .line("new_external"),
            .expression("", language: .vhdl),
            .line("")
        ]
        machine.attributes[0].attributes["external_signals"]?.tableValue.append(newSignal)
        let path = AnyPath(
            Path(MetaMachine.self)
                .attributes[0]
                .attributes["external_signals"]
                .wrappedValue
                .tableValue[2]
        )
        XCTAssertTrue(trigger.isTriggerForPath(path, in: machine))
        XCTAssertTrue(try trigger.performTrigger(&machine, for: path).get())
        let newExternals = Set((externals + [newSignal]).map { $0[2].lineValue })
        XCTAssertEqual(
            schema?.stateSchema.variables.externals.type, .enumerableCollection(validValues: newExternals)
        )
        machine.states.forEach {
            let field = $0.attributes[0].fields.first { $0.name == "externals" }
            XCTAssertEqual(field?.type, .enumerableCollection(validValues: newExternals))
            XCTAssertEqual(
                newExternals, $0.attributes[0].attributes["externals"]?.enumerableCollectionValidValues
            )
        }
    }

    /// Test that removing an external variables updates the states and the schema.
    func testTriggersRemoveExternalVariablesFromStates() {
        guard
            let trigger = variables?.allTriggers,
            let externals = machine.attributes[0].attributes["external_signals"]?.tableValue
        else {
            XCTFail("Failed to retrieve trigger in group.")
            return
        }
        let removedExternals = Array(externals.dropFirst())
        machine.attributes[0].attributes["external_signals"]?.tableValue.remove(at: 0)
        let path = AnyPath(
            Path(MetaMachine.self)
                .attributes[0]
                .attributes["external_signals"]
                .wrappedValue
                .tableValue[0]
        )
        XCTAssertTrue(trigger.isTriggerForPath(path, in: machine))
        XCTAssertTrue(try trigger.performTrigger(&machine, for: path).get())
        let newExternals = Set(removedExternals.map { $0[2].lineValue })
        XCTAssertEqual(
            schema?.stateSchema.variables.externals.type, .enumerableCollection(validValues: newExternals)
        )
        machine.states.forEach {
            let field = $0.attributes[0].fields.first { $0.name == "externals" }
            XCTAssertEqual(field?.type, .enumerableCollection(validValues: newExternals))
            XCTAssertEqual(
                newExternals, $0.attributes[0].attributes["externals"]?.enumerableCollectionValidValues
            )
        }
    }

    /// Test that renaming an external variables updates the states and the schema.
    func testTriggersUpdateExternalVariablesInStates() {
        guard let trigger = variables?.allTriggers else {
            XCTFail("Failed to retrieve trigger in group.")
            return
        }
        machine.attributes[0].attributes["external_signals"]?.tableValue[0][2] = .line("znew_name")
        let path = AnyPath(
            Path(MetaMachine.self)
                .attributes[0]
                .attributes["external_signals"]
                .wrappedValue
                .tableValue[0][2]
                .lineValue
        )
        XCTAssertTrue(trigger.isTriggerForPath(path, in: machine))
        XCTAssertTrue(try trigger.performTrigger(&machine, for: path).get())
        let newExternals: Set<String> = ["znew_name", "y"]
        XCTAssertEqual(
            schema?.stateSchema.variables.externals.type, .enumerableCollection(validValues: newExternals)
        )
        machine.states.forEach {
            let field = $0.attributes[0].fields.first { $0.name == "externals" }
            XCTAssertEqual(field?.type, .enumerableCollection(validValues: newExternals))
            XCTAssertEqual(
                newExternals, $0.attributes[0].attributes["externals"]?.enumerableCollectionValidValues
            )
        }
    }

    /// Test that the validator rules throw errors for an invalid name.
    func testClockNameValidatorRules() throws {
        try [
            clockTable(name: "a%^&"),
            clockTable(name: "std_logic"),
            clockTable(name: "integer"),
            clockTable(name: "abs"),
            clockTable(name: "")
        ]
        .forEach {
            XCTAssertThrowsError(try variables?.clocks.validate.performValidation($0))
        }
        try [
            clockTable(name: "x"),
            clockTable(name: "y"),
            clockTable(name: "x_1"),
            clockTable(name: "_x"),
            clockTable(name: "abs3"),
            clockTable(name: "clk"),
            clockTable(name: "clk1"),
            clockTable(name: "clk_1"),
            clockTable(name: "clk_2"),
            clockTable(name: "clk50")
        ]
        .forEach {
            XCTAssertNoThrow(try variables?.clocks.validate.performValidation($0))
        }
    }

    /// Test that the validator rules throw errors for an invalid frequency.
    func testClockFrequencyValidatorRules() throws {
        try [
            clockTable(frequency: -1),
            clockTable(frequency: 0),
            clockTable(frequency: 1000),
            clockTable(frequency: -1000)
        ]
        .forEach {
            XCTAssertThrowsError(try variables?.clocks.validate.performValidation($0))
        }
        try [
            clockTable(frequency: 1),
            clockTable(frequency: 500),
            clockTable(frequency: 999)
        ]
        .forEach {
            XCTAssertNoThrow(try variables?.clocks.validate.performValidation($0))
        }
    }

    /// Test that the validator rules throw errors for an invalid unit.
    func testClockUnitValidatorRules() throws {
        try [
            clockTable(unit: "KHz"),
            clockTable(unit: "Mhz"),
            clockTable(unit: "ghz"),
            clockTable(unit: "integer"),
            clockTable(unit: "std_logic"),
            clockTable(unit: "freq"),
            clockTable(unit: "other")
        ]
        .forEach {
            XCTAssertThrowsError(try variables?.clocks.validate.performValidation($0))
        }
        try [
            clockTable(unit: "Hz"),
            clockTable(unit: "kHz"),
            clockTable(unit: "MHz"),
            clockTable(unit: "GHz"),
            clockTable(unit: "THz")
        ]
        .forEach {
            XCTAssertNoThrow(try variables?.clocks.validate.performValidation($0))
        }
    }

    /// Test validate throws error when clocks table is empty.
    func testClocksThrowsErrorWhenEmpty() throws {
        let attribute = Attribute.table([], columns: [
            ("name", .line),
            ("frequency", .integer),
            ("unit", .enumerated(validValues: frequencies))
        ])
        XCTAssertThrowsError(try variables?.clocks.validate.performValidation(attribute))
    }

    /// Test that driving clock validators enforce valid values.
    func testDrivingClockValidationRules() throws {
        try [
            Attribute.enumerated("", validValues: ["clk", "clk1"]),
            Attribute.enumerated("a", validValues: ["clk", "clk1"]),
            Attribute.enumerated("b", validValues: ["clk", "clk1"]),
            Attribute.enumerated("clk2", validValues: ["clk", "clk1"]),
            Attribute.enumerated("Clk1", validValues: ["clk", "clk1"]),
            Attribute.enumerated("Clk2", validValues: ["clk", "clk1"]),
            Attribute.enumerated("clk_1", validValues: ["clk", "clk1"])
        ]
        .forEach {
            XCTAssertThrowsError(try variables?.drivingClock.validate.performValidation($0))
        }
        try [
            Attribute.enumerated("clk", validValues: ["clk", "clk1"]),
            Attribute.enumerated("clk1", validValues: ["clk", "clk1"])
        ]
        .forEach {
            XCTAssertNoThrow(try variables?.drivingClock.validate.performValidation($0))
        }
    }

    /// Create a table for a clock.
    private func clockTable(name: String = "clk", frequency: Int = 50, unit: String = "MHz") -> Attribute {
        let row: [LineAttribute] = [
            .line(name),
            .integer(frequency),
            .enumerated(unit, validValues: frequencies)
        ]
        return .table(
            [row],
            columns: [
                ("name", .line),
                ("frequency", .integer),
                ("unit", .enumerated(validValues: frequencies))
            ]
        )
    }

}

// swiftlint:enable type_body_length
// swiftlint:enable file_length
