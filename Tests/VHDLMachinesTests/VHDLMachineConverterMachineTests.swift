// VHDLMachineConverterMachineTests.swift 
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
import XCTest

/// Test class for ``VHDLMachineConverter``.
final class VHDLMachineConverterMachineTests: XCTestCase {

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

    /// The default machine attributes.
    let machineAttributes = [
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

    /// Initialise the machine before every test.
    override func setUp() {
        machine = MetaMachine.initialMachine(forSemantics: .vhdl)
        super.setUp()
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

}
