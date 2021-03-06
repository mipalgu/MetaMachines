//
//  File.swift
//  
//
//  Created by Morgan McColl on 2/6/21.
//

import Foundation
import Attributes

public protocol MachineSchema: SchemaProtocol, MachineMutatorResponder where Root == MetaMachine {
    
    associatedtype StateSchema: SchemaProtocol where StateSchema.Root == Root
    
    associatedtype TransitionSchema: SchemaProtocol where TransitionSchema.Root == Root
    
    var stateSchema: StateSchema { get }
    
    var transitionSchema: TransitionSchema { get }
    
}

public extension MachineSchema {
    
    mutating func didCreateDependency(machine: inout MetaMachine, dependency: MachineDependency, index: Int) -> Result<Bool, AttributeError<MetaMachine>> {
        return .success(false)
    }
    
    mutating func didCreateNewState(machine: inout MetaMachine, state: State, index: Int) -> Result<Bool, AttributeError<MetaMachine>> {
        return .success(false)
    }
    
    mutating func didChangeStatesName(machine: inout MetaMachine, state: State, index: Int, oldName: String) -> Result<Bool, AttributeError<MetaMachine>> {
        return .success(false)
    }
    
    mutating func didCreateNewTransition(machine: inout MetaMachine, transition: Transition, stateIndex: Int, transitionIndex: Int) -> Result<Bool, AttributeError<MetaMachine>> {
        return .success(false)
    }
    
    mutating func didDeleteDependency(machine: inout MetaMachine, dependency: MachineDependency, at: Int) -> Result<Bool, AttributeError<MetaMachine>> {
        return .success(false)
    }
    
    mutating func didDeleteState(machine: inout MetaMachine, state: State, at: Int) -> Result<Bool, AttributeError<MetaMachine>> {
        return .success(false)
    }
    
    mutating func didDeleteTransition(machine: inout MetaMachine, transition: Transition, stateIndex: Int, at: Int) -> Result<Bool, AttributeError<MetaMachine>> {
        return .success(false)
    }
    
    mutating func didDeleteDependencies(machine: inout MetaMachine, dependency: [MachineDependency], at: IndexSet) -> Result<Bool, AttributeError<MetaMachine>> {
        return .success(false)
    }
    
    mutating func didDeleteStates(machine: inout MetaMachine, state: [State], at: IndexSet) -> Result<Bool, AttributeError<MetaMachine>> {
        return .success(false)
    }
    
    mutating func didDeleteTransitions(machine: inout MetaMachine, transition: [Transition], stateIndex: Int, at: IndexSet) -> Result<Bool, AttributeError<MetaMachine>> {
        return .success(false)
    }
    
    mutating func update(from metaMachine: MetaMachine) {}
    
}
