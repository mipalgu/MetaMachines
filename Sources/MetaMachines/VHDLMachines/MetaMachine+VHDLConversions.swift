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

extension MetaMachine {

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

    var vhdlDrivingClock: Int {
        guard
            self.attributes.count == 4,
            let clock = self.attributes[0].attributes["driving_clock"]?.enumeratedValue,
            let index = self.attributes[0].attributes["clocks"]?.tableValue.firstIndex(where: { $0[0].lineValue == clock })
        else {
            fatalError("Cannot retrieve driving clock")
        }
        return index
    }

    var vhdlExternalVariables: [ExternalVariable] {
        guard
            self.attributes.count == 4,
            let variables = self.attributes[0].attributes["external_variables"]?.tableValue
        else {
            fatalError("Cannot retrieve external variables")
        }
        return variables.map {
            ExternalVariable(
                type: $0[1].expressionValue,
                name: $0[2].lineValue,
                mode: Mode(rawValue: $0[0].enumeratedValue)!,
                range: nil,
                defaultValue: $0[3].expressionValue == "" ? nil : $0[2].expressionValue,
                comment: $0[4].lineValue == "" ? nil : $0[3].lineValue
            )
        }
    }

    var vhdlExternalSignals: [ExternalSignal] {
        guard
            self.attributes.count == 4,
            let signals = self.attributes[0].attributes["external_signals"]?.tableValue
        else {
            fatalError("Cannot retrieve external signals")
        }
        return signals.map {
            let value = $0[3].expressionValue == "" ? nil : $0[3].expressionValue
            let comment = $0[4].lineValue == "" ? nil : $0[4].lineValue
            guard let mode = Mode(rawValue: $0[0].enumeratedValue) else {
                fatalError("Cannot convert Mode!")
            }
            return ExternalSignal(type: $0[1].expressionValue, name: $0[2].lineValue, mode: mode, defaultValue: value, comment: comment)
        }
    }

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

    var vhdlIsParameterised: Bool {
        guard let isParameterised = self.attributes[1].attributes["is_parameterised"]?.boolValue else {
            fatalError("Cannot discern if machine is parameterised")
        }
        return isParameterised
    }

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
                defaultValue: $0[2].expressionValue == "" ? nil : $0[2].expressionValue,
                comment: $0[3].lineValue == "" ? nil : $0[3].lineValue
            )
        }
    }

    var vhdlMachineVariables: [VHDLVariable] {
        guard
            self.attributes.count == 4,
            let variables = self.attributes[0].attributes["machine_variables"]?.tableValue
        else {
            fatalError("Cannot retrieve machine variables")
        }
        return variables.map {
            VHDLVariable(
                type: $0[0].expressionValue,
                name: $0[1].lineValue,
                defaultValue: $0[2].expressionValue == "" ? nil : $0[2].expressionValue,
                range: nil,
                comment: $0[3].lineValue == "" ? nil : $0[3].lineValue
            )
        }
    }

    var vhdlTransitions: [VHDLMachines.Transition] {
        self.states.indices.flatMap { stateIndex in
            self.states[stateIndex].transitions.map { transition in
                guard let targetIndex = self.states.firstIndex(where: { transition.target == $0.name }) else {
                    fatalError("Cannot find target state \(transition.target) for transition \(transition) from state \(self.states[stateIndex].name)")
                }
                return VHDLMachines.Transition(condition: transition.condition ?? "true", source: stateIndex, target: targetIndex)
            }
        }
    }

    public init(vhdl machine: VHDLMachines.Machine) {
        self = VHDLMachinesConverter().toMachine(machine: machine)
    }

    public static func initialVHDLMachine(filePath: URL) -> MetaMachine {
        VHDLMachinesConverter().toMachine(machine: VHDLMachines.Machine.initial(path: filePath))
    }

    func vhdlParameterOutputs(for key: String) -> [ReturnableVariable] {
        guard
            self.attributes.count == 4,
            let returns = self.attributes[1].attributes[key]?.tableValue
        else {
            fatalError("No outputs")
        }
        return returns.map {
            let comment = $0[2].lineValue
            return ReturnableVariable(type: $0[0].expressionValue, name: $0[1].lineValue, comment: comment == "" ? nil : comment)
        }
    }

    func vhdlParameters(for key: String) -> [Parameter] {
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
                defaultValue: $0[2].expressionValue == "" ? nil : $0[2].expressionValue,
                comment: $0[3].lineValue == "" ? nil : $0[3].lineValue
            )
        }
    }

    func vhdlVariables(for key: String) -> [VHDLVariable] {
        guard
            self.attributes.count == 4,
            let variables = self.attributes[0].attributes[key]?.tableValue
        else {
            fatalError("Cannot retrieve external variables")
        }
        return variables.map {
            VHDLVariable(
                type: $0[0].expressionValue,
                name: $0[1].lineValue,
                defaultValue: $0[2].expressionValue == "" ? nil : $0[2].expressionValue,
                range: nil,
                comment: $0[3].lineValue == "" ? nil : $0[3].lineValue
            )
        }
    }

}
