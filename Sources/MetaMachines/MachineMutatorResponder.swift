//
//  File.swift
//  
//
//  Created by Morgan McColl on 7/6/21.
//

import Attributes
import Foundation

public protocol MachineMutatorResponder: DependencyLayoutContainer {
    
    func didCreateDependency(machine: inout MetaMachine, dependency: MachineDependency, index: Int) -> Result<Bool, AttributeError<MetaMachine>>
    
    func didCreateNewState(machine: inout MetaMachine, state: State, index: Int) -> Result<Bool, AttributeError<MetaMachine>>
    
    func didChangeStatesName(machine: inout MetaMachine, state: State, index: Int, oldName: String) -> Result<Bool, AttributeError<MetaMachine>>
    
    func didCreateNewTransition(machine: inout MetaMachine, transition: Transition, stateIndex: Int, transitionIndex: Int) -> Result<Bool, AttributeError<MetaMachine>>
    
    func didDeleteDependency(machine: inout MetaMachine, dependency: MachineDependency, at: Int) -> Result<Bool, AttributeError<MetaMachine>>
    
    func didDeleteState(machine: inout MetaMachine, state: State, at: Int) -> Result<Bool, AttributeError<MetaMachine>>
    
    func didDeleteTransition(machine: inout MetaMachine, transition: Transition, stateIndex: Int, at: Int) -> Result<Bool, AttributeError<MetaMachine>>
    
    func didDeleteDependencies(machine: inout MetaMachine, dependency: [MachineDependency], at: IndexSet) -> Result<Bool, AttributeError<MetaMachine>>
    
    func didDeleteStates(machine: inout MetaMachine, state: [State], at: IndexSet) -> Result<Bool, AttributeError<MetaMachine>>
    
    func didDeleteTransitions(machine: inout MetaMachine, transition: [Transition], stateIndex: Int, at: IndexSet) -> Result<Bool, AttributeError<MetaMachine>>
    
}
