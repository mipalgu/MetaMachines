// MockMetaMachineMutator.swift
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
import MetaMachines

/// Mock struct for testing.
class MockMetaMachineMutator: MachineMutatorResponder, MachineAttributesMutator, MachineModifier {

    /// Sum type for which function is called and what parameters it received.
    enum FunctionCalled {

        // swiftlint:disable large_tuple

        /// The dependencyLayout property was called.
        case dependencyLayout

        /// Function called with parameters.
        case didCreateDependency(
            parameters: (
                machine: MetaMachines.MetaMachine, dependency: MetaMachines.MachineDependency, index: Int
            )
        )

        /// Function called with parameters.
        case didCreateNewState(
            parameters: (machine: MetaMachines.MetaMachine, state: MetaMachines.State, index: Int)
        )

        /// Function called with parameters.
        case didChangeStatesName(
            parameters: (
                machine: MetaMachines.MetaMachine, state: MetaMachines.State, index: Int, oldName: String
            )
        )

        /// Function called with parameters.
        case didCreateNewTransition(
            parameters: (
                    machine: MetaMachines.MetaMachine,
                    transition: MetaMachines.Transition,
                    stateIndex: Int,
                    transitionIndex: Int
                )
        )

        /// Function called with parameters.
        case didDeleteDependency(
            parameters: (
                machine: MetaMachines.MetaMachine, dependency: MetaMachines.MachineDependency, at: Int
            )
        )

        /// Function called with parameters.
        case didDeleteState(
            parameters: (machine: MetaMachines.MetaMachine, state: MetaMachines.State, at: Int)
        )

        /// Function called with parameters.
        case didDeleteTransition(parameters: (machine: MetaMachine, transition: Transition, at: Int, in: Int))

        /// Function called with parameters.
        case didDeleteDependencies(
            parameters: (
                machine: MetaMachines.MetaMachine,
                dependencies: [MetaMachines.MachineDependency],
                at: IndexSet
            )
        )

        /// Function called with parameters.
        case didDeleteStates(
            parameters: (machine: MetaMachines.MetaMachine, states: [MetaMachines.State], at: IndexSet)
        )

        /// Function called with parameters.
        case didDeleteTransitions(
            parameters: (
                machine: MetaMachines.MetaMachine,
                transitions: [MetaMachines.Transition],
                at: IndexSet,
                in: Int
            )
        )

        /// Function called with parameters.
        case update(metaMachine: MetaMachines.MetaMachine)

        /// Function called with parameters.
        case didAddItem(parameters: (item: Any, attribute: Any, machine: MetaMachines.MetaMachine))

        /// Function called with parameters.
        case didMoveItems(
            parameters: (
                attribute: Any, machine: MetaMachine, source: IndexSet, destination: Int, items: [Any]
            )
        )

        /// Function called with parameters.
        case didDeleteItems(
            parameters: (attribute: Any, indices: IndexSet, machine: MetaMachine, items: [Any])
        )

        /// Function called with parameters.
        case didDeleteItem(parameters: (attribute: Any, atIndex: Int, machine: MetaMachine, item: Any))

        /// Function called with parameters.
        case didModify(parameters: (attribute: Any, oldValue: Any, newValue: Any, machine: MetaMachine))

        /// Function called with parameters.
        case validate(metaMachine: MetaMachines.MetaMachine)

        // swiftlint:enable large_tuple

    }

    /// An array of all functions called.
    private(set) var functionsCalled: [FunctionCalled] = []

    /// The dependency layout.
    var dependencyLayout: [Attributes.Field] {
        self.functionsCalled.append(.dependencyLayout)
        return []
    }

    /// What value to return from the functions.
    private let returns: Result<Bool, Attributes.AttributeError<MetaMachines.MetaMachine>>

    /// Initialises the mock.
    init(returns: Result<Bool, Attributes.AttributeError<MetaMachines.MetaMachine>> = .success(true)) {
        self.returns = returns
    }

    /// Mock function.
    func didCreateDependency(
        machine: inout MetaMachines.MetaMachine, dependency: MetaMachines.MachineDependency, index: Int
    ) -> Result<Bool, Attributes.AttributeError<MetaMachines.MetaMachine>> {
        self.functionsCalled.append(.didCreateDependency(parameters: (machine, dependency, index)))
        return returns
    }

    /// Mock function.
    func didCreateNewState(
        machine: inout MetaMachines.MetaMachine, state: MetaMachines.State, index: Int
    ) -> Result<Bool, Attributes.AttributeError<MetaMachines.MetaMachine>> {
        self.functionsCalled.append(.didCreateNewState(parameters: (machine, state, index)))
        return returns
    }

    /// Mock function.
    func didChangeStatesName(
        machine: inout MetaMachines.MetaMachine, state: MetaMachines.State, index: Int, oldName: String
    ) -> Result<Bool, Attributes.AttributeError<MetaMachines.MetaMachine>> {
        self.functionsCalled.append(.didChangeStatesName(parameters: (machine, state, index, oldName)))
        return returns
    }

    /// Mock function.
    func didCreateNewTransition(
        machine: inout MetaMachines.MetaMachine,
        transition: MetaMachines.Transition,
        stateIndex: Int,
        transitionIndex: Int
    ) -> Result<Bool, Attributes.AttributeError<MetaMachines.MetaMachine>> {
        self.functionsCalled.append(
            .didCreateNewTransition(parameters: (machine, transition, stateIndex, transitionIndex))
        )
        return returns
    }

    /// Mock function.
    func didDeleteDependency(
        machine: inout MetaMachines.MetaMachine, dependency: MetaMachines.MachineDependency, at: Int
    ) -> Result<Bool, Attributes.AttributeError<MetaMachines.MetaMachine>> {
        self.functionsCalled.append(.didDeleteDependency(parameters: (machine, dependency, at)))
        return returns
    }

    /// Mock function.
    func didDeleteState(
        machine: inout MetaMachines.MetaMachine, state: MetaMachines.State, at: Int
    ) -> Result<Bool, Attributes.AttributeError<MetaMachines.MetaMachine>> {
        self.functionsCalled.append(.didDeleteState(parameters: (machine, state, at)))
        return returns
    }

    /// Mock function.
    func didDeleteTransition(
        machine: inout MetaMachines.MetaMachine, transition: MetaMachines.Transition, stateIndex: Int, at: Int
    ) -> Result<Bool, Attributes.AttributeError<MetaMachines.MetaMachine>> {
        self.functionsCalled.append(.didDeleteTransition(parameters: (machine, transition, stateIndex, at)))
        return returns
    }

    /// Mock function.
    func didDeleteDependencies(
        machine: inout MetaMachines.MetaMachine, dependency: [MetaMachines.MachineDependency], at: IndexSet
    ) -> Result<Bool, Attributes.AttributeError<MetaMachines.MetaMachine>> {
        self.functionsCalled.append(.didDeleteDependencies(parameters: (machine, dependency, at)))
        return returns
    }

    /// Mock function.
    func didDeleteStates(
        machine: inout MetaMachines.MetaMachine, state: [MetaMachines.State], at: IndexSet
    ) -> Result<Bool, Attributes.AttributeError<MetaMachines.MetaMachine>> {
        self.functionsCalled.append(.didDeleteStates(parameters: (machine, state, at)))
        return returns
    }

    /// Mock function.
    func didDeleteTransitions(
        machine: inout MetaMachines.MetaMachine,
        transition: [MetaMachines.Transition],
        stateIndex: Int,
        at: IndexSet
    ) -> Result<Bool, Attributes.AttributeError<MetaMachines.MetaMachine>> {
        self.functionsCalled.append(.didDeleteTransitions(parameters: (machine, transition, at, stateIndex)))
        return returns
    }

    /// Mock function.
    func update(from metaMachine: MetaMachines.MetaMachine) {
        self.functionsCalled.append(.update(metaMachine: metaMachine))
    }

    /// Mock function.
    func didAddItem<Path, T>(
        _ item: T, to attribute: Path, machine: inout MetaMachines.MetaMachine
    ) -> Result<Bool, Attributes.AttributeError<Path.Root>> where Path: Attributes.PathProtocol,
        Path.Root == MetaMachines.MetaMachine, Path.Value == [T] {
        self.functionsCalled.append(.didAddItem(parameters: (item as Any, attribute as Any, machine)))
        return returns
    }

    /// Mock function.
    func didMoveItems<Path, T>(
        attribute: Path,
        machine: inout MetaMachines.MetaMachine,
        from source: IndexSet,
        to destination: Int,
        items: [T]
    ) -> Result<Bool, Attributes.AttributeError<Path.Root>> where Path: Attributes.PathProtocol,
        Path.Root == MetaMachines.MetaMachine, Path.Value == [T] {
        self.functionsCalled.append(
            .didMoveItems(parameters: (attribute as Any, machine, source, destination, items as [Any]))
        )
        return returns
    }

    /// Mock function.
    func didDeleteItems<Path, T>(
        table attribute: Path, indices: IndexSet, machine: inout MetaMachines.MetaMachine, items: [T]
    ) -> Result<Bool, Attributes.AttributeError<Path.Root>> where Path: Attributes.PathProtocol,
        Path.Root == MetaMachines.MetaMachine, Path.Value == [T] {
        self.functionsCalled.append(
            .didDeleteItems(parameters: (attribute as Any, indices, machine, items as [Any]))
        )
        return returns
    }

    /// Mock function.
    func didDeleteItem<Path, T>(
        attribute: Path, atIndex: Int, machine: inout MetaMachines.MetaMachine, item: T
    ) -> Result<Bool, Attributes.AttributeError<Path.Root>> where Path: Attributes.PathProtocol,
        Path.Root == MetaMachines.MetaMachine, Path.Value == [T] {
        self.functionsCalled.append(
            .didDeleteItem(parameters: (attribute as Any, atIndex, machine, item as Any))
        )
        return returns
    }

    /// Mock function.
    func didModify<Path>(
        attribute: Path, oldValue: Path.Value, newValue: Path.Value, machine: inout MetaMachines.MetaMachine
    ) -> Result<Bool, Attributes.AttributeError<Path.Root>> where Path: Attributes.PathProtocol,
        Path.Root == MetaMachines.MetaMachine {
        self.functionsCalled.append(
            .didModify(parameters: (attribute as Any, oldValue as Any, newValue as Any, machine))
        )
        return returns
    }

    /// Mock function.
    func validate(machine: MetaMachines.MetaMachine) throws {
        self.functionsCalled.append(.validate(metaMachine: machine))
    }

}
