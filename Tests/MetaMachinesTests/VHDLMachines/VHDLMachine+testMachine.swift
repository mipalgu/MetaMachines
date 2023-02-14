// VHDLMachine+testMachine.swift 
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
import Foundation
import VHDLMachines

/// Add test machine data.
extension Machine {

    /// The machine attributes that are equivalent to the test machine.
    static var testAttributes: [AttributeGroup] {
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
                    Field(name: "driving_clock", type: .enumerated(validValues: ["clk", "clk1"])),
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
                                ("lower_range", .line),
                                ("upper_range", .line),
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
                    "clocks": .table(
                        [
                            [
                                .line("clk"),
                                .integer(50),
                                .enumerated("MHz", validValues: ["Hz", "kHz", "MHz", "GHz", "THz"])
                            ],
                            [
                                .line("clk1"),
                                .integer(1),
                                .enumerated("GHz", validValues: ["Hz", "kHz", "MHz", "GHz", "THz"])
                            ]
                        ],
                        columns: [
                            ("name", .line),
                            ("frequency", .integer),
                            ("unit", .enumerated(validValues: ["Hz", "kHz", "MHz", "GHz", "THz"]))
                        ]
                    ),
                    "external_signals": .table(
                        [
                            [
                                .enumerated("in", validValues: ["in", "out", "inout", "buffer"]),
                                .expression("std_logic", language: .vhdl),
                                .line("x"),
                                .expression("'1'", language: .vhdl),
                                .line("Signal x.")
                            ],
                            [
                                .enumerated("out", validValues: ["in", "out", "inout", "buffer"]),
                                .expression("std_logic", language: .vhdl),
                                .line("y"),
                                .expression("'0'", language: .vhdl),
                                .line("Signal y.")
                            ]
                        ],
                        columns: [
                            ("mode", .enumerated(validValues: ["in", "out", "inout", "buffer"])),
                            ("type", .expression(language: .vhdl)),
                            ("name", .line),
                            ("value", .expression(language: .vhdl)),
                            ("comment", .line)
                        ]
                    ),
                    "generics": .table(
                        [
                            [
                                .expression("boolean", language: .vhdl),
                                .line(""),
                                .line(""),
                                .line("hasX"),
                                .expression("true", language: .vhdl),
                                .line("Bool hasX.")
                            ],
                            [
                                .expression("integer", language: .vhdl),
                                .line("0"),
                                .line("255"),
                                .line("numX"),
                                .expression("1", language: .vhdl),
                                .line("Int numX.")
                            ]
                        ],
                        columns: [
                            ("type", .expression(language: .vhdl)),
                            ("lower_range", .line),
                            ("upper_range", .line),
                            ("name", .line),
                            ("value", .expression(language: .vhdl)),
                            ("comment", .line)
                        ]
                    ),
                    "machine_signals": .table(
                        [
                            [
                                .expression("std_logic", language: .vhdl),
                                .line("a"),
                                .expression("'0'", language: .vhdl),
                                .line("Signal a.")
                            ],
                            [
                                .expression("std_logic", language: .vhdl),
                                .line("b"),
                                .expression("'1'", language: .vhdl),
                                .line("Signal b.")
                            ]
                        ],
                        columns: [
                            ("type", .expression(language: .vhdl)),
                            ("name", .line),
                            ("value", .expression(language: .vhdl)),
                            ("comment", .line)
                        ]
                    ),
                    "machine_variables": .table(
                        [
                            [
                                .expression("integer", language: .vhdl),
                                .line("0"),
                                .line("127"),
                                .line("numA"),
                                .expression("0", language: .vhdl),
                                .line("Int numA.")
                            ],
                            [
                                .expression("integer", language: .vhdl),
                                .line("0"),
                                .line("127"),
                                .line("numB"),
                                .expression("10", language: .vhdl),
                                .line("Int numB.")
                            ]
                        ],
                        columns: [
                            ("type", .expression(language: .vhdl)),
                            ("lower_range", .line),
                            ("upper_range", .line),
                            ("name", .line),
                            ("value", .expression(language: .vhdl)),
                            ("comment", .line)
                        ]
                    ),
                    "driving_clock": .enumerated("clk", validValues: ["clk", "clk1"])
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
                    "is_parameterised": .bool(true),
                    "parameter_signals": .table(
                        [
                            [
                                .expression("unsigned", language: .vhdl),
                                .line("timeout"),
                                .expression("250", language: .vhdl),
                                .line("Unsigned timeout.")

                            ],
                            [
                                .expression("std_logic", language: .vhdl),
                                .line("defaultReturns"),
                                .expression("'1'", language: .vhdl),
                                .line("Signal defaultReturns.")
                            ]
                        ],
                        columns: [
                            ("type", .expression(language: .vhdl)),
                            ("name", .line),
                            ("value", .expression(language: .vhdl)),
                            ("comment", .line)
                        ]
                    ),
                    "returnable_signals": .table(
                        [
                            [
                                .expression("std_logic", language: .vhdl),
                                .line("returnSignal"),
                                .line("Signal returnSignal.")
                            ]
                        ],
                        columns: [
                            ("type", .expression(language: .vhdl)),
                            ("name", .line),
                            ("comment", .line)
                        ]
                    )
                ],
                metaData: [:]
            ),
            AttributeGroup(
                name: "includes",
                fields: [
                    Field(name: "architecture_body", type: .code(language: .vhdl)),
                    Field(name: "architecture_head", type: .code(language: .vhdl)),
                    Field(name: "includes", type: .code(language: .vhdl))
                ],
                attributes: [
                    "includes": .code("library IEEE;\nuse IEEE.std_logic_1164.All;", language: .vhdl),
                    "architecture_head": .code("std_logic AA :='0';", language: .vhdl),
                    "architecture_body": .code("AA <= not x;", language: .vhdl)
                ],
                metaData: [:]
            ),
            AttributeGroup(
                name: "settings",
                fields: [
                    Field(
                        name: "initial_state", type: .enumerated(validValues: ["Initial", "Suspended"])
                    ),
                    Field(
                        name: "suspended_state", type: .enumerated(validValues: ["Initial", "Suspended", ""])
                    )
                ],
                attributes: [
                    "initial_state": .enumerated("Initial", validValues: ["Initial", "Suspended"]),
                    "suspended_state": .enumerated("Suspended", validValues: ["Initial", "Suspended", ""])
                ],
                metaData: [:]
            )
        ]
    }

    // swiftlint:disable function_body_length

    /// Test machine used as test data.
    static func testMachine(path: URL) -> Machine {
        let name = path.lastPathComponent.components(separatedBy: ".machine").first ?? path.lastPathComponent
        return Machine(
            name: name,
            path: path,
            includes: ["library IEEE;", "use IEEE.std_logic_1164.All;"],
            externalSignals: [
                ExternalSignal(
                    type: "std_logic", name: "x", mode: .input, defaultValue: "'1'", comment: "Signal x."
                ),
                ExternalSignal(
                    type: "std_logic", name: "y", mode: .output, defaultValue: "'0'", comment: "Signal y."
                )
            ],
            generics: [
                VHDLVariable(
                    type: "boolean", name: "hasX", defaultValue: "true", range: nil, comment: "Bool hasX."
                ),
                VHDLVariable(
                    type: "integer", name: "numX", defaultValue: "1", range: (0, 255), comment: "Int numX."
                )
            ],
            clocks: [
                Clock(name: "clk", frequency: 50, unit: .MHz), Clock(name: "clk1", frequency: 1, unit: .GHz)
            ],
            drivingClock: 0,
            dependentMachines: [
                "Machine2": URL(fileURLWithPath: "Machine2.machine", isDirectory: true),
                "Machine3": URL(fileURLWithPath: "Machine3.machine", isDirectory: true)
            ],
            machineVariables: [
                VHDLVariable(
                    type: "integer", name: "numA", defaultValue: "0", range: (0, 127), comment: "Int numA."
                ),
                VHDLVariable(
                    type: "integer", name: "numB", defaultValue: "10", range: (0, 127), comment: "Int numB."
                )
            ],
            machineSignals: [
                LocalSignal(type: "std_logic", name: "a", defaultValue: "'0'", comment: "Signal a."),
                LocalSignal(type: "std_logic", name: "b", defaultValue: "'1'", comment: "Signal b.")
            ],
            isParameterised: true,
            parameterSignals: [
                Parameter(
                    type: "unsigned", name: "timeout", defaultValue: "250", comment: "Unsigned timeout."
                ),
                Parameter(
                    type: "std_logic",
                    name: "defaultReturns",
                    defaultValue: "'1'",
                    comment: "Signal defaultReturns."
                )
            ],
            returnableSignals: [
                ReturnableVariable(type: "std_logic", name: "returnSignal", comment: "Signal returnSignal.")
            ],
            states: [
                State.testState(name: "Initial"),
                State.testState(name: "Suspended")
            ],
            transitions: [Transition(condition: "true", source: 0, target: 1)],
            initialState: 0,
            suspendedState: 1,
            architectureHead: "std_logic AA :='0';",
            architectureBody: "AA <= not x;"
        )
    }

    // swiftlint:enable function_body_length

}
