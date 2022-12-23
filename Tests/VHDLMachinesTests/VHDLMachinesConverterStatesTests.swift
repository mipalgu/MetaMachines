//
//  File.swift
//  File
//
//  Created by Morgan McColl on 18/9/21.
//

import Attributes
import Foundation
@testable import MetaMachines
import VHDLMachines
import XCTest

/// Test class for ``VHDLMachinesConverter``.
final class VHDLMachinesConverterStatesTests: XCTestCase {

    /// The machine to be converted.
    var machine = MetaMachine.initialMachine(forSemantics: .vhdl)

    /// The converter under test.
    let converter = VHDLMachinesConverter()

    /// The default actions in a state.
    let actions = [
        Action(name: "OnEntry", implementation: "", language: .vhdl),
        Action(name: "OnExit", implementation: "", language: .vhdl),
        Action(name: "OnSuspend", implementation: "", language: .vhdl),
        Action(name: "OnResume", implementation: "", language: .vhdl),
        Action(name: "Internal", implementation: "", language: .vhdl)
    ]

    /// The names of the default actions.
    var actionsNames: Set<String> {
        Set(actions.map(\.name))
    }

    /// The default attributes in an empty state.
    var stateAttributes: [AttributeGroup] {
        [
            AttributeGroup(
                name: "variables",
                fields: [
                    Field(name: "externals", type: .enumerableCollection(validValues: [])),
                    Field(
                        name: "state_signals",
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
                        name: "state_variables",
                        type: .table(
                            columns: [
                                ("type", .expression(language: .vhdl)),
                                ("lower_range", .line),
                                ("upper_range", .line),
                                ("name", .line),
                                ("value", .expression(language: .vhdl)),
                                ("comment", .line)
                            ]
                        )
                    )
                ],
                attributes: [
                    "externals": .enumerableCollection([], validValues: []),
                    "state_signals": .table(
                        [],
                        columns: [
                            ("type", .expression(language: .vhdl)),
                            ("name", .line),
                            ("value", .expression(language: .vhdl)),
                            ("comment", .line)
                        ]
                    ),
                    "state_variables": .table(
                        [],
                        columns: [
                            ("type", .expression(language: .vhdl)),
                            ("lower_range", .line),
                            ("upper_range", .line),
                            ("name", .line),
                            ("value", .expression(language: .vhdl)),
                            ("comment", .line)
                        ]
                    )
                ],
                metaData: [:]
            ),
            AttributeGroup(
                name: "actions",
                fields: [
                    Field(
                        name: "action_names", type: .table(columns: [("name", .line)])
                    ),
                    Field(
                        name: "action_order",
                        type: .table(
                            columns: [
                                ("timeslot", .integer),
                                ("action", .enumerated(validValues: actionsNames))
                            ]
                        )
                    )
                ],
                attributes: [
                    "action_names": .table(
                        [
                            [.line("Internal")],
                            [.line("OnEntry")],
                            [.line("OnExit")],
                            [.line("OnResume")],
                            [.line("OnSuspend")]

                        ],
                        columns: [("name", .line)]
                    ),
                    "action_order": .table(
                        [
                            [.integer(0), .enumerated("OnResume", validValues: actionsNames)],
                            [.integer(0), .enumerated("OnSuspend", validValues: actionsNames)],
                            [.integer(1), .enumerated("OnEntry", validValues: actionsNames)],
                            [.integer(2), .enumerated("OnExit", validValues: actionsNames)],
                            [.integer(2), .enumerated("Internal", validValues: actionsNames)]
                        ],
                        columns: [
                            ("timeslot", .integer),
                            ("action", .enumerated(validValues: actionsNames))
                        ]
                    )
                ],
                metaData: [:]
            )
        ]
    }

    /// Path to a test machine.
    let testMachinePath = URL(fileURLWithPath: "Test.machine", isDirectory: true)

    /// Default includes for a machine.
    let includes = ["library IEEE;", "use IEEE.std_logic_1164.All;"]

    /// The default actions in a state.
    let vhdlActions: [ActionName: String] = [
        "OnEntry": "",
        "OnExit": "",
        "OnSuspend": "",
        "OnResume": "",
        "Internal": ""
    ]

    /// Default states in a VHDL machine.
    var states: [VHDLMachines.State] {
        [
            VHDLMachines.State(
                name: "Initial",
                actions: vhdlActions,
                actionOrder: [["OnResume", "OnSuspend"], ["OnEntry"], ["OnExit", "Internal"]],
                signals: [],
                variables: [],
                externalVariables: []
            ),
            VHDLMachines.State(
                name: "Suspended",
                actions: vhdlActions,
                actionOrder: [["OnResume", "OnSuspend"], ["OnEntry"], ["OnExit", "Internal"]],
                signals: [],
                variables: [],
                externalVariables: []
            )
        ]
    }

    /// A default VHDL machine.
    lazy var vhdlMachine = VHDLMachines.Machine(
        name: machine.name,
        path: URL(fileURLWithPath: "\(machine.name).machine", isDirectory: true),
        includes: ["library IEEE;", "use IEEE.std_logic_1164.All;"],
        externalSignals: [],
        generics: [],
        clocks: [Clock(name: "clk", frequency: 50, unit: .MHz)],
        drivingClock: 0,
        dependentMachines: [:],
        machineVariables: [],
        machineSignals: [],
        isParameterised: false,
        parameterSignals: [],
        returnableSignals: [],
        states: states,
        transitions: [],
        initialState: 0,
        suspendedState: 1
    )

    /// Initialise the machine before every test.
    override func setUp() {
        machine = MetaMachine.initialMachine(forSemantics: .vhdl)
        vhdlMachine = VHDLMachines.Machine(
            name: machine.name,
            path: URL(fileURLWithPath: "\(machine.name).machine", isDirectory: true),
            includes: ["library IEEE;", "use IEEE.std_logic_1164.All;"],
            externalSignals: [],
            generics: [],
            clocks: [Clock(name: "clk", frequency: 50, unit: .MHz)],
            drivingClock: 0,
            dependentMachines: [:],
            machineVariables: [],
            machineSignals: [],
            isParameterised: false,
            parameterSignals: [],
            returnableSignals: [],
            states: states,
            transitions: [],
            initialState: 0,
            suspendedState: 1
        )
        super.setUp()
    }

    // /// Test toLineAttribute for action order.
    // func testActionOrderToLineAttribute() {
    //     let actionOrder = [["OnResume", "OnSuspend"], ["OnEntry"], ["OnExit", "Internal"]]
    //     let validValues = actionsNames
    //     let attribute = converter.toLineAttribute(actionOrder: actionOrder, validValues: validValues)
    //     let expected: [[LineAttribute]] = [
    //         [.integer(0), .enumerated("OnResume", validValues: validValues)],
    //         [.integer(0), .enumerated("OnSuspend", validValues: validValues)],
    //         [.integer(1), .enumerated("OnEntry", validValues: validValues)],
    //         [.integer(2), .enumerated("OnExit", validValues: validValues)],
    //         [.integer(2), .enumerated("Internal", validValues: validValues)]
    //     ]
    //     XCTAssertEqual(attribute, expected)
    // }

    // /// Test the state attributes match the expected ones.
    // func testStateAttributes() {
    //     let intialState = vhdlMachine.states[0]
    //     let attributes = converter.stateAttributes(state: intialState, machine: vhdlMachine)
    //     XCTAssertEqual(attributes, stateAttributes)
    // }

    /// Test converter creates correct machine.
    func testConverterProducesMachine() throws {
        let vhdlMachine = try converter.convert(machine: machine)
        let states = [
            VHDLMachines.State(
                name: "Initial",
                actions: vhdlActions,
                actionOrder: [["OnResume", "OnSuspend"], ["OnEntry"], ["OnExit", "Internal"]],
                signals: [],
                variables: [],
                externalVariables: []
            ),
            VHDLMachines.State(
                name: "Suspended",
                actions: vhdlActions,
                actionOrder: [["OnResume", "OnSuspend"], ["OnEntry"], ["OnExit", "Internal"]],
                signals: [],
                variables: [],
                externalVariables: []
            )
        ]
        let expected = VHDLMachines.Machine(
            name: machine.name,
            path: URL(fileURLWithPath: "\(machine.name).machine", isDirectory: true),
            includes: ["library IEEE;", "use IEEE.std_logic_1164.All;"],
            externalSignals: [],
            generics: [],
            clocks: [Clock(name: "clk", frequency: 50, unit: .MHz)],
            drivingClock: 0,
            dependentMachines: [:],
            machineVariables: [],
            machineSignals: [],
            isParameterised: false,
            parameterSignals: [],
            returnableSignals: [],
            states: states,
            transitions: [],
            initialState: 0,
            suspendedState: 1
        )
        XCTAssertEqual(expected, vhdlMachine)
    }
}
