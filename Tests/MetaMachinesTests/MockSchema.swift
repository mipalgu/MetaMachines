// MockSchema.swift
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
import AttributesTestUtils
import Foundation
import MetaMachines

/// A mock schema.
final class MockSchema: MachineSchema {

    /// The StateSchema is empty.
    typealias StateSchema = EmptySchema

    /// The transition schema is empty.
    typealias TransitionSchema = EmptySchema

    /// An enum representing which function within the mock was called.
    enum FunctionsCalled: Equatable {

        /// The `didCreateDependency` function.
        case didCreateDependency(machine: MetaMachine, dependency: MachineDependency, index: Int)

        /// The `didCreateNewState` function.
        case didCreateNewState(machine: MetaMachine, state: State, index: Int)

        /// The `didChangeStatesName` function.
        case didChangeStatesName(machine: MetaMachine, state: State, index: Int, oldName: String)

        /// The `didCreateNewTransition` function.
        case didCreateNewTransition(
            machine: MetaMachine, transition: Transition, stateIndex: Int, transitionIndex: Int
        )

        /// The `didDeleteDependency` function.
        case didDeleteDependency(machine: MetaMachine, dependency: MachineDependency, at: Int)

        /// The `didDeleteState` function.
        case didDeleteState(machine: MetaMachine, state: State, at: Int)

        /// The `didDeleteTransition` function.
        case didDeleteTransition(machine: MetaMachine, transition: Transition, stateIndex: Int, at: Int)

        /// The `didDeleteDependencies` function.
        case didDeleteDependencies(machine: MetaMachine, dependency: [MachineDependency], at: IndexSet)

        /// The `didDeleteStates` function.
        case didDeleteStates(machine: MetaMachine, state: [State], at: IndexSet)

        /// The `didDeleteTransitions` function.
        case didDeleteTransitions(
            machine: MetaMachine, transition: [Transition], stateIndex: Int, at: IndexSet
        )

        /// The `update` function.
        case update(metaMachine: MetaMachine)

        /// The `makeValidator` function.
        case makeValidator(root: MetaMachine)

        /// The `groups` computed property.
        case groups

        /// The `trigger` computed property.
        case trigger

    }

    /// The dependency layout.
    var dependencyLayout: [Attributes.Field]

    /// The state schema.
    var stateSchema = EmptySchema()

    /// The transition schema.
    var transitionSchema = EmptySchema()

    /// The value to return from the functions.
    let returnType: Result<Bool, AttributeError<MetaMachine>>

    /// The trigger to use in this schema.
    private let mockTrigger: MockTrigger<MetaMachine>

    /// The functions called in this mock.
    private(set) var functionsCalled: [FunctionsCalled] = []

    /// The last function called.
    var lastFunctionCalled: FunctionsCalled? {
        functionsCalled.last
    }

    /// All `didCreateDependency` function calls.
    var didCreateDependencyCalls: [FunctionsCalled] {
        functionsCalled.filter {
            if case .didCreateDependency = $0 {
                return true
            }
            return false
        }
    }

    /// All `didCreateNewState` function calls.
    var didCreateNewStateCalls: [FunctionsCalled] {
        functionsCalled.filter {
            if case .didCreateNewState = $0 {
                return true
            }
            return false
        }
    }

    /// All `didChangeStatesName` function calls.
    var didChangeStatesNameCalls: [FunctionsCalled] {
        functionsCalled.filter {
            if case .didChangeStatesName = $0 {
                return true
            }
            return false
        }
    }

    /// All `didCreateNewTransition` function calls.
    var didCreateNewTransitionCalls: [FunctionsCalled] {
        functionsCalled.filter {
            if case .didCreateNewTransition = $0 {
                return true
            }
            return false
        }
    }

    /// All `didDeleteDependency` function calls.
    var didDeleteDependencyCalls: [FunctionsCalled] {
        functionsCalled.filter {
            if case .didDeleteDependency = $0 {
                return true
            }
            return false
        }
    }

    /// All `didDeleteState` function calls.
    var didDeleteStateCalls: [FunctionsCalled] {
        functionsCalled.filter {
            if case .didDeleteState = $0 {
                return true
            }
            return false
        }
    }

    /// All `didDeleteTransition` function calls.
    var didDeleteTransitionCalls: [FunctionsCalled] {
        functionsCalled.filter {
            if case .didDeleteTransition = $0 {
                return true
            }
            return false
        }
    }

    /// All `didDeleteDependencies` function calls.
    var didDeleteDependenciesCalls: [FunctionsCalled] {
        functionsCalled.filter {
            if case .didDeleteDependencies = $0 {
                return true
            }
            return false
        }
    }

    /// All `didDeleteStates` function calls.
    var didDeleteStatesCalls: [FunctionsCalled] {
        functionsCalled.filter {
            if case .didDeleteStates = $0 {
                return true
            }
            return false
        }
    }

    /// All `didDeleteTransitions` function calls.
    var didDeleteTransitionsCalls: [FunctionsCalled] {
        functionsCalled.filter {
            if case .didDeleteTransitions = $0 {
                return true
            }
            return false
        }
    }

    /// All `update` function calls.
    var updateCalls: [FunctionsCalled] {
        functionsCalled.filter {
            if case .update = $0 {
                return true
            }
            return false
        }
    }

    /// All `makeValidator` function calls.
    var makeValidatorCalls: [FunctionsCalled] {
        functionsCalled.filter {
            if case .makeValidator = $0 {
                return true
            }
            return false
        }
    }

    /// All `groups` function calls.
    var groupsCalls: [FunctionsCalled] {
        functionsCalled.filter {
            if case .groups = $0 {
                return true
            }
            return false
        }
    }

    /// All `trigger` function calls.
    var triggerCalls: [FunctionsCalled] {
        functionsCalled.filter {
            if case .trigger = $0 {
                return true
            }
            return false
        }
    }

    /// The number of times `didCreateDependency` was called.
    var didCreateDependencyTimesCalled: Int {
        didCreateDependencyCalls.count
    }

    /// The number of times `didCreateNewState` was called.
    var didCreateNewStateTimesCalled: Int {
        didCreateNewStateCalls.count
    }

    /// The number of times `didChangeStatesName` was called.
    var didChangeStatesNameTimesCalled: Int {
        didChangeStatesNameCalls.count
    }

    /// The number of times `didCreateNewTransition` was called.
    var didCreateNewTransitionTimesCalled: Int {
        didCreateNewTransitionCalls.count
    }

    /// The number of times `didDeleteDependency` was called.
    var didDeleteDependencyTimesCalled: Int {
        didDeleteDependencyCalls.count
    }

    /// The number of times `didDeleteState` was called.
    var didDeleteStateTimesCalled: Int {
        didDeleteStateCalls.count
    }

    /// The number of times `didDeleteTransition` was called.
    var didDeleteTransitionTimesCalled: Int {
        didDeleteTransitionCalls.count
    }

    /// The number of times `didDeleteDependencies` was called.
    var didDeleteDependenciesTimesCalled: Int {
        didDeleteDependenciesCalls.count
    }

    /// The number of times `didDeleteStates` was called.
    var didDeleteStatesTimesCalled: Int {
        didDeleteStatesCalls.count
    }

    /// The number of times `didDeleteTransitions` was called.
    var didDeleteTransitionsTimesCalled: Int {
        didDeleteTransitionsCalls.count
    }

    /// The number of times `update` was called.
    var updateTimesCalled: Int {
        updateCalls.count
    }

    /// The number of times `makeValidator` was called.
    var makeValidatorTimesCalled: Int {
        makeValidatorCalls.count
    }

    /// The number of times `groups` was called.
    var groupsTimesCalled: Int {
        groupsCalls.count
    }

    /// The number of times `trigger` was called.
    var triggerTimesCalled: Int {
        triggerCalls.count
    }

    /// The `groups` computed property.
    var groups: [AnyGroup<MetaMachine>] {
        functionsCalled.append(.groups)
        return []
    }

    /// The `trigger` computed property
    var trigger: AnyTrigger<MetaMachine> {
        functionsCalled.append(.trigger)
        return AnyTrigger(mockTrigger)
    }

    /// Initialise this mock with a dependency layout.
    /// - Parameter dependencyLayout: The dependency layout.
    /// - Parameter trigger: The trigger used in this schema.
    /// - Parameter returnType: The return type of the functions.
    init(
        dependencyLayout: [Field],
        trigger: MockTrigger<MetaMachine>,
        returnType: Result<Bool, AttributeError<MetaMachine>> = .success(false)
    ) {
        self.dependencyLayout = dependencyLayout
        self.mockTrigger = trigger
        self.returnType = returnType
    }

    /// The `didCreateDependency` function.
    func didCreateDependency(
        machine: inout MetaMachine, dependency: MachineDependency, index: Int
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        functionsCalled.append(.didCreateDependency(machine: machine, dependency: dependency, index: index))
        return returnType
    }

    /// The `didCreateNewState` function.
    func didCreateNewState(
        machine: inout MetaMachine, state: State, index: Int
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        functionsCalled.append(.didCreateNewState(machine: machine, state: state, index: index))
        return returnType
    }

    /// The `didChangeStatesName` function.
    func didChangeStatesName(
        machine: inout MetaMachine, state: State, index: Int, oldName: String
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        functionsCalled.append(
            .didChangeStatesName(machine: machine, state: state, index: index, oldName: oldName)
        )
        return returnType
    }

    /// The `didCreateNewTransition` function.
    func didCreateNewTransition(
        machine: inout MetaMachine, transition: Transition, stateIndex: Int, transitionIndex: Int
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        functionsCalled.append(
            .didCreateNewTransition(
                machine: machine,
                transition: transition,
                stateIndex: stateIndex,
                transitionIndex: transitionIndex
            )
        )
        return returnType
    }

    /// The `didDeleteDependency` function.
    func didDeleteDependency(
        machine: inout MetaMachine, dependency: MachineDependency, at: Int
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        functionsCalled.append(.didDeleteDependency(machine: machine, dependency: dependency, at: at))
        return returnType
    }

    /// The `didDeleteState` function.
    func didDeleteState(
        machine: inout MetaMachine, state: State, at: Int
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        functionsCalled.append(.didDeleteState(machine: machine, state: state, at: at))
        return returnType
    }

    /// The `didDeleteTransition` function.
    func didDeleteTransition(
        machine: inout MetaMachine, transition: Transition, stateIndex: Int, at: Int
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        functionsCalled.append(
            .didDeleteTransition(
                machine: machine,
                transition: transition,
                stateIndex: stateIndex,
                at: at
            )
        )
        return returnType
    }

    /// The `didDeleteDependencies` function.
    func didDeleteDependencies(
        machine: inout MetaMachine, dependency: [MachineDependency], at: IndexSet
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        functionsCalled.append(.didDeleteDependencies(machine: machine, dependency: dependency, at: at))
        return returnType
    }

    /// The `didDeleteStates` function.
    func didDeleteStates(
        machine: inout MetaMachine, state: [State], at: IndexSet
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        functionsCalled.append(.didDeleteStates(machine: machine, state: state, at: at))
        return returnType
    }

    /// The `didDeleteTransitions` function.
    func didDeleteTransitions(
        machine: inout MetaMachine, transition: [Transition], stateIndex: Int, at: IndexSet
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        functionsCalled.append(
            .didDeleteTransitions(
                machine: machine,
                transition: transition,
                stateIndex: stateIndex,
                at: at
            )
        )
        return returnType
    }

    /// The `update` function.
    func update(from metaMachine: MetaMachine) {
        functionsCalled.append(.update(metaMachine: metaMachine))
    }

    /// The `makeValidator` function.
    func makeValidator(root: MetaMachine) -> AnyValidator<MetaMachine> {
        functionsCalled.append(.makeValidator(root: root))
        return AnyValidator([])
    }

}
