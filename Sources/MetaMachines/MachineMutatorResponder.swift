//
//  File.swift
//  
//
//  Created by Morgan McColl on 7/6/21.
//

import Attributes
import Foundation

/// A protocol for defining types that can define functions in response to events that happen within a
/// ``MetaMachine``.
public protocol MachineMutatorResponder: DependencyLayoutContainer {

    /// Enact some function in response to a machine creating a dependency.
    /// - Parameters:
    ///   - machine: The machine that contains the dependency.
    ///   - dependency: The newly created dependency.
    ///   - index: The index of the newly created dependency.
    /// - Returns: Whether or not the this function succeeded.
    mutating func didCreateDependency(
        machine: inout MetaMachine, dependency: MachineDependency, index: Int
    ) -> Result<Bool, AttributeError<MetaMachine>>

    /// Enact some function in response to a machine creating a state.
    /// - Parameters:
    ///   - machine: The machine that contains the state.
    ///   - state: The newly created state.
    ///   - index: The index of the newly created state.
    /// - Returns: Whether or not the this function succeeded.
    mutating func didCreateNewState(
        machine: inout MetaMachine, state: State, index: Int
    ) -> Result<Bool, AttributeError<MetaMachine>>

    /// Enact some function in response to a machine changing a states name.
    /// - Parameters:
    ///   - machine: The machine that contains the state.
    ///   - state: The state that had its name changed.
    ///   - index: The index of the state that had its name changed.
    ///   - oldName: The original name of the state.
    /// - Returns: Whether or not the this function succeeded.
    mutating func didChangeStatesName(
        machine: inout MetaMachine, state: State, index: Int, oldName: String
    ) -> Result<Bool, AttributeError<MetaMachine>>

    /// Enact some function in response to a machine creating a new transition.
    /// - Parameters:
    ///   - machine: The machine that contains the transition.
    ///   - transition: The newly created transition.
    ///   - stateIndex: The index of the state that contains the transition.
    ///   - transitionIndex: The index of the newly created transition.
    /// - Returns: Whether or not the this function succeeded.
    mutating func didCreateNewTransition(
        machine: inout MetaMachine, transition: Transition, stateIndex: Int, transitionIndex: Int
    ) -> Result<Bool, AttributeError<MetaMachine>>

    /// Enact some function in response to a machine deleting a dependency.
    /// - Parameters:
    ///   - machine: The machine that contains the dependency.
    ///   - dependency: The dependency that was deleted.
    ///   - at: The index of the deleted dependency.
    /// - Returns: Whether or not the this function succeeded.
    mutating func didDeleteDependency(
        machine: inout MetaMachine, dependency: MachineDependency, at: Int
    ) -> Result<Bool, AttributeError<MetaMachine>>

    /// Enact some function in response to a machine deleting a state.
    /// - Parameters:
    ///   - machine: The machine that contains the state.
    ///   - state: The state that was deleted.
    ///   - at: The index of the deleted state.
    /// - Returns: Whether or not the this function succeeded.
    mutating func didDeleteState(
        machine: inout MetaMachine, state: State, at: Int
    ) -> Result<Bool, AttributeError<MetaMachine>>

    /// Enact some function in response to a machine deleting a transition.
    /// - Parameters:
    ///   - machine: The machine that contains the transition.
    ///   - transition: The transition that was deleted.
    ///   - stateIndex: The index of the state that contains the transition.
    ///   - at: The index of the deleted transition.
    /// - Returns: Whether or not the this function succeeded.
    mutating func didDeleteTransition(
        machine: inout MetaMachine, transition: Transition, stateIndex: Int, at: Int
    ) -> Result<Bool, AttributeError<MetaMachine>>

    /// Enact some function in response to a machine deleting multiple dependencies.
    /// - Parameters:
    ///   - machine: The machine that contains the dependencies.
    ///   - dependency: The dependencies that were deleted.
    ///   - at: The indexes of the deleted dependencies.
    /// - Returns: Whether or not the this function succeeded.
    mutating func didDeleteDependencies(
        machine: inout MetaMachine, dependency: [MachineDependency], at: IndexSet
    ) -> Result<Bool, AttributeError<MetaMachine>>

    /// Enact some function in response to a machine deleting multiple states.
    /// - Parameters:
    ///   - machine: The machine that contains the states.
    ///   - state: The states that were deleted.
    ///   - at: The indexes of the deleted states.
    /// - Returns: Whether or not the this function succeeded.
    mutating func didDeleteStates(
        machine: inout MetaMachine, state: [State], at: IndexSet
    ) -> Result<Bool, AttributeError<MetaMachine>>

    /// Enact some function in response to a machine deleting multiple transitions.
    /// - Parameters:
    ///   - machine: The machine that contains the transitions.
    ///   - transition: The transitions that were deleted.
    ///   - stateIndex: The index of the state that contains the transitions.
    ///   - at: The indexes of the deleted transitions.
    /// - Returns: Whether or not the this function succeeded.
    mutating func didDeleteTransitions(
        machine: inout MetaMachine, transition: [Transition], stateIndex: Int, at: IndexSet
    ) -> Result<Bool, AttributeError<MetaMachine>>

    /// Update this ``MachineMutatorResponder`` from a ``MetaMachine``.
    /// - Parameter metaMachine: The ``MetaMachine`` to update from.
    mutating func update(from metaMachine: MetaMachine)

}
