// MetaMachineExtensions.swift 
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

    public init(vhdl machine: VHDLMachines.Machine) {
        self = VHDLMachinesConverter().toMachine(machine: machine)
    }

    public static func initialVHDLMachine(filePath: URL) -> MetaMachine {
        VHDLMachinesConverter().toMachine(machine: VHDLMachines.Machine.initial(path: filePath))
    }

}

extension State {

    public init(vhdl state: VHDLMachines.State, in machine: VHDLMachines.Machine) {
        let actions = state.actionOrder.reduce([]){ $0 + $1 }.map {
            Action(name: $0, implementation: state.actions[$0] ?? "", language: .vhdl)
        }
        guard let stateIndex = machine.states.firstIndex(where: { $0.name == state.name }) else {
            fatalError("Cannot find state with name: \(state.name).")
        }
        self.init(
            name: state.name,
            actions: actions,
            transitions: machine.transitions.filter({ $0.source == stateIndex }).map({ Transition(vhdl: $0, in: machine) }),
            attributes: state.attributes(for: machine),
            metaData: []
        )
    }

}

extension Transition {

    public init(vhdl transition: VHDLMachines.Transition, in machine: VHDLMachines.Machine) {
        self.init(
            condition: transition.condition,
            target: machine.states[transition.target].name,
            attributes: [],
            metaData: []
        )
    }

}

extension VHDLMachines.Machine {

    public init(machine: MetaMachine) throws {
        self = try VHDLMachinesConverter().convert(machine: machine)
    }

}

extension Arrangement {

    public init(vhdl arrangement: VHDLMachines.Arrangement) {
        self.init(
            semantics: .swiftfsm,
            name: arrangement.path.lastPathComponent.components(separatedBy: ".")[0],
            dependencies: arrangement.parents.compactMap {
                guard let path = arrangement.machines[$0] else {
                    return nil
                }
                return MachineDependency(relativePath: path.relativePathString(relativeto: arrangement.path))
            },
            attributes: [],
            metaData: []
        )
    }

}
