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
final class VHDLMachinesConverterTests: XCTestCase {

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

    /// The default machine attributes.
    var machineAttributes: [AttributeGroup] {
        [
            AttributeGroup(
                name: "variables",
                fields: [
                    Field(
                        name: "clocks",
                        type: .table(
                            columns: [
                                ("name", .line),
                                ("frequency", .integer),
                                ("unit", .enumerated(validValues: ["Hz", "kHz", "MHz", "GHz", "THz"]))
                            ]
                        )
                    ),
                    Field(
                        name: "external_signals",
                        type: .table(
                            columns: [
                                ("mode", .enumerated(validValues: ["in", "out", "inout", "buffer"])),
                                ("type", .expression(language: .vhdl)),
                                ("name", .line),
                                ("value", .expression(language: .vhdl)),
                                ("comment", .line)
                            ]
                        )
                    ),
                    Field(
                        name: "generics",
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
                        name: "machine_signals",
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
                        name: "machine_variables",
                        type: .table(
                            columns: [
                                ("type", .expression(language: .vhdl)),
                                ("name", .line),
                                ("value", .expression(language: .vhdl)),
                                ("comment", .line)
                            ]
                        )
                    ),
                    Field(name: "driving_clock", type: .enumerated(validValues: ["clk"]))
                ],
                attributes: [
                    "clocks": .table(
                        [
                            [
                                .line("clk"),
                                .integer(50),
                                .enumerated("MHz", validValues: ["Hz", "kHz", "MHz", "GHz", "THz"])
                            ]
                        ],
                        columns: [
                            ("name", .line),
                            ("frequency", .integer),
                            ("unit", .enumerated(validValues: ["Hz", "kHz", "MHz", "GHz", "THz"]))
                        ]
                    ),
                    "external_signals": .table([], columns: [
                        ("mode", .enumerated(validValues: ["in", "out", "inout", "buffer"])),
                        ("type", .expression(language: .vhdl)),
                        ("name", .line),
                        ("value", .expression(language: .vhdl)),
                        ("comment", .line)
                    ]),
                    "generics": .table([], columns: [
                        ("type", .expression(language: .vhdl)),
                        ("name", .line),
                        ("value", .expression(language: .vhdl)),
                        ("comment", .line)
                    ]),
                    "machine_signals": .table([], columns: [
                        ("type", .expression(language: .vhdl)),
                        ("name", .line),
                        ("value", .expression(language: .vhdl)),
                        ("comment", .line)
                    ]),
                    "machine_variables": .table([], columns: [
                        ("type", .expression(language: .vhdl)),
                        ("name", .line),
                        ("value", .expression(language: .vhdl)),
                        ("comment", .line)
                    ]),
                    "driving_clock": .enumerated("clk", validValues: ["clk"])
                ],
                metaData: [:]
            ),
            AttributeGroup(
                name: "parameters",
                fields: [
                    Field(name: "is_parameterised", type: .bool),
                    Field(name: "parameter_signals", type: .table(
                        columns: [
                            ("type", .expression(language: .vhdl)),
                            ("name", .line),
                            ("value", .expression(language: .vhdl)),
                            ("comment", .line)
                        ]
                    )),
                    Field(name: "returnable_signals", type: .table(
                        columns: [
                            ("type", .expression(language: .vhdl)),
                            ("name", .line),
                            ("comment", .line)
                        ]
                    ))
                ],
                attributes: [
                    "is_parameterised": .bool(false),
                    "parameter_signals": .table([], columns: [
                        ("type", .expression(language: .vhdl)),
                        ("name", .line),
                        ("value", .expression(language: .vhdl)),
                        ("comment", .line)
                    ]),
                    "returnable_signals": .table([], columns: [
                        ("type", .expression(language: .vhdl)),
                        ("name", .line),
                        ("comment", .line)
                    ])
                ],
                metaData: [:]
            ),
            AttributeGroup(
                name: "includes",
                fields: [
                    Field(name: "includes", type: .code(language: .vhdl)),
                    Field(name: "architecture_head", type: .code(language: .vhdl)),
                    Field(name: "architecture_body", type: .code(language: .vhdl))
                ],
                attributes: [
                    "includes": .code("library IEEE;\nuse IEEE.std_logic_1164.All;", language: .vhdl),
                    "architecture_head": .code("", language: .vhdl),
                    "architecture_body": .code("", language: .vhdl)
                ],
                metaData: [:]
            ),
            AttributeGroup(
                name: "settings",
                fields: [
                    Field(
                        name: "initial_state", type: .enumerated(validValues: ["Initial", "Suspended", ""])
                    ),
                    Field(
                        name: "suspended_state", type: .enumerated(validValues: ["Initial", "Suspended", ""])
                    )
                ],
                attributes: [
                    "initial_state": .enumerated("Initial", validValues: ["Initial", "Suspended", ""]),
                    "suspended_state": .enumerated("Suspended", validValues: ["Initial", "Suspended", ""])
                ],
                metaData: [:]
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

    /// Test toLineAttribute for action order.
    func testActionOrderToLineAttribute() {
        let actionOrder = [["OnResume", "OnSuspend"], ["OnEntry"], ["OnExit", "Internal"]]
        let validValues = actionsNames
        let attribute = converter.toLineAttribute(actionOrder: actionOrder, validValues: validValues)
        let expected: [[LineAttribute]] = [
            [.integer(0), .enumerated("OnResume", validValues: validValues)],
            [.integer(0), .enumerated("OnSuspend", validValues: validValues)],
            [.integer(1), .enumerated("OnEntry", validValues: validValues)],
            [.integer(2), .enumerated("OnExit", validValues: validValues)],
            [.integer(2), .enumerated("Internal", validValues: validValues)]
        ]
        XCTAssertEqual(attribute, expected)
    }

    /// Test the state attributes match the expected ones.
    func testStateAttributes() {
        let intialState = vhdlMachine.states[0]
        let attributes = converter.stateAttributes(state: intialState, machine: vhdlMachine)
        XCTAssertEqual(attributes, stateAttributes)
    }

    /// Test initial machine is set up correctly.
    func testInitialMachine() {
        let machine = converter.initialVHDLMachine(
            filePath: URL(fileURLWithPath: "Test.machine", isDirectory: true)
        )
        let states = [
            State(
                name: "Initial",
                actions: actions,
                transitions: [],
                attributes: stateAttributes,
                metaData: []
            ),
            State(
                name: "Suspended",
                actions: actions,
                transitions: [],
                attributes: stateAttributes,
                metaData: []
            )
        ]
        let expected = MetaMachine(
            semantics: .vhdl,
            mutator: SchemaMutator(schema: VHDLSchema(dependencyLayout: [])),
            name: "Test",
            initialState: "Initial",
            states: states,
            dependencies: [],
            attributes: machineAttributes,
            metaData: []
        )
        XCTAssertEqual(expected, machine)
    }

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
