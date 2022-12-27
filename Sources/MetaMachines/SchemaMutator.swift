//
//  File.swift
//  
//
//  Created by Morgan McColl on 31/5/21.
//

import Attributes
import Foundation

/// A mutator that delegates to an underlying schema.
struct SchemaMutator<Schema: MachineSchema>: MachineMutatorResponder, MachineModifier,
    MachineAttributesMutator {

    /// The schema to delegate to.
    var schema: Schema

    /// The dependency layout of the mutator.
    var dependencyLayout: [Field] {
        schema.dependencyLayout
    }

    /// The function executed after a dependency is created.
    /// - Parameters:
    ///   - machine: The machine containing the dependencies.
    ///   - dependency: The dependency that was created.
    ///   - index: The index of the new dependency.
    /// - Returns: A result indicating whether this change affects other attributes within the machine.
    mutating func didCreateDependency(
        machine: inout MetaMachine, dependency: MachineDependency, index: Int
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        perform(metaMachine: &machine) { me, machine in
            me.schema.didCreateDependency(machine: &machine, dependency: dependency, index: index)
        }
    }

    /// The function executed after a state is created.
    /// - Parameters:
    ///   - machine: The machine containing the new state.
    ///   - state: The new state.
    ///   - index: The index of the new state.
    /// - Returns: A result indicating whether this change affects other attributes within the machine.
    mutating func didCreateNewState(
        machine: inout MetaMachine, state: State, index: Int
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        perform(metaMachine: &machine) { me, machine in
            me.schema.didCreateNewState(machine: &machine, state: state, index: index)
        }
    }

    /// The function executed after a states name is mutated.
    /// - Parameters:
    ///   - machine: The machine containing the state.
    ///   - state: The state that was mutated.
    ///   - index: The index of the state.
    ///   - oldName: The old name of the state.
    /// - Returns: Whether this change affects other attributes within the machine.
    mutating func didChangeStatesName(
        machine: inout MetaMachine, state: State, index: Int, oldName: String
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        perform(metaMachine: &machine) { me, machine in
            me.schema.didChangeStatesName(machine: &machine, state: state, index: index, oldName: oldName)
        }
    }

    /// The function executed after a transition is created.
    /// - Parameters:
    ///   - machine: The machine containing the new transition.
    ///   - transition: The new transition.
    ///   - stateIndex: The index of the state containing the new transition.
    ///   - transitionIndex: The index of the new transition.
    /// - Returns: Whether this change affects other attributes within the machine.
    mutating func didCreateNewTransition(
        machine: inout MetaMachine, transition: Transition, stateIndex: Int, transitionIndex: Int
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        perform(metaMachine: &machine) { me, machine in
            me.schema.didCreateNewTransition(
                machine: &machine,
                transition: transition,
                stateIndex: stateIndex,
                transitionIndex: transitionIndex
            )
        }
    }

    /// The function executed after dependencies are deleted.
    /// - Parameters:
    ///   - machine: The machine containing the dependencies.
    ///   - dependency: The dependencies that were deleted.
    ///   - at: The indices of the deleted dependencies.
    /// - Returns: Whether this change affects other attributes within the machine.
    mutating func didDeleteDependencies(
        machine: inout MetaMachine, dependency: [MachineDependency], at: IndexSet
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        perform(metaMachine: &machine) { me, machine in
            me.schema.didDeleteDependencies(machine: &machine, dependency: dependency, at: at)
        }
    }

    /// The function executed after states are deleted.
    /// - Parameters:
    ///   - machine: The machine containing the states.
    ///   - state: The states that were deleted.
    ///   - at: The indices of the deleted states.
    /// - Returns: Whether this change affects other attributes within the machine.
    mutating func didDeleteStates(
        machine: inout MetaMachine, state: [State], at: IndexSet
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        perform(metaMachine: &machine) { me, machine in
            me.schema.didDeleteStates(machine: &machine, state: state, at: at)
        }
    }

    /// The function executed after transitions are deleted.
    /// - Parameters:
    ///   - machine: The machine containing the transitions.
    ///   - transition: The transitions that were deleted.
    ///   - stateIndex: The index of the state containing the deleted transitions.
    ///   - at: The indices of the deleted transitions.
    /// - Returns: Whether this change affects other attributes within the machine.
    mutating func didDeleteTransitions(
        machine: inout MetaMachine, transition: [Transition], stateIndex: Int, at: IndexSet
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        perform(metaMachine: &machine) { me, machine in
            me.schema.didDeleteTransitions(
                machine: &machine, transition: transition, stateIndex: stateIndex, at: at
            )
        }
    }

    /// The function executed after a dependency is deleted.
    /// - Parameters:
    ///   - machine: The machine containing the dependency.
    ///   - dependency: The dependency that was deleted.
    ///   - at: The index of the deleted dependency.
    /// - Returns: Whether this change affects other attributes within the machine.
    mutating func didDeleteDependency(
        machine: inout MetaMachine, dependency: MachineDependency, at: Int
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        perform(metaMachine: &machine) { me, machine in
            me.schema.didDeleteDependency(machine: &machine, dependency: dependency, at: at)
        }
    }

    /// The function executed after a state is deleted.
    /// - Parameters:
    ///   - machine: The machine containing the state.
    ///   - state: The state that was deleted.
    ///   - at: The index of the deleted state.
    /// - Returns: Whether this change affects other attributes within the machine.
    mutating func didDeleteState(
        machine: inout MetaMachine, state: State, at: Int
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        perform(metaMachine: &machine) { me, machine in
            me.schema.didDeleteState(machine: &machine, state: state, at: at)
        }
    }

    /// The function executed after a transition is deleted.
    /// - Parameters:
    ///   - machine: The machine containing the transition.
    ///   - transition: The transition that was deleted.
    ///   - stateIndex: The index of the state containing the deleted transition.
    ///   - at: The index of the deleted transition.
    /// - Returns: Whether this change affects other attributes within the machine.
    mutating func didDeleteTransition(
        machine: inout MetaMachine, transition: Transition, stateIndex: Int, at: Int
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        perform(metaMachine: &machine) { me, machine in
            me.schema.didDeleteTransition(
                machine: &machine, transition: transition, stateIndex: stateIndex, at: at
            )
        }
    }

    /// The function executed after an item is added to an array within a machine.
    /// - Parameters:
    ///   - item: The item that was added.
    ///   - attribute: The path to the array.
    ///   - machine: The machine containing the array.
    /// - Returns: Whether this change affects other attributes within the machine.
    mutating func didAddItem<Path: PathProtocol, T>(
        _ item: T, to attribute: Path, machine: inout MetaMachine
    ) -> Result<Bool, AttributeError<Path.Root>> where Path.Root == MetaMachine, Path.Value == [T] {
        perform(metaMachine: &machine) { me, machine in
            me.schema.trigger.performTrigger(&machine, for: AnyPath(attribute))
        }
    }
    
    mutating func didDeleteItems<Path: PathProtocol, T>(table attribute: Path, indices: IndexSet, machine: inout MetaMachine, items: [T]) -> Result<Bool, AttributeError<Path.Root>> where Path.Root == MetaMachine, Path.Value == [T] {
        perform(metaMachine: &machine) { (me, machine) in
            me.schema.trigger.performTrigger(&machine, for: AnyPath(attribute))
        }
    }
    
    mutating func didDeleteItem<Path: PathProtocol, T>(attribute: Path, atIndex: Int, machine: inout MetaMachine, item: T) -> Result<Bool, AttributeError<Path.Root>> where Path.Root == MetaMachine, Path.Value == [T] {
        perform(metaMachine: &machine) { (me, machine) in
            me.schema.trigger.performTrigger(&machine, for: AnyPath(attribute))
        }
    }
    
    mutating func didMoveItems<Path: PathProtocol, T>(attribute: Path, machine: inout MetaMachine, from source: IndexSet, to destination: Int, items: [T]) -> Result<Bool, AttributeError<Path.Root>> where Path.Root == MetaMachine, Path.Value == [T] {
        perform(metaMachine: &machine) { (me, machine) in
            me.schema.trigger.performTrigger(&machine, for: AnyPath(attribute))
        }
    }
    
    mutating func didModify<Path: PathProtocol>(attribute: Path, oldValue: Path.Value, newValue: Path.Value, machine: inout MetaMachine) -> Result<Bool, AttributeError<Path.Root>> where Path.Root == MetaMachine {
        self.perform(metaMachine: &machine) { (me, machine) in
            me.schema.trigger.performTrigger(&machine, for: AnyPath(attribute))
        }
    }
    
    mutating func update(from metaMachine: MetaMachine) {
        schema.update(from: metaMachine)
    }
    
    private mutating func perform(metaMachine: inout MetaMachine, _ f: (inout Self, inout MetaMachine) -> Result<Bool, AttributeError<MetaMachine>>) -> Result<Bool, AttributeError<MetaMachine>> {
        let result = f(&self, &metaMachine)
        update(from: metaMachine)
        return result
    }
    
    func validate(machine: MetaMachine) throws {
        try schema.makeValidator(root: machine).performValidation(machine)
    }

}
