//
//  File.swift
//  
//
//  Created by Morgan McColl on 31/5/21.
//

import Foundation
import Attributes

struct SchemaMutator<Schema: MachineSchema>: MachineMutatorResponder, MachineModifier, MachineAttributesMutator {

    var schema: Schema
    
    var dependencyLayout: [Field] {
        schema.dependencyLayout
    }
    
    mutating func didCreateDependency(machine: inout MetaMachine, dependency: MachineDependency, index: Int) -> Result<Bool, AttributeError<MetaMachine>> {
        schema.didCreateDependency(machine: &machine, dependency: dependency, index: index)
    }
    
    mutating func didCreateNewState(machine: inout MetaMachine, state: State, index: Int) -> Result<Bool, AttributeError<MetaMachine>> {
        schema.didCreateNewState(machine: &machine, state: state, index: index)
    }
    
    mutating func didChangeStatesName(machine: inout MetaMachine, state: State, index: Int, oldName: String) -> Result<Bool, AttributeError<MetaMachine>> {
        schema.didChangeStatesName(machine: &machine, state: state, index: index, oldName: oldName)
    }
    
    mutating func didCreateNewTransition(machine: inout MetaMachine, transition: Transition, stateIndex: Int, transitionIndex: Int) -> Result<Bool, AttributeError<MetaMachine>> {
        schema.didCreateNewTransition(machine: &machine, transition: transition, stateIndex: stateIndex, transitionIndex: transitionIndex)
    }
    
    mutating func didDeleteDependencies(machine: inout MetaMachine, dependency: [MachineDependency], at: IndexSet) -> Result<Bool, AttributeError<MetaMachine>> {
        schema.didDeleteDependencies(machine: &machine, dependency: dependency, at: at)
    }
    
    mutating func didDeleteStates(machine: inout MetaMachine, state: [State], at: IndexSet) -> Result<Bool, AttributeError<MetaMachine>> {
        schema.didDeleteStates(machine: &machine, state: state, at: at)
    }
    
    mutating func didDeleteTransitions(machine: inout MetaMachine, transition: [Transition], stateIndex: Int, at: IndexSet) -> Result<Bool, AttributeError<MetaMachine>> {
        schema.didDeleteTransitions(machine: &machine, transition: transition, stateIndex: stateIndex, at: at)
    }
    
    mutating func didDeleteDependency(machine: inout MetaMachine, dependency: MachineDependency, at: Int) -> Result<Bool, AttributeError<MetaMachine>> {
        schema.didDeleteDependency(machine: &machine, dependency: dependency, at: at)
    }
    
    mutating func didDeleteState(machine: inout MetaMachine, state: State, at: Int) -> Result<Bool, AttributeError<MetaMachine>> {
        schema.didDeleteState(machine: &machine, state: state, at: at)
    }
    
    mutating func didDeleteTransition(machine: inout MetaMachine, transition: Transition, stateIndex: Int, at: Int) -> Result<Bool, AttributeError<MetaMachine>> {
        schema.didDeleteTransition(machine: &machine, transition: transition, stateIndex: stateIndex, at: at)
    }
    
    mutating func didAddItem<Path: PathProtocol, T>(_ item: T, to attribute: Path, machine: inout MetaMachine) -> Result<Bool, AttributeError<Path.Root>> where Path.Root == MetaMachine, Path.Value == [T] {
        return schema.trigger.performTrigger(&machine, for: AnyPath(attribute))
    }
    
    mutating func didDeleteItems<Path: PathProtocol, T>(table attribute: Path, indices: IndexSet, machine: inout MetaMachine, items: [T]) -> Result<Bool, AttributeError<Path.Root>> where Path.Root == MetaMachine, Path.Value == [T] {
        return schema.trigger.performTrigger(&machine, for: AnyPath(attribute))
    }
    
    mutating func didDeleteItem<Path: PathProtocol, T>(attribute: Path, atIndex: Int, machine: inout MetaMachine, item: T) -> Result<Bool, AttributeError<Path.Root>> where Path.Root == MetaMachine, Path.Value == [T] {
        return schema.trigger.performTrigger(&machine, for: AnyPath(attribute))
    }
    
    mutating func didMoveItems<Path: PathProtocol, T>(attribute: Path, machine: inout MetaMachine, from source: IndexSet, to destination: Int, items: [T]) -> Result<Bool, AttributeError<Path.Root>> where Path.Root == MetaMachine, Path.Value == [T] {
        return schema.trigger.performTrigger(&machine, for: AnyPath(attribute))
    }
    
    mutating func didModify<Path: PathProtocol>(attribute: Path, oldValue: Path.Value, newValue: Path.Value, machine: inout MetaMachine) -> Result<Bool, AttributeError<Path.Root>> where Path.Root == MetaMachine {
        return schema.trigger.performTrigger(&machine, for: AnyPath(attribute))
    }
    
    func validate(machine: MetaMachine) throws {
        try schema.makeValidator(root: machine).performValidation(machine)
    }

}
