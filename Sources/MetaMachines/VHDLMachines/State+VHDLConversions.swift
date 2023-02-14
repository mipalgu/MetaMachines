// State+VHDLAccessors.swift 
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

/// Adds computed properties and initialisers for conversions between `VHDLMachines.State` and the ``State``
/// type.
extension State {

    /// Retrieve the VHDL external variables in the states attributes.
    var vhdlExternalVariables: [String] {
        guard
            let rows = self.attributes.first(where: { $0.name == "variables" })?.attributes["externals"]?
                .enumerableCollectionValue
        else {
            return []
        }
        return Array(rows).sorted()
    }

    /// Retrieve the VHDL state signals from the states attributes.
    var vhdlStateSignals: [LocalSignal] {
        guard
            let rows = self.attributes.first(where: { $0.name == "variables" })?.attributes["state_signals"]?
                .tableValue
        else {
            return []
        }
        return rows.map {
            LocalSignal(
                type: $0[0].expressionValue.trimmingCharacters(in: .whitespaces),
                name: $0[1].lineValue.trimmingCharacters(in: .whitespaces),
                defaultValue: $0[2].expressionValue.trimmingCharacters(in: .whitespaces).isEmpty ? nil :
                    $0[2].expressionValue.trimmingCharacters(in: .whitespaces),
                comment: $0[3].lineValue.trimmingCharacters(in: .whitespaces).isEmpty ? nil :
                    $0[3].lineValue.trimmingCharacters(in: .whitespaces)
            )
        }
    }

    /// Retrieve the VHDL state variables from the states attributes.
    var vhdlStateVariables: [VHDLMachines.VHDLVariable] {
        guard
            let rows = self.attributes.first(where: { $0.name == "variables" })?
                .attributes["state_variables"]?.tableValue
        else {
            return []
        }
        return rows.map {
            guard
                let lowerRange = Int($0[1].lineValue.trimmingCharacters(in: .whitespaces)),
                let upperRange = Int($0[2].lineValue.trimmingCharacters(in: .whitespaces))
            else {
                return VHDLMachines.VHDLVariable(
                    type: $0[0].expressionValue.trimmingCharacters(in: .whitespaces),
                    name: $0[3].lineValue.trimmingCharacters(in: .whitespaces),
                    defaultValue: $0[4].expressionValue.trimmingCharacters(in: .whitespaces) == "" ? nil :
                        $0[4].expressionValue.trimmingCharacters(in: .whitespaces),
                    range: nil,
                    comment: $0[5].lineValue.trimmingCharacters(in: .whitespaces) == "" ? nil :
                        $0[5].lineValue.trimmingCharacters(in: .whitespaces)
                )
            }
            return VHDLMachines.VHDLVariable(
                type: $0[0].expressionValue.trimmingCharacters(in: .whitespaces),
                name: $0[3].lineValue.trimmingCharacters(in: .whitespaces),
                defaultValue: $0[4].expressionValue.trimmingCharacters(in: .whitespaces).isEmpty ? nil :
                    $0[4].expressionValue.trimmingCharacters(in: .whitespaces),
                range: (lowerRange, upperRange),
                comment: $0[5].lineValue.trimmingCharacters(in: .whitespaces).isEmpty ? nil :
                    $0[5].lineValue.trimmingCharacters(in: .whitespaces)
            )
        }
    }

    /// Retrieve the VHDL action order from the states attributes.
    var vhdlActionOrder: [[VHDLMachines.ActionName]] {
        guard
            let order = self.attributes.first(where: { $0.name == "actions" })?.attributes["action_order"]
        else {
            fatalError("Failed to retrieve action attributes.")
        }
        if order.tableValue.isEmpty {
            return [[]]
        }
        let maxIndex = order.tableValue.reduce(0) {
            max($0, $1[0].integerValue)
        }
        var actionOrder: [[VHDLMachines.ActionName]] = Array(repeating: [], count: maxIndex + 1)
        actionOrder.indices.forEach { timeslot in
            actionOrder[timeslot] = order.tableValue.compactMap { row in
                if row[0].integerValue == timeslot {
                    return row[1].enumeratedValue.trimmingCharacters(in: .whitespaces)
                }
                return nil
            }
        }
        return actionOrder
    }

    /// Create a new ``State`` from a `VHDLMachines.State`.
    /// - Parameters:
    ///   - state: The `VHDLMachines.State` to convert.
    ///   - machine: The `VHDLMachines.Machine` the state belongs to.
    public init(vhdl state: VHDLMachines.State, in machine: VHDLMachines.Machine) {
        let actions = state.actionOrder.joined().map {
            Action(name: $0, implementation: state.actions[$0] ?? "", language: .vhdl)
        }
        guard let stateIndex = machine.states.firstIndex(where: { $0.name == state.name }) else {
            fatalError("Cannot find state with name: \(state.name).")
        }
        self.init(
            name: state.name,
            actions: actions,
            transitions: machine.transitions.filter { $0.source == stateIndex }
                .map { Transition(vhdl: $0, in: machine) },
            attributes: state.attributes(for: machine),
            metaData: []
        )
    }

}
