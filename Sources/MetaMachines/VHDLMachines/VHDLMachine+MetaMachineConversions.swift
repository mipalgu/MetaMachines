// VHDLMachine+MetaMachineConversion.swift 
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

/// Add conversion properties to create MetaMachine objects.
extension VHDLMachines.Machine {

    /// The attributes that match the current instance of this machine.
    var attributes: [AttributeGroup] {
        var attributes: [AttributeGroup] = []
        let variableFields: [Field] = [
            Field(name: "clocks", type: .table(columns: [
                ("name", .line),
                ("frequency", .integer),
                (
                    "unit",
                    .enumerated(
                        validValues: Set(VHDLMachines.Clock.FrequencyUnit.allCases.map { $0.rawValue })
                    )
                )
            ])),
            Field(name: "external_signals", type: .table(columns: [
                ("mode", .enumerated(validValues: Set(VHDLMachines.Mode.allCases.map { $0.rawValue }))),
                ("type", .expression(language: .vhdl)),
                ("name", .line),
                ("value", .expression(language: .vhdl)),
                ("comment", .line)
            ])),
            Field(name: "generics", type: .table(columns: [
                ("type", .expression(language: .vhdl)),
                ("lower_range", .line),
                ("upper_range", .line),
                ("name", .line),
                ("value", .expression(language: .vhdl)),
                ("comment", .line)
            ])),
            Field(name: "machine_signals", type: .table(columns: [
                ("type", .expression(language: .vhdl)),
                ("name", .line),
                ("value", .expression(language: .vhdl)),
                ("comment", .line)
            ])),
            Field(name: "machine_variables", type: .table(columns: [
                ("type", .expression(language: .vhdl)),
                ("lower_range", .line),
                ("upper_range", .line),
                ("name", .line),
                ("value", .expression(language: .vhdl)),
                ("comment", .line)
            ])),
            Field(name: "driving_clock", type: .enumerated(validValues: Set(self.clocks.map { $0.name })))
        ]
        let variableAttributes: [String: Attribute] = [
            "clocks": .table(
                self.clocks.map(\.toLineAttribute),
                columns: [
                    ("name", .line),
                    ("frequency", .integer),
                    (
                        "unit",
                        .enumerated(
                            validValues: Set(VHDLMachines.Clock.FrequencyUnit.allCases.map { $0.rawValue })
                        )
                    )
                ]
            ),
            "external_signals": .table(
                self.externalSignals.map(\.toLineAttribute),
                columns: [
                    ("mode", .enumerated(validValues: Set(VHDLMachines.Mode.allCases.map { $0.rawValue }))),
                    ("type", .expression(language: .vhdl)),
                    ("name", .line),
                    ("value", .expression(language: .vhdl)),
                    ("comment", .line)
                ]
            ),
            "generics": .table(
                self.generics.map(\.toLineAttribute),
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
                self.machineSignals.map(\.toLineAttribute),
                columns: [
                    ("type", .expression(language: .vhdl)),
                    ("name", .line),
                    ("value", .expression(language: .vhdl)),
                    ("comment", .line)
                ]
            ),
            "machine_variables": .table(
                self.machineVariables.map(\.toLineAttribute),
                columns: [
                    ("type", .expression(language: .vhdl)),
                    ("lower_range", .line),
                    ("upper_range", .line),
                    ("name", .line),
                    ("value", .expression(language: .vhdl)),
                    ("comment", .line)
                ]
            ),
            "driving_clock": .enumerated(
                self.clocks[self.drivingClock].name, validValues: Set(self.clocks.map { $0.name })
            )
        ]
        let variables = AttributeGroup(
            name: "variables",
            fields: variableFields,
            attributes: variableAttributes,
            metaData: [:]
        )
        attributes.append(variables)
        let parameters = AttributeGroup(
            name: "parameters",
            fields: [
                Field(name: "is_parameterised", type: .bool),
                Field(name: "parameter_signals", type: .table(columns: [
                    ("type", .expression(language: .vhdl)),
                    ("name", .line),
                    ("value", .expression(language: .vhdl)),
                    ("comment", .line)
                ])),
                Field(name: "returnable_signals", type: .table(columns: [
                    ("type", .expression(language: .vhdl)),
                    ("name", .line),
                    ("comment", .line)
                ]))
            ],
            attributes: [
                "is_parameterised": .bool(self.isParameterised),
                "parameter_signals": .table(
                    !self.isParameterised ? [] : self.parameterSignals.map(\.toLineAttribute),
                    columns: [
                        ("type", .expression(language: .vhdl)),
                        ("name", .line),
                        ("value", .expression(language: .vhdl)),
                        ("comment", .line)
                    ]
                ),
                "returnable_signals": .table(
                    !self.isParameterised ? [] : self.returnableSignals.map(\.toLineAttribute),
                    columns: [
                        ("type", .expression(language: .vhdl)),
                        ("name", .line),
                        ("comment", .line)
                    ]
                )
            ],
            metaData: [:]
        )
        attributes.append(parameters)
        let includes = AttributeGroup(
            name: "includes",
            fields: [
                Field(name: "includes", type: .code(language: .vhdl)),
                Field(name: "architecture_head", type: .code(language: .vhdl)),
                Field(name: "architecture_body", type: .code(language: .vhdl))
            ],
            attributes: [
                "includes": .code(self.includes.joined(separator: "\n"), language: .vhdl),
                "architecture_head": .code(self.architectureHead ?? "", language: .vhdl),
                "architecture_body": .code(self.architectureBody ?? "", language: .vhdl)
            ],
            metaData: [:]
        )
        attributes.append(includes)
        let settings = AttributeGroup(
            name: "settings",
            fields: [
                Field(
                    name: "initial_state", type: .enumerated(validValues: Set(self.states.map(\.name)))
                ),
                Field(
                    name: "suspended_state",
                    type: .enumerated(validValues: Set([""] + self.states.map(\.name)))
                )
            ],
            attributes: [
                "initial_state": .enumerated(
                    self.states[self.initialState].name, validValues: Set(self.states.map(\.name))
                ),
                "suspended_state": .enumerated(
                    self.suspendedState.map { self.states[$0].name } ?? "",
                    validValues: Set([""] + self.states.map(\.name))
                )
            ],
            metaData: [:]
        )
        attributes.append(settings)
        return attributes
    }

    /// Create a `VHDLMachines.Machine` for the given `MetaMachine`.
    /// - Parameter machine: The meta machine to convert.
    public init(machine: MetaMachine) {
        // let validator = VHDLMachinesValidator()
        // try validator.validate(machine: machine)
        let vhdlStates = machine.states.map(VHDLMachines.State.init)
        let suspendedState = machine.attributes.first { $0.name == "settings" }?
            .attributes["suspended_state"]?
            .enumeratedValue
        let suspendedStateName = (suspendedState?.isEmpty ?? true) ? nil : suspendedState
        let suspendedIndex = suspendedStateName == nil ? nil : vhdlStates.firstIndex {
            // swiftlint:disable:next force_unwrapping
            $0.name == suspendedStateName!
        }
        self.init(
            name: machine.name,
            path: URL(fileURLWithPath: "\(machine.name).machine", isDirectory: true),
            includes: machine.vhdlIncludes,
            externalSignals: machine.vhdlExternalSignals,
            generics: machine.vhdlGenerics,
            clocks: machine.vhdlClocks,
            drivingClock: machine.vhdlDrivingClock,
            dependentMachines: machine.vhdlDependentMachines,
            machineVariables: machine.vhdlMachineVariables,
            machineSignals: machine.vhdlMachineSignals,
            isParameterised: machine.vhdlIsParameterised,
            parameterSignals: machine.vhdlParameterSignals,
            returnableSignals: machine.vhdlReturnableSignals,
            states: machine.states.map(VHDLMachines.State.init),
            transitions: machine.vhdlTransitions,
            initialState: (machine.states.firstIndex { machine.initialState == $0.name }) ?? 0,
            suspendedState: suspendedIndex,
            architectureHead: machine.vhdlArchitectureHead,
            architectureBody: machine.vhdlArchitectureBody
        )
    }

}
