// VHDLState+MetaMachineStateConversion.swift 
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
import VHDLMachines

/// Add conversions to MetaMachine types.
extension VHDLMachines.State {

    /// Create a new `VHDLMachines.State` from a ``MetaMachine.State``.
    /// - Parameter state: The ``MetaMachine.State`` to convert.
    public init(state: State) {
        let order = state.vhdlActionOrder
        let signals = state.vhdlStateSignals
        let variables = state.vhdlStateVariables
        let externals = state.vhdlExternalVariables
        self.init(
            name: state.name,
            actions: Dictionary(uniqueKeysWithValues: state.actions.map { ($0.name, $0.implementation) }),
            actionOrder: order,
            signals: signals,
            variables: variables,
            externalVariables: externals
        )
    }

    // swiftlint:disable function_body_length

    /// Create the default for a new state.
    /// - Parameter machine: The machine to create the new state in.
    /// - Returns: The attributes for the new state.
    static func defaultAttributes(in machine: MetaMachine) -> [AttributeGroup] {
        let schema = machine.vhdlSchema
        let validValues = schema?.stateSchema.variables.externalValidValues ?? []
        let variables = AttributeGroup(
            name: "variables",
            fields: [
                Field(name: "externals", type: .enumerableCollection(
                        validValues: validValues
                )),
                Field(name: "state_signals", type: .table(columns: [
                    ("type", .expression(language: .vhdl)),
                    ("name", .line),
                    ("value", .expression(language: .vhdl)),
                    ("comment", .line)
                ]))
            ],
            attributes: [
                "externals": .enumerableCollection([], validValues: validValues),
                "state_signals": .table(
                    [],
                    columns: [
                        ("type", .expression(language: .vhdl)),
                        ("name", .line),
                        ("value", .expression(language: .vhdl)),
                        ("comment", .line)
                    ]
                )
            ],
            metaData: [:]
        )
        return [variables]
    }

    // swiftlint:enable function_body_length

    /// The attributes of this state. These attributes can be used to specify additional properties for a
    /// state in a ``MetaMachine``.
    /// - Parameter machine: The machine this state belongs too.
    /// - Returns: The attributes of this state.
    func attributes(for machine: VHDLMachines.Machine) -> [AttributeGroup] {
        [variablesGroup(externals: machine.externalSignals.map { $0.name.rawValue })]
    }

    /// Create a new `Attributes.AttributeGroup` for the variables of this state.
    /// - Parameter externals: The external signals available to this state.
    /// - Returns: The variable AttributeGroup.
    private func variablesGroup(externals: [String]) -> AttributeGroup {
        AttributeGroup(
            name: "variables",
            fields: [
                Field(name: "externals", type: .enumerableCollection(
                        validValues: Set(externals)
                )),
                Field(name: "state_signals", type: .table(columns: [
                    ("type", .expression(language: .vhdl)),
                    ("name", .line),
                    ("value", .expression(language: .vhdl)),
                    ("comment", .line)
                ]))
            ],
            attributes: [
                "externals": .enumerableCollection(Set(self.externalVariables), validValues: Set(externals)),
                "state_signals": .table(
                    self.signals.map(\.toLineAttribute),
                    columns: [
                        ("type", .expression(language: .vhdl)),
                        ("name", .line),
                        ("value", .expression(language: .vhdl)),
                        ("comment", .line)
                    ]
                )
            ],
            metaData: [:]
        )
    }

}
