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

    /// Test the state attributes match the expected ones.
    func testStateAttributes() {
        let intialState = vhdlMachine.states[0]
        let attributes = converter.stateAttributes(state: intialState, machine: vhdlMachine)
        let stateAttributes = stateAttributes
        XCTAssertEqual(attributes.count, stateAttributes.count)
        zip(attributes, stateAttributes).forEach {
            XCTAssertEqual($0.name, $1.name)
            XCTAssertEqual($0.fields.count, $1.fields.count)
            zip($0.fields, $1.fields).forEach {
                XCTAssertEqual($0.name, $1.name)
                XCTAssertEqual($0.type, $1.type)
            }
            XCTAssertEqual($0.attributes.count, $1.attributes.count)
            zip($0.attributes.sorted { $0.0 < $1.0 }, $1.attributes.sorted { $0.0 < $1.0 }).forEach {
                let lhs = $0.1
                let rhs = $1.1
                XCTAssertEqual($0.0, $1.0)
                XCTAssertEqual(lhs, rhs)
            }
        }
    }

    // func testInitialMachine() {
    //     let machine = converter.initialVHDLMachine(
    //         filePath: URL(fileURLWithPath: "Test.machine", isDirectory: true)
    //     )
    //     let states = [
    //         State(
    //             name: "Initial",
    //             actions: actions,
    //             transitions: [],
    //             attributes: stateAttributes,
    //             metaData: []
    //         ),
    //         State(
    //             name: "Suspended",
    //             actions: actions,
    //             transitions: [],
    //             attributes: stateAttributes,
    //             metaData: []
    //         )
    //     ]
    //     let expected = MetaMachine(
    //         semantics: .vhdl,
    //         mutator: SchemaMutator(schema: VHDLSchema()),
    //         name: "Test",
    //         initialState: "Initial",
    //         states: states,
    //         dependencies: [],
    //         attributes: [AttributeGroup],
    //         metaData: [AttributeGroup]
    //     )
    // }

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
        XCTAssertEqual(vhdlMachine.name, expected.name)
        XCTAssertEqual(vhdlMachine.includes, expected.includes)
        XCTAssertEqual(vhdlMachine.externalSignals, expected.externalSignals)
        XCTAssertEqual(vhdlMachine.generics, expected.generics)
        XCTAssertEqual(vhdlMachine.clocks, expected.clocks)
        XCTAssertEqual(vhdlMachine.drivingClock, expected.drivingClock)
        XCTAssertEqual(vhdlMachine.dependentMachines, expected.dependentMachines)
        XCTAssertEqual(vhdlMachine.machineVariables, expected.machineVariables)
        XCTAssertEqual(vhdlMachine.machineSignals, expected.machineSignals)
        XCTAssertEqual(vhdlMachine.isParameterised, expected.isParameterised)
        XCTAssertEqual(vhdlMachine.parameterSignals, expected.parameterSignals)
        XCTAssertEqual(vhdlMachine.returnableSignals, expected.returnableSignals)
        XCTAssertEqual(vhdlMachine.states.count, expected.states.count)
        for (state, expectedState) in zip(vhdlMachine.states, expected.states) {
            XCTAssertEqual(state.name, expectedState.name)
            XCTAssertEqual(state.actions, expectedState.actions)
            XCTAssertEqual(state.actionOrder, expectedState.actionOrder)
            XCTAssertEqual(state.signals, expectedState.signals)
            XCTAssertEqual(state.variables, expectedState.variables)
            XCTAssertEqual(state.externalVariables, expectedState.externalVariables)
        }
        XCTAssertEqual(vhdlMachine.transitions, expected.transitions)
        XCTAssertEqual(vhdlMachine.initialState, expected.initialState)
        XCTAssertEqual(vhdlMachine.suspendedState, expected.suspendedState)
    }
}

// [
//     Attributes.AttributeGroup(
//         name: "variables",
//         fields: [
//             Attributes.Field(
//                 name: "externals",
//                 type: Attributes.AttributeType.block(
//                     Attributes.BlockAttributeType.enumerableCollection(validValues: Set([]))
//                 )
//             ),
//             Attributes.Field(
//                 name: "state_signals",
//                 type: Attributes.AttributeType.block(
//                     Attributes.BlockAttributeType.table(
//                         columns: [
//                             Attributes.BlockAttributeType.TableColumn(
//                                 name: "type",
//                                 type: Attributes.LineAttributeType.expression(
//                                     language: Attributes.Language.vhdl
//                                 )
//                             ),
//                             Attributes.BlockAttributeType.TableColumn(
//                                 name: "name", type: Attributes.LineAttributeType.line
//                             ),
//                             Attributes.BlockAttributeType.TableColumn(
//                                 name: "value",
//                                 type: Attributes.LineAttributeType.expression(
//                                     language: Attributes.Language.vhdl
//                                 )
//                             ),
//                             Attributes.BlockAttributeType.TableColumn(
//                                 name: "comment", type: Attributes.LineAttributeType.line
//                             )
//                         ]
//                     )
//                 )
//             ),
//             Attributes.Field(
//                 name: "state_variables",
//                 type: Attributes.AttributeType.block(
//                     Attributes.BlockAttributeType.table(
//                         columns: [
//                             Attributes.BlockAttributeType.TableColumn(
//                                 name: "type",
//                                 type: Attributes.LineAttributeType.expression(
//                                     language: Attributes.Language.vhdl
//                                 )
//                             ),
//                             Attributes.BlockAttributeType.TableColumn(
//                                 name: "lower_range", type: Attributes.LineAttributeType.line
//                             ),
//                             Attributes.BlockAttributeType.TableColumn(
//                                 name: "upper_range", type: Attributes.LineAttributeType.line
//                             ),
//                             Attributes.BlockAttributeType.TableColumn(
//                                 name: "name", type: Attributes.LineAttributeType.line
//                             ),
//                             Attributes.BlockAttributeType.TableColumn(
//                                 name: "value",
//                                 type: Attributes.LineAttributeType.expression(
//                                     language: Attributes.Language.vhdl
//                                 )
//                             ),
//                             Attributes.BlockAttributeType.TableColumn(
//                                 name: "comment", type: Attributes.LineAttributeType.line
//                             )
//                         ]
//                     )
//                 )
//             )
//         ],
//         attributes: [
//             "externals": Attributes.Attribute.block(
//                 Attributes.BlockAttribute.enumerableCollection(Set([]), validValues: Set([]))
//             ),
//             "state_signals": Attributes.Attribute.block(
//                 Attributes.BlockAttribute.table(
//                     [],
//                     columns: [
//                         Attributes.BlockAttributeType.TableColumn(
//                             name: "type",
//                             type: Attributes.LineAttributeType.expression(language: Attributes.Language.vhdl)
//                         ),
//                         Attributes.BlockAttributeType.TableColumn(
//                             name: "name", type: Attributes.LineAttributeType.line
//                         ),
//                         Attributes.BlockAttributeType.TableColumn(
//                             name: "value",
//                             type: Attributes.LineAttributeType.expression(language: Attributes.Language.vhdl)
//                         ),
//                         Attributes.BlockAttributeType.TableColumn(
//                             name: "comment", type: Attributes.LineAttributeType.line
//                         )
//                     ]
//                 )
//             ),
//             "state_variables": Attributes.Attribute.block(
//                 Attributes.BlockAttribute.table(
//                     [],
//                     columns: [
//                         Attributes.BlockAttributeType.TableColumn(
//                             name: "type",
//                             type: Attributes.LineAttributeType.expression(language: Attributes.Language.vhdl)
//                         ),
//                         Attributes.BlockAttributeType.TableColumn(
//                             name: "lower_range", type: Attributes.LineAttributeType.line
//                         ),
//                         Attributes.BlockAttributeType.TableColumn(
//                             name: "upper_range", type: Attributes.LineAttributeType.line
//                         ),
//                         Attributes.BlockAttributeType.TableColumn(
//                             name: "name", type: Attributes.LineAttributeType.line
//                         ),
//                         Attributes.BlockAttributeType.TableColumn(
//                             name: "value",
//                             type: Attributes.LineAttributeType.expression(
//                                 language: Attributes.Language.vhdl
//                             )
//                         ),
//                         Attributes.BlockAttributeType.TableColumn(
//                             name: "comment", type: Attributes.LineAttributeType.line
//                         )
//                     ]
//                 )
//             )
//         ],
//         metaData: [:]
//     ),
//     Attributes.AttributeGroup(
//         name: "actions",
//         fields: [
//             Attributes.Field(
//                 name: "action_names",
//                 type: Attributes.AttributeType.block(
//                     Attributes.BlockAttributeType.table(
//                         columns: [
//                             Attributes.BlockAttributeType.TableColumn(
//                                 name: "name", type: Attributes.LineAttributeType.line
//                             )
//                         ]
//                     )
//                 )
//             ),
//             Attributes.Field(
//                 name: "action_order",
//                 type: Attributes.AttributeType.block(
//                     Attributes.BlockAttributeType.table(
//                         columns: [
//                             Attributes.BlockAttributeType.TableColumn(
//                                 name: "timeslot", type: Attributes.LineAttributeType.integer
//                             ),
//                             Attributes.BlockAttributeType.TableColumn(
//                                 name: "action",
//                                 type: Attributes.LineAttributeType.enumerated(
//                                     validValues: Set(
//                                         ["Internal", "OnSuspend", "OnResume", "OnExit", "OnEntry"]
//                                     )
//                                 )
//                             )
//                         ]
//                     )
//                 )
//             )
//         ],
//         attributes: [
//             "action_names": Attributes.Attribute.block(
//                 Attributes.BlockAttribute.table(
//                     [
//                         [Attributes.LineAttribute.line("Internal")],
//                         [Attributes.LineAttribute.line("OnExit")],
//                         [Attributes.LineAttribute.line("OnSuspend")],
//                         [Attributes.LineAttribute.line("OnEntry")],
//                         [Attributes.LineAttribute.line("OnResume")]
//                     ],
//                     columns: [
//                         Attributes.BlockAttributeType.TableColumn(
//                             name: "name", type: Attributes.LineAttributeType.line
//                         )
//                     ]
//                 )
//             ),
//             "action_order": Attributes.Attribute.block(
//                 Attributes.BlockAttribute.table(
//                     [
                        
//                         [
//                             Attributes.LineAttribute.integer(0),
//                             Attributes.LineAttribute.enumerated(
//                                 "OnResume",
//                                 validValues: Set(["OnExit", "OnSuspend", "Internal", "OnEntry", "OnResume"])
//                             ),
//                             Attributes.LineAttribute.integer(0),
//                             Attributes.LineAttribute.enumerated(
//                                 "OnSuspend",
//                                 validValues: Set(["OnExit", "OnSuspend", "Internal", "OnEntry", "OnResume"])
//                             )
//                         ],
//                         [
//                             Attributes.LineAttribute.integer(1),
//                             Attributes.LineAttribute.enumerated(
//                                 "OnEntry",
//                                 validValues: Set(["OnExit", "OnSuspend", "Internal", "OnEntry", "OnResume"])
//                             )
//                         ],
//                         [
//                             Attributes.LineAttribute.integer(2),
//                             Attributes.LineAttribute.enumerated(
//                                 "OnExit",
//                                 validValues: Set(["OnExit", "OnSuspend", "Internal", "OnEntry", "OnResume"])
//                             ),
//                             Attributes.LineAttribute.integer(2),
//                             Attributes.LineAttribute.enumerated(
//                                 "Internal",
//                                 validValues: Set(["OnExit", "OnSuspend", "Internal", "OnEntry", "OnResume"])
//                             )
//                         ]
//                     ],
//                     columns: [
//                         Attributes.BlockAttributeType.TableColumn(
//                             name: "timeslot", type: Attributes.LineAttributeType.integer
//                         ),
//                         Attributes.BlockAttributeType.TableColumn(
//                             name: "action",
//                             type: Attributes.LineAttributeType.enumerated(
//                                 validValues: Set(["Internal", "OnResume", "OnExit", "OnSuspend", "OnEntry"])
//                             )
//                         )
//                     ]
//                 )
//             )
//         ],
//         metaData: [:]
//     )
// ]

// [
//     Attributes.AttributeGroup(
//         name: "variables",
//         fields: [
//             Attributes.Field(
//                 name: "externals",
//                 type: Attributes.AttributeType.block(
//                     Attributes.BlockAttributeType.enumerableCollection(validValues: Set([]))
//                 )
//             ),
//             Attributes.Field(
//                 name: "state_signals",
//                 type: Attributes.AttributeType.block(
//                     Attributes.BlockAttributeType.table(
//                         columns: [
//                             Attributes.BlockAttributeType.TableColumn(
//                                 name: "type",
//                                 type: Attributes.LineAttributeType.expression(
//                                     language: Attributes.Language.vhdl
//                                 )
//                             ),
//                             Attributes.BlockAttributeType.TableColumn(
//                                 name: "name", type: Attributes.LineAttributeType.line
//                             ),
//                             Attributes.BlockAttributeType.TableColumn(
//                                 name: "value",
//                                 type: Attributes.LineAttributeType.expression(
//                                     language: Attributes.Language.vhdl
//                                 )
//                             ),
//                             Attributes.BlockAttributeType.TableColumn(
//                                 name: "comment", type: Attributes.LineAttributeType.line
//                             )
//                         ]
//                     )
//                 )
//             ),
//             Attributes.Field(
//                 name: "state_variables",
//                 type: Attributes.AttributeType.block(
//                     Attributes.BlockAttributeType.table(
//                         columns: [
//                             Attributes.BlockAttributeType.TableColumn(
//                                 name: "type",
//                                 type: Attributes.LineAttributeType.expression(
//                                     language: Attributes.Language.vhdl
//                                 )
//                             ),
//                             Attributes.BlockAttributeType.TableColumn(
//                                 name: "lower_range", type: Attributes.LineAttributeType.line
//                             ),
//                             Attributes.BlockAttributeType.TableColumn(
//                                 name: "upper_range", type: Attributes.LineAttributeType.line
//                             ),
//                             Attributes.BlockAttributeType.TableColumn(
//                                 name: "name", type: Attributes.LineAttributeType.line
//                             ),
//                             Attributes.BlockAttributeType.TableColumn(
//                                 name: "value",
//                                 type: Attributes.LineAttributeType.expression(
//                                     language: Attributes.Language.vhdl
//                                 )
//                             ),
//                             Attributes.BlockAttributeType.TableColumn(
//                                 name: "comment", type: Attributes.LineAttributeType.line
//                             )
//                         ]
//                     )
//                 )
//             )
//         ],
//         attributes: [
//             "state_variables": Attributes.Attribute.block(
//                 Attributes.BlockAttribute.table(
//                     [],
//                     columns: [
//                         Attributes.BlockAttributeType.TableColumn(
//                             name: "type",
//                             type: Attributes.LineAttributeType.expression(language: Attributes.Language.vhdl)
//                         ),
//                         Attributes.BlockAttributeType.TableColumn(
//                             name: "lower_range", type: Attributes.LineAttributeType.line
//                         ),
//                         Attributes.BlockAttributeType.TableColumn(
//                             name: "upper_range", type: Attributes.LineAttributeType.line
//                         ),
//                         Attributes.BlockAttributeType.TableColumn(
//                             name: "name", type: Attributes.LineAttributeType.line
//                         ),
//                         Attributes.BlockAttributeType.TableColumn(
//                             name: "value",
//                             type: Attributes.LineAttributeType.expression(language: Attributes.Language.vhdl)
//                         ),
//                         Attributes.BlockAttributeType.TableColumn(
//                             name: "comment", type: Attributes.LineAttributeType.line
//                         )
//                     ]
//                 )
//             ),
//             "externals": Attributes.Attribute.block(
//                 Attributes.BlockAttribute.enumerableCollection(Set([]), validValues: Set([]))
//             ),
//             "state_signals": Attributes.Attribute.block(
//                 Attributes.BlockAttribute.table(
//                     [],
//                     columns: [
//                         Attributes.BlockAttributeType.TableColumn(
//                             name: "type",
//                             type: Attributes.LineAttributeType.expression(language: Attributes.Language.vhdl)
//                         ),
//                         Attributes.BlockAttributeType.TableColumn(
//                             name: "name", type: Attributes.LineAttributeType.line
//                         ),
//                         Attributes.BlockAttributeType.TableColumn(
//                             name: "value",
//                             type: Attributes.LineAttributeType.expression(language: Attributes.Language.vhdl)
//                         ),
//                         Attributes.BlockAttributeType.TableColumn(
//                             name: "comment", type: Attributes.LineAttributeType.line
//                         )
//                     ]
//                 )
//             )
//         ],
//         metaData: [:]
//     ),
//     Attributes.AttributeGroup(
//         name: "actions",
//         fields: [
//             Attributes.Field(
//                 name: "action_names",
//                 type: Attributes.AttributeType.block(
//                     Attributes.BlockAttributeType.table(
//                         columns: [
//                             Attributes.BlockAttributeType.TableColumn(
//                                 name: "name", type: Attributes.LineAttributeType.line
//                             )
//                         ]
//                     )
//                 )
//             ),
//             Attributes.Field(
//                 name: "action_order",
//                 type: Attributes.AttributeType.block(
//                     Attributes.BlockAttributeType.table(
//                         columns: [
//                             Attributes.BlockAttributeType.TableColumn(
//                                 name: "timeslot", type: Attributes.LineAttributeType.integer
//                             ),
//                             Attributes.BlockAttributeType.TableColumn(
//                                 name: "action", 
//                                 type: Attributes.LineAttributeType.enumerated(
//                                     validValues: Set(
//                                         ["OnEntry", "OnSuspend", "OnResume", "Internal", "OnExit"]
//                                     )
//                                 )
//                             )
//                         ]
//                     )
//                 )
//             )
//         ],
//         attributes: [
//             "action_order": Attributes.Attribute.block(
//                 Attributes.BlockAttribute.table(
//                     [
//                         [
//                             Attributes.LineAttribute.integer(0),
//                             Attributes.LineAttribute.enumerated(
//                                 "OnResume",
//                                 validValues: Set(["OnEntry", "OnSuspend", "OnResume", "Internal", "OnExit"])
//                             )
//                         ],
//                         [
//                             Attributes.LineAttribute.integer(0),
//                             Attributes.LineAttribute.enumerated(
//                                 "OnSuspend",
//                                 validValues: Set(["OnEntry", "OnResume", "OnSuspend", "OnExit", "Internal"])
//                             )
//                         ],
//                         [
//                             Attributes.LineAttribute.integer(1),
//                             Attributes.LineAttribute.enumerated(
//                                 "OnEntry",
//                                 validValues: Set(["OnExit", "OnResume", "OnSuspend", "Internal", "OnEntry"])
//                             )
//                         ],
//                         [
//                             Attributes.LineAttribute.integer(2),
//                             Attributes.LineAttribute.enumerated(
//                                 "OnExit",
//                                 validValues: Set(["OnResume", "Internal", "OnEntry", "OnExit", "OnSuspend"])
//                             )
//                         ],
//                         [
//                             Attributes.LineAttribute.integer(2),
//                             Attributes.LineAttribute.enumerated(
//                                 "Internal",
//                                 validValues: Set(["OnSuspend", "Internal", "OnEntry", "OnResume", "OnExit"])
//                             )
//                         ]
//                     ],
//                     columns: [
//                         Attributes.BlockAttributeType.TableColumn(
//                             name: "timeslot", type: Attributes.LineAttributeType.integer
//                         ),
//                         Attributes.BlockAttributeType.TableColumn(
//                             name: "action",
//                             type: Attributes.LineAttributeType.enumerated(
//                                 validValues: Set(["OnSuspend", "OnExit", "OnResume", "Internal", "OnEntry"])
//                             )
//                         )
//                     ]
//                 )
//             ),
//             "action_names": Attributes.Attribute.block(
//                 Attributes.BlockAttribute.table(
//                     [
//                         [Attributes.LineAttribute.line("Internal")],
//                         [Attributes.LineAttribute.line("OnEntry")],
//                         [Attributes.LineAttribute.line("OnExit")],
//                         [Attributes.LineAttribute.line("OnResume")],
//                         [Attributes.LineAttribute.line("OnSuspend")]
//                     ],
//                     columns: [
//                         Attributes.BlockAttributeType.TableColumn(
//                             name: "name", type: Attributes.LineAttributeType.line
//                         )
//                     ]
//                 )
//             )
//         ]
//         metaData: [:]
//     )
// ]
