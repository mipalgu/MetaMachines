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
    
    func didCreateDependency(machine: inout MetaMachine, dependency: MachineDependency, index: Int) -> Result<Bool, AttributeError<MetaMachine>> {
        return .success(false)
    }
    
    func didCreateNewState(machine: inout MetaMachine, state: State, index: Int) -> Result<Bool, AttributeError<MetaMachine>> {
        return .success(false)
    }
    
    func didChangeStatesName(machine: inout MetaMachine, state: State, index: Int, oldName: String) -> Result<Bool, AttributeError<MetaMachine>> {
        return .success(false)
    }
    
    func didCreateNewTransition(machine: inout MetaMachine, transition: Transition, stateIndex: Int, transitionIndex: Int) -> Result<Bool, AttributeError<MetaMachine>> {
        return .success(false)
    }
    
    func didDeleteDependency(machine: inout MetaMachine, dependency: MachineDependency, at: Int) -> Result<Bool, AttributeError<MetaMachine>> {
        return .success(false)
    }
    
    func didDeleteState(machine: inout MetaMachine, state: State, at: Int) -> Result<Bool, AttributeError<MetaMachine>> {
        return .success(false)
    }
    
    func didDeleteTransition(machine: inout MetaMachine, transition: Transition, stateIndex: Int, at: Int) -> Result<Bool, AttributeError<MetaMachine>> {
        return .success(false)
    }
    
    func didDeleteDependencies(machine: inout MetaMachine, dependency: [MachineDependency], at: IndexSet) -> Result<Bool, AttributeError<MetaMachine>> {
        return .success(false)
    }
    
    func didDeleteStates(machine: inout MetaMachine, state: [State], at: IndexSet) -> Result<Bool, AttributeError<MetaMachine>> {
        return .success(false)
    }
    
    func didDeleteTransitions(machine: inout MetaMachine, transition: [Transition], stateIndex: Int, at: IndexSet) -> Result<Bool, AttributeError<MetaMachine>> {
        return .success(false)
    }
    
}
