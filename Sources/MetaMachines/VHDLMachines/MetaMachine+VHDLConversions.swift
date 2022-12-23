// MetaMachine+VHDLConversions.swift 
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

import Foundation
import VHDLMachines

/// Adds properties and initialisers for accessing and creating `VHDLMachines` objects.
extension MetaMachine {

    /// Fetch the VHDL architecture body from this machines attributes.
    var vhdlArchitectureBody: String? {
        self.vhdlCodeIncludes(for: "architecture_body")
    }

    /// Fetch the VHDL architecture head from this machines attributes.
    var vhdlArchitectureHead: String? {
        self.vhdlCodeIncludes(for: "architecture_head")
    }

    /// Fetch the VHDL clocks from this machines attributes.
    var vhdlClocks: [Clock] {
        guard
            self.attributes.count == 4,
            let clocks = self.attributes[0].attributes["clocks"]?.tableValue
        else {
            fatalError("Cannot retrieve clocks")
        }
        return clocks.map {
            guard let unit = Clock.FrequencyUnit(rawValue: $0[2].enumeratedValue) else {
                fatalError("Clock unit is invalid: \($0[2])")
            }
            return Clock(name: $0[0].lineValue, frequency: UInt(clamping: $0[1].integerValue), unit: unit)
        }
    }

    /// Convert this machines dependencies to the `VHDLMachines` equivalent objects.
    var vhdlDependentMachines: [VHDLMachines.MachineName: URL] {
        Dictionary(uniqueKeysWithValues: self.dependencies.map {
            (
                $0.name,
                URL(fileURLWithPath: $0.relativePath, isDirectory: true)
            )
        })
    }

    /// Fetch the VHDL driving clock from this machines attributes.
    var vhdlDrivingClock: Int {
        guard
            self.attributes.count == 4,
            let clock = self.attributes[0].attributes["driving_clock"]?.enumeratedValue,
            let index = self.attributes[0].attributes["clocks"]?.tableValue.firstIndex(where: {
                $0[0].lineValue == clock
            })
        else {
            fatalError("Cannot retrieve driving clock")
        }
        return index
    }

    /// Fetch the VHDL external signals from this machines attributes.
    var vhdlExternalSignals: [ExternalSignal] {
        guard
            self.attributes.count == 4,
            let signals = self.attributes[0].attributes["external_signals"]?.tableValue
        else {
            fatalError("Cannot retrieve external signals")
        }
        return signals.map {
            let value = $0[3].expressionValue.isEmpty ? nil : $0[3].expressionValue
            let comment = $0[4].lineValue.isEmpty ? nil : $0[4].lineValue
            guard let mode = Mode(rawValue: $0[0].enumeratedValue) else {
                fatalError("Cannot convert Mode!")
            }
            return ExternalSignal(
                type: $0[1].expressionValue,
                name: $0[2].lineValue,
                mode: mode,
                defaultValue: value,
                comment: comment
            )
        }
    }

    /// Fetch the VHDL generics from this machines attributes.
    var vhdlGenerics: [VHDLVariable] {
        self.vhdlVariables(for: "generics")
    }

    /// Fetch the VHDL includes from this machines attributes.
    var vhdlIncludes: [String] {
        guard
            self.attributes.count == 4,
            let includes = self.attributes[2].attributes["includes"]?.codeValue
        else {
            fatalError("Cannot retrieve includes")
        }
        return includes.split(separator: ";").map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines) + ";"
        }
    }

    /// Fetch the VHDL isParameterised property from this machines attributes.
    var vhdlIsParameterised: Bool {
        guard let isParameterised = self.attributes[1].attributes["is_parameterised"]?.boolValue else {
            fatalError("Cannot discern if machine is parameterised")
        }
        return isParameterised
    }

    /// Fetch the VHDL machine signals from this machines attributes.
    var vhdlMachineSignals: [MachineSignal] {
        guard
            self.attributes.count == 4,
            let signals = self.attributes[0].attributes["machine_signals"]?.tableValue
        else {
            fatalError("Cannot retrieve machine signals")
        }
        return signals.map {
            MachineSignal(
                type: $0[0].expressionValue,
                name: $0[1].lineValue,
                defaultValue: $0[2].expressionValue.isEmpty ? nil : $0[2].expressionValue,
                comment: $0[3].lineValue.isEmpty ? nil : $0[3].lineValue
            )
        }
    }

    /// Fetch the VHDL machine variables from this machines attributes.
    var vhdlMachineVariables: [VHDLVariable] {
        guard
            self.attributes.count == 4,
            let variables = self.attributes[0].attributes["machine_variables"]?.tableValue
        else {
            fatalError("Cannot retrieve machine variables")
        }
        return variables.map {
            guard let range0 = Int($0[1].lineValue), let range1 = Int($0[2].lineValue) else {
                return VHDLVariable(
                    type: $0[0].expressionValue,
                    name: $0[3].lineValue,
                    defaultValue: $0[4].expressionValue.isEmpty ? nil : $0[4].expressionValue,
                    range: nil,
                    comment: $0[5].lineValue.isEmpty ? nil : $0[5].lineValue
                )
            }
            return VHDLVariable(
                type: $0[0].expressionValue,
                name: $0[3].lineValue,
                defaultValue: $0[4].expressionValue.isEmpty ? nil : $0[4].expressionValue,
                range: (range0, range1),
                comment: $0[5].lineValue.isEmpty ? nil : $0[5].lineValue
            )
        }
    }

    /// Fetch the VHDL parameter signals from this machines attributes.
    var vhdlParameterSignals: [Parameter] {
        self.vhdlParameters(for: "parameter_signals")
    }

    /// Fetch the VHDL returnable signals from this machines attributes.
    var vhdlReturnableSignals: [ReturnableVariable] {
        self.vhdlParameterOutputs(for: "returnable_signals")
    }

    /// Convert the transitions of this machine into the `VHDLMachines.Transition` format.
    var vhdlTransitions: [VHDLMachines.Transition] {
        self.states.indices.flatMap { stateIndex in
            self.states[stateIndex].transitions.map { transition in
                guard let targetIndex = self.states.firstIndex(where: { transition.target == $0.name }) else {
                    fatalError("Cannot find target state \(transition.target) for transition \(transition)" +
                        " from state \(self.states[stateIndex].name)")
                }
                return VHDLMachines.Transition(
                    condition: transition.condition ?? "true", source: stateIndex, target: targetIndex
                )
            }
        }
    }

    /// Initialise a `MetaMachine` from a `VHDLMachines.Machine`.
    /// - Parameter machine: The `VHDLMachines.Machine` to convert to a `MetaMachine`.
    public init(vhdl machine: VHDLMachines.Machine) {
        self.init(
            semantics: .vhdl,
            name: machine.name,
            initialState: machine.states[machine.initialState].name,
            states: machine.states.map { State(vhdl: $0, in: machine) },
            dependencies: machine.dependentMachines.values.map {
                MachineDependency(relativePath: $0.relativePath)
            },
            attributes: machine.attributes,
            metaData: []
        )
    }

    /// Create an initial MetaMachine that uses the VHDL semantics.
    /// - Parameter filePath: The file path to the new machine.
    /// - Returns: An initial `MetaMachine` that uses the VHDL semantics.
    public static func initialVHDLMachine(filePath: URL) -> MetaMachine {
        MetaMachine(vhdl: VHDLMachines.Machine.initial(path: filePath))
    }

    /// Fetch the code values from the includes attribute group.
    /// - Parameter key: The key of the attribute to fetch within the group.
    /// - Returns: The code value.
    private func vhdlCodeIncludes(for key: String) -> String? {
        guard
            let val = self.attributes.first(where: { $0.name == "includes" })?.attributes[key]?.codeValue
        else {
            return nil
        }
        return val.isEmpty ? nil : val
    }

    /// Fetch the parameter outputs from the attribute group.
    /// - Parameter key: The name of the key in the parameters attribute to fetch.
    /// - Returns: The ReturnableVariable values at the key.
    private func vhdlParameterOutputs(for key: String) -> [ReturnableVariable] {
        guard
            self.attributes.count == 4,
            let returns = self.attributes[1].attributes[key]?.tableValue
        else {
            fatalError("No outputs")
        }
        return returns.map {
            let comment = $0[2].lineValue
            return ReturnableVariable(
                type: $0[0].expressionValue, name: $0[1].lineValue, comment: comment.isEmpty ? nil : comment
            )
        }
    }

    /// Fetch VHDL parameters from the attribute group.
    /// - Parameter key: The key of the attribute to fetch.
    /// - Returns: The parameters located at the key.
    private func vhdlParameters(for key: String) -> [Parameter] {
        guard
            self.attributes.count == 4,
            let variables = self.attributes[1].attributes[key]?.tableValue
        else {
            fatalError("Cannot retrieve external variables")
        }
        return variables.map {
            Parameter(
                type: $0[0].expressionValue,
                name: $0[1].lineValue,
                defaultValue: $0[2].expressionValue.isEmpty ? nil : $0[2].expressionValue,
                comment: $0[3].lineValue.isEmpty ? nil : $0[3].lineValue
            )
        }
    }

    /// Fetch the VHDL Variables within the variables attribute group.
    /// - Parameter key: The key of the attribute to fetch.
    /// - Returns: The variables located at the key.
    private func vhdlVariables(for key: String) -> [VHDLVariable] {
        guard
            self.attributes.count == 4,
            let variables = self.attributes[0].attributes[key]?.tableValue
        else {
            fatalError("Cannot retrieve external variables")
        }
        return variables.map {
            guard let range0 = Int($0[1].lineValue), let range1 = Int($0[2].lineValue) else {
                return VHDLVariable(
                    type: $0[0].expressionValue,
                    name: $0[3].lineValue,
                    defaultValue: $0[4].expressionValue.isEmpty ? nil : $0[4].expressionValue,
                    range: nil,
                    comment: $0[5].lineValue.isEmpty ? nil : $0[5].lineValue
                )
            }
            return VHDLVariable(
                type: $0[0].expressionValue,
                name: $0[3].lineValue,
                defaultValue: $0[4].expressionValue.isEmpty ? nil : $0[4].expressionValue,
                range: (range0, range1),
                comment: $0[5].lineValue.isEmpty ? nil : $0[5].lineValue
            )
        }
    }

}
