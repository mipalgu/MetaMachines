//
//  File.swift
//  
//
//  Created by Morgan McColl on 2/6/21.
//

import Attributes
import Foundation

/// A schema that represents a ``MetaMachine``. This schema is similar to the standard `SchemaProtocol` found
/// in `Attributes`, however it has additional properties for the state and transition schemas.
public protocol MachineSchema: SchemaProtocol, MachineMutatorResponder where Root == MetaMachine {

    /// The type of the state schema.
    associatedtype StateSchema: SchemaProtocol where StateSchema.Root == Root

    /// The type of the transition schema.
    associatedtype TransitionSchema: SchemaProtocol where TransitionSchema.Root == Root

    /// The state schema.
    var stateSchema: StateSchema { get }

    /// The transition schema.
    var transitionSchema: TransitionSchema { get }

    /// Initialise this schema from a ``MetaMachine``s properties.
    /// - Parameters:
    ///   - name: The name of the machine.
    ///   - initialState: The name of the initial state in the machine.
    ///   - states: The states of the machine.
    ///   - dependencies: The dependencies of the machine.
    ///   - attributes: The attributes in the machine.
    ///   - metaData: The metadata in the machine.
    init(
        name: String,
        initialState: StateName,
        states: [State],
        dependencies: [MachineDependency],
        attributes: [AttributeGroup],
        metaData: [AttributeGroup]
    )

}

/// Default implementations.
public extension MachineSchema {

    /// The triggers in the state schema, transition schema, and all groups.
    var trigger: AnyTrigger<Root> {
        AnyTrigger(groups.map(\.allTriggers) + [stateSchema.trigger, transitionSchema.trigger])
    }

    /// Default implementation does nothing.
    mutating func didCreateDependency(
        machine: inout MetaMachine, dependency: MachineDependency, index: Int
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        .success(false)
    }

    /// Default implementation does nothing.
    mutating func didCreateNewState(
        machine: inout MetaMachine, state: State, index: Int
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        .success(false)
    }

    /// Default implementation does nothing.
    mutating func didChangeStatesName(
        machine: inout MetaMachine, state: State, index: Int, oldName: String
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        .success(false)
    }

    /// Default implementation does nothing.
    mutating func didCreateNewTransition(
        machine: inout MetaMachine, transition: Transition, stateIndex: Int, transitionIndex: Int
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        .success(false)
    }

    /// Default implementation does nothing.
    mutating func didDeleteDependency(
        machine: inout MetaMachine, dependency: MachineDependency, at: Int
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        .success(false)
    }

    /// Default implementation does nothing.
    mutating func didDeleteState(
        machine: inout MetaMachine, state: State, at: Int
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        .success(false)
    }

    /// Default implementation does nothing.
    mutating func didDeleteTransition(
        machine: inout MetaMachine, transition: Transition, stateIndex: Int, at: Int
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        .success(false)
    }

    /// Default implementation does nothing.
    mutating func didDeleteDependencies(
        machine: inout MetaMachine, dependency: [MachineDependency], at: IndexSet
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        .success(false)
    }

    /// Default implementation does nothing.
    mutating func didDeleteStates(
        machine: inout MetaMachine, state: [State], at: IndexSet
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        .success(false)
    }

    /// Default implementation does nothing.
    mutating func didDeleteTransitions(
        machine: inout MetaMachine, transition: [Transition], stateIndex: Int, at: IndexSet
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        .success(false)
    }

    /// Default implementation does nothing.
    mutating func update(from metaMachine: MetaMachine) {}

}
