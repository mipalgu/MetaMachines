/*
 * Machine.swift
 * Machines
 *
 * Created by Callum McColl on 18/9/18.
 * Copyright © 2018 Callum McColl. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above
 *    copyright notice, this list of conditions and the following
 *    disclaimer in the documentation and/or other materials
 *    provided with the distribution.
 *
 * 3. All advertising materials mentioning features or use of this
 *    software must display the following acknowledgement:
 *
 *        This product includes software developed by Callum McColl.
 *
 * 4. Neither the name of the author nor the names of contributors
 *    may be used to endorse or promote products derived from this
 *    software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * -----------------------------------------------------------------------
 * This program is free software; you can redistribute it and/or
 * modify it under the above terms or under the terms of the GNU
 * General Public License as published by the Free Software Foundation;
 * either version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, see http://www.gnu.org/licenses/
 * or write to the Free Software Foundation, Inc., 51 Franklin Street,
 * Fifth Floor, Boston, MA  02110-1301, USA.
 *
 */

import Foundation
import Attributes
#if os(Linux)
import IO
#endif

/// A general meta model machine.
///
/// This type is responsible for representing all possible supported semantics
/// provided by an LLFSM scheduler (swiftfsm, clfsm for example). Because the
/// meta model needs to be able to represent a wide array of semantics, this
/// data structures --- as well as other general data structures this type
/// depends on --- take a minimalistic view of LLFSM semantics. The idea here
/// is to establish a semantics within the meta model which all schedulers
/// share. Any additional data that is required for custom semantics of a
/// particular scheduler is enabled through the use of `Attribute`s and
/// `AttributeGroup`s which provide a type agnostic interface for specifying
/// such data.
///
/// Importantly, the meta model needs to be convertible to the underlying data
/// structures for specific concrete implementations --- `SwiftMachines.Machine`
/// for swiftfsm machines for example.
///
/// - SeeAlso: `SwiftMachinesConvertible`.
public struct MetaMachine: PathContainer, Modifiable, MutatorContainer, DependenciesContainer {

    /// The mutators type.
    public typealias Mutator = MachineMutatorResponder & MachineAttributesMutator & MachineModifier

    /// The semantics available to the meta machine.
    public enum Semantics: String, Hashable, Codable, CaseIterable, Comparable {

        /// Miscellanious semantics.
        case other

        /// The swiftfsm semantics used for swift machines.
        case swiftfsm

        /// The clfsm semantics used for C++ machines.
        case clfsm

        /// The vhdl semantics used for HDL machines in FPGAs.
        case vhdl

        /// The ucfsm semantics used for C machines on bare-metal implementations.
        case ucfsm

        /// The spartanfsm semantics used for VHDL machines based on the clfsm machine format.
        case spartanfsm

        /// Compare two semantics. This places the semantics in alphabetical order.
        public static func < (lhs: MetaMachine.Semantics, rhs: MetaMachine.Semantics) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    /// The semantics that are fully supported by this module.
    ///
    /// This means that it is possible to create a machine using the
    /// helper functions such as `initialMachine(forSemantics:)` or call
    /// the semantics initialiser.
    ///
    /// If you are implementing an editor, this could be used when creating a
    /// new machine to display a list of options to asking inquiring which
    /// semantics they would like to use.
    ///
    /// This array generally contains all semantics except for the `other` case.
    public static var supportedSemantics: [MetaMachine.Semantics] {
        MetaMachine.Semantics.allCases.filter { $0 != .other }
    }

    /// Fetches a keypath like structure for use when modifying and validating
    /// properties of machines.
    public static var path: Path<MetaMachine, MetaMachine> {
        Path(Self.self)
    }

    /// The underlying mutator that handles operations on the machine.
    public fileprivate(set) var mutator: Mutator

    /// The collection of errors within the machine.
    public private(set) var errorBag: ErrorBag<MetaMachine> = ErrorBag()

    /// The ID of the machine.
    public private(set) var id = UUID()

    /// The underlying semantics which this meta machine follows.
    public var semantics: Semantics

    /// The name of the machine.
    public var name: String

    /// The name of the initial state.
    ///
    /// The name should represent the name of a state within the `states` array.
    public var initialState: StateName

    /// The accepting states of the machine.
    ///
    /// An accepting state is a state without any transitions.
    ///
    /// - Complexity: O(n * m) where n is the length of the `states` array and
    /// m is the length of the `transitions` array.
    public var acceptingStates: [State] {
        self.states.filter { $0.transitions.isEmpty }
    }

    /// All states within the machine.
    public var states: [State]

    /// All machines that this machine depends on
    public var dependencies: [MachineDependency]

    /// A list of attributes specifying additional fields that can change.
    ///
    /// The attribute list usually details extra fields necessary for additional
    /// semantics not covered in the general meta machine model. The meta
    /// machine model takes a minimalistic point of view where the meta model
    /// represents the common semantics between different schedulers
    /// (swiftfsm, clfsm for example). Obviously each scheduler has a different
    /// feature set. The features which are not common between schedulers
    /// should be facilitated through this attributes field.
    public var attributes: [AttributeGroup]

    /// A list of attributes specifying additional fields that do not change.
    ///
    /// This metaData property is similar to the `attributes` property, however;
    /// the values within this field are under the control of the parsers and
    /// generators for the specific scheduler. This allows the parsers and
    /// generators to parse/generate machines which require data that the user
    /// doesn't necessarily need to know about. These fields are therefore
    /// hidden.
    ///
    /// - Attention: If you were to make a GUI using the meta model machines,
    /// then you should simply keep these values the same between modifications.
    public var metaData: [AttributeGroup]

    /// Fetches a keypath like structure for use when modifying and validating
    /// properties of machines.
    public var path: Path<MetaMachine, MetaMachine> {
        Path(Self.self)
    }

    /// An attribute type representing the dependency layout.
    public var dependencyAttributeType: AttributeType {
        .complex(layout: [
            "name": .line,
            "filePath": .line,
            "attributes": .complex(layout: mutator.dependencyLayout)
        ])
    }

    /// An array of attributes representing each dependency.
    public var dependencyAttributes: [Attribute] {
        get {
            self.dependencies.map(\.complexAttribute)
        } set {
            self.dependencies = zip(self.dependencies, newValue).map {
                var dep = $0
                dep.complexAttribute = $1
                return dep
            }
        }
    }

    /// Create a new `Machine`.
    ///
    /// Creates a new meta machine model.
    ///
    /// - Parameter semantics: The semantics this meta machine model implements.
    ///
    /// - Parameter initialState: The name of the starting state of the machine
    /// within the `states` array.
    ///
    /// - Parameter states: All states within the machine.
    ///
    /// - Parameter attributes: All attributes of the meta machine that detail
    /// additional fields for custom semantics provided by a particular
    /// scheduler.
    ///
    /// - Parameter metaData: Attributes which should be hidden from the user,
    /// but detail additional field for custom semantics provided by a
    /// particular scheduler.
    public init(
        semantics: Semantics,
        name: String,
        initialState: StateName,
        states: [State] = [],
        dependencies: [MachineDependency] = [],
        attributes: [AttributeGroup],
        metaData: [AttributeGroup]
    ) {
        self.semantics = semantics
        self.name = name
        switch semantics {
        case .vhdl:
            self.mutator = SchemaMutator(
                schema: VHDLSchema(
                    name: name,
                    initialState: initialState,
                    states: states,
                    dependencies: dependencies,
                    attributes: attributes,
                    metaData: metaData
                )
            )
        case .swiftfsm:
            self.mutator = SchemaMutator(
                schema: SwiftfsmSchema(
                    name: name,
                    initialState: initialState,
                    states: states,
                    dependencies: dependencies,
                    attributes: attributes,
                    metaData: metaData
                )
            )
        case .ucfsm, .clfsm, .spartanfsm:
            guard let schema = CXXSchema(semantics: semantics) else {
                fatalError("Tried to create CXXSchema for unsupported semantics")
            }
            self.mutator = SchemaMutator(schema: schema)
        case .other:
            fatalError("Use the mutator constructor if you wish to use an undefined semantics")
        // default:
        //    fatalError("Semantics not supported")
        }
        self.initialState = initialState
        self.states = states
        self.dependencies = dependencies
        self.attributes = attributes
        self.metaData = metaData
    }

    /// Create a new `Machine`.
    ///
    /// Creates a new meta machine model.
    ///
    /// - Parameter semantics: A `MachineMutator` responsible for performing
    /// mutating operations on the machine.
    ///
    /// - Parameter initialState: The name of the starting state of the machine
    /// within the `states` array.
    ///
    /// - Parameter states: All states within the machine.
    ///
    /// - Parameter attributes: All attributes of the meta machine that detail
    /// additional fields for custom semantics provided by a particular
    /// scheduler.
    ///
    /// - Parameter metaData: Attributes which should be hidden from the user,
    /// but detail additional field for custom semantics provided by a
    /// particular scheduler.
    public init(
        semantics: Semantics = .other,
        mutator: Mutator,
        name: String,
        initialState: StateName,
        states: [State] = [],
        dependencies: [MachineDependency] = [],
        attributes: [AttributeGroup],
        metaData: [AttributeGroup]
    ) {
        self.semantics = semantics
        self.mutator = mutator
        self.name = name
        self.initialState = initialState
        self.states = states
        self.dependencies = dependencies
        self.attributes = attributes
        self.metaData = metaData
    }

    /// Setup an initial machine for a specific semantics.
    ///
    /// - Parameter semantics: The semantics which the machine should follow.
    ///
    /// - Warning: The value of `semantics` should exist in the
    /// `supportedSemantics` array.
    public static func initialMachine(
        forSemantics semantics: MetaMachine.Semantics,
        filePath: URL = URL(fileURLWithPath: "/tmp/Untitled.machine", isDirectory: true)
    ) -> MetaMachine {
        switch semantics {
        case .clfsm:
            return CLFSMConverter().initialCLFSMMachine(filePath: filePath)
        case .ucfsm:
            return UCFSMConverter().initialUCFSMMachine(filePath: filePath)
        case .spartanfsm:
            return SpartanFSMConverter().intialSpartanFSMMachine(filePath: filePath)
        case .swiftfsm:
            return SwiftfsmConverter().initialMachine
        case .vhdl:
            return self.initialVHDLMachine(filePath: filePath)
        case .other:
            fatalError("You cannot create an initial machine for an unknown semantics")
        }
    }
    
    /// Add a new item to a table attribute.
    public mutating func addItem<Path: PathProtocol, T>(_ item: T, to attribute: Path) -> Result<Bool, AttributeError<MetaMachine>> where Path.Root == MetaMachine, Path.Value == [T] {
        return perform { machine in
            machine[keyPath: attribute.path].append(item)
            var mutator = machine.mutator
            let result = mutator.didAddItem(item, to: attribute, machine: &machine)
            machine.mutator = mutator
            return result
        }
    }
    
    public mutating func moveItems<Path: PathProtocol, T>(table attribute: Path, from source: IndexSet, to destination: Int) -> Result<Bool, AttributeError<MetaMachine>> where Path.Root == MetaMachine, Path.Value == [T]  {
        return perform { machine in
            let indices = Array(source)
            let items = indices.map { machine[keyPath: attribute.keyPath][$0] }
            machine[keyPath: attribute.path].move(fromOffsets: source, toOffset: destination)
            var mutator = machine.mutator
            let result = mutator.didMoveItems(attribute: attribute, machine: &machine, from: source, to: destination, items: items)
            machine.mutator = mutator
            return result
        }
    }

    /// Create a new dependency for this machine.
    /// - Parameter dependency: The dependency to add to this machine.
    /// - Returns: Whether the dependency was successfully added.
    public mutating func newDependency(
        _ dependency: MachineDependency
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        perform { machine in
            if machine.dependencies.contains(where: { $0.name == dependency.name }) {
                return .failure(AttributeError<MetaMachine>(
                    message: "The dependency '\(dependency.name)' already exists.",
                    path: machine.path.dependencies[machine.dependencies.count]
                ))
            }
            machine.dependencies.append(dependency)
            guard let index = machine.dependencies.firstIndex(where: { $0 == dependency }) else {
                return .failure(AttributeError(
                    message: "Failed to find added dependency", path: MetaMachine.path.dependencies
                ))
            }
            var mutator = machine.mutator
            let result = mutator.didCreateDependency(machine: &machine, dependency: dependency, index: index)
            machine.mutator = mutator
            return result
        }
    }

    /// Add a new empty state to the machine.
    /// - Returns: A `Result` containing a `Bool` indicating whether other data was mutated during this
    /// operation.
    public mutating func newState() -> Result<Bool, AttributeError<MetaMachine>> {
        perform { machine in
            let newName = machine.generateNewStateName()
            let newInitialMachine = MetaMachine.initialMachine(forSemantics: machine.semantics)
            guard let firstState = newInitialMachine.states.first else {
                fatalError("Cannot create new state from blueprint")
            }
            let appendingState = State(
                name: newName,
                actions: firstState.actions,
                transitions: [],
                attributes: firstState.attributes,
                metaData: firstState.metaData
            )
            machine.states.append(appendingState)
            guard
                let newState = machine.states.last, let index = machine.states.lastIndex(of: newState)
            else {
                return .failure(
                    AttributeError(message: "Failed to find added state", path: MetaMachine.path.states)
                )
            }
            var mutator = machine.mutator
            let result = mutator.didCreateNewState(machine: &machine, state: newState, index: index)
            machine.mutator = mutator
            return result
        }
    }

    /// Add a new empty transition to the machine.
    public mutating func newTransition(
        source: StateName, target: StateName, condition: Expression? = nil
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        // swiftlint:disable:next closure_body_length
        perform { machine in
            guard
                let index = machine.states.indices.first(where: { machine.states[$0].name == source }),
                machine.states.contains(where: { $0.name == target })
            else {
                return .failure(
                    ValidationError(
                        message: "You must attach a transition to a source and target state",
                        path: MetaMachine.path
                    )
                )
            }
            let transition = Transition(condition: condition, target: target)
            machine.states[index].transitions.append(transition)
            guard
                let transitionIndex = machine.states[index].transitions.lastIndex(where: {
                    $0 == transition
                })
            else {
                return .failure(
                    AttributeError(
                        message: "Failed to find added transition",
                        path: MetaMachine.path.states[index].transitions
                    )
                )
            }
            var mutator = machine.mutator
            let result = mutator.didCreateNewTransition(
                machine: &machine, transition: transition, stateIndex: index, transitionIndex: transitionIndex
            )
            machine.mutator = mutator
            return result
        }
    }

    /// Delete a specific item in a table attribute.
    public mutating func deleteItem<Path: PathProtocol, T>(table attribute: Path, atIndex index: Int) -> Result<Bool, AttributeError<MetaMachine>> where Path.Root == MetaMachine, Path.Value == [T] {
        return perform { machine in
            if machine[keyPath: attribute.path].count <= index || index < 0 {
                return .failure(ValidationError(message: "Invalid index '\(index)'", path: attribute))
            }
            let item = machine[keyPath: attribute.keyPath][index]
            machine[keyPath: attribute.path].remove(at: index)
            var mutator = machine.mutator
            let result = mutator.didDeleteItem(attribute: attribute, atIndex: index, machine: &machine, item: item)
            machine.mutator = mutator
            return result
        }
    }
    
    public mutating func deleteItems<Path: PathProtocol, T>(table attribute: Path, items: IndexSet) -> Result<Bool, AttributeError<MetaMachine>> where Path.Root == MetaMachine, Path.Value == [T] {
        return perform { machine in
            if machine[keyPath: attribute.path].count <= items.max() ?? -1 || (items.min() ?? -1) < 0 {
                return .failure(ValidationError(message: "Invalid indexes '\(items)'", path: attribute))
            }
            let itemObjs = Array(items).map {
                machine[keyPath: attribute.keyPath][$0]
            }
            Array(items).sorted(by: >).forEach {
                machine[keyPath: attribute.path].remove(at: $0)
            }
            var mutator = machine.mutator
            let result = mutator.didDeleteItems(table: attribute, indices: items, machine: &machine, items: itemObjs)
            machine.mutator = mutator
            return result
        }
    }

    /// Delete multiple dependencies from this machine.
    /// - Parameter dependencies: The indices of the dependencies to delete.
    /// - Returns: A result indicating whether the operation was successful.
    public mutating func delete(dependencies: IndexSet) -> Result<Bool, AttributeError<MetaMachine>> {
        perform { machine in
            let deletedDependencies = machine.dependencies
                .enumerated()
                .filter { dependencies.contains($0.0) }
                .map(\.element)
            machine.dependencies = machine.dependencies
                .enumerated()
                .filter { !dependencies.contains($0.0) }
                .map(\.element)
            var mutator = machine.mutator
            let result = mutator.didDeleteDependencies(
                machine: &machine, dependency: deletedDependencies, at: dependencies
            )
            machine.mutator = mutator
            return result
        }
    }

    /// Delete a set of states and transitions.
    /// - Parameter states: The states to delete.
    /// - Returns: A result indicating whether the operation was successful.
    public mutating func delete(states: IndexSet) -> Result<Bool, AttributeError<MetaMachine>> {
        perform { machine in
            if
                let initialIndex = machine.states.enumerated().first(
                    where: { $0.1.name == machine.initialState }
                )?.0,
                states.contains(initialIndex) {
                return .failure(ValidationError(
                    message: "You cannot delete the initial state",
                    path: MetaMachine.path.states[initialIndex]
                ))
            }
            let deletedStatesArray = machine.states.enumerated().filter { states.contains($0.0) }.map(
                \.element
            )
            let deletedStates = Set(deletedStatesArray.map(\.name))
            machine.states = machine.states.enumerated().filter { !states.contains($0.0) }.map(\.element)
            machine.states = machine.states.map {
                var state = $0
                state.transitions.removeAll { deletedStates.contains($0.target) }
                return state
            }
            var mutator = machine.mutator
            let result = mutator.didDeleteStates(machine: &machine, state: deletedStatesArray, at: states)
            machine.mutator = mutator
            return result
        }
    }

    /// Delete several transitions belonging to a specific state.
    /// - Parameters:
    ///   - transitions: The indices of the transitions to delete.
    ///   - sourceState: The state these transitions are attached to.
    /// - Returns: A result indicating whether the operation was successful.
    public mutating func delete(
        transitions: IndexSet, attachedTo sourceState: StateName
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        perform { machine in
            guard let stateIndex = machine.states.firstIndex(where: { $0.name == sourceState }) else {
                return .failure(ValidationError(
                    message: "Unable to find state with name \(sourceState)", path: MetaMachine.path.states
                ))
            }
            let deletedTransitions = machine.states[stateIndex].transitions
                .enumerated()
                .filter { transitions.contains($0.0) }
                .map { $1 }
            machine.states[stateIndex].transitions = machine.states[stateIndex].transitions
                .enumerated()
                .filter { !transitions.contains($0.0) }
                .map { $1 }
            var mutator = machine.mutator
            let result = mutator.didDeleteTransitions(
                machine: &machine, transition: deletedTransitions, stateIndex: stateIndex, at: transitions
            )
            machine.mutator = mutator
            return result
        }
    }

    /// Delete a dependency from this machine.
    /// - Parameter index: The index of the dependency to delete.
    /// - Returns: A result indicating whether the operation was successful.
    public mutating func deleteDependency(atIndex index: Int) -> Result<Bool, AttributeError<MetaMachine>> {
        perform { machine in
            if index < 0 || index >= machine.dependencies.count {
                return .failure(AttributeError<MetaMachine>(
                    message: "Invalid index \(index) for deleting a dependency.",
                    path: machine.path.dependencies
                ))
            }
            let dependency = machine.dependencies[index]
            machine.dependencies.remove(at: index)
            var mutator = machine.mutator
            let result = mutator.didDeleteDependency(machine: &machine, dependency: dependency, at: index)
            machine.mutator = mutator
            return result
        }
    }

    /// Delete a state at a specific index.
    /// - Parameter index: The index of the state to delete.
    /// - Returns: A result indicating whether the operation was successful.
    public mutating func deleteState(atIndex index: Int) -> Result<Bool, AttributeError<MetaMachine>> {
        perform { machine in
            if index >= machine.states.count {
                return .failure(ValidationError(
                    message: "Can't delete state that doesn't exist", path: MetaMachine.path.states
                ))
            }
            let name = machine.states[index].name
            if name == machine.initialState {
                return .failure(ValidationError(
                    message: "Can't delete the initial state", path: MetaMachine.path.states[index]
                ))
            }
            let state = machine.states[index]
            machine.states.remove(at: index)
            machine.states = machine.states.map {
                var state = $0
                state.transitions.removeAll { $0.target == name }
                return state
            }
            var mutator = machine.mutator
            let result = mutator.didDeleteState(machine: &machine, state: state, at: index)
            machine.mutator = mutator
            return result
        }
    }

    /// Delete a transition at a specific index.
    /// - Parameters:
    ///  - index: The index of the transition to delete.
    ///  - sourceState: The name of the state the transition is attached to.
    /// - Returns: A result indicating whether the operation was successful.
    public mutating func deleteTransition(
        atIndex index: Int, attachedTo sourceState: StateName
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        perform { machine in
            guard let stateIndex = machine.states.indices.first(
                where: { machine.states[$0].name == sourceState }
            ) else {
                return .failure(ValidationError(
                    message: "Cannot delete a transition attached to a state that does not exist",
                    path: MetaMachine.path.states
                ))
            }
            guard machine.states[stateIndex].transitions.count >= index else {
                return .failure(ValidationError(
                    message: "Cannot delete transition that does not exist",
                    path: MetaMachine.path.states[stateIndex].transitions
                ))
            }
            let transition = machine.states[stateIndex].transitions[index]
            machine.states[stateIndex].transitions.remove(at: index)
            var mutator = machine.mutator
            let result = mutator.didDeleteTransition(
                machine: &machine, transition: transition, stateIndex: stateIndex, at: index
            )
            machine.mutator = mutator
            return result
        }
    }

    /// Change a states name to a new name.
    /// - Parameters:
    ///   - index: The index of the state to rename.
    ///   - newName: The new name.
    /// - Returns: A result indicating whether the operation was successful.
    public mutating func changeStateName(
        atIndex index: Int, to newName: String
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        perform { machine in
            guard machine.states.count > index else {
                return .failure(AttributeError(
                    message: "Invalid index \(index) for changing a state name.",
                    path: MetaMachine.path.states[index]
                ))
            }
            let oldName = machine.states[index].name
            if oldName == newName {
                return .success(false)
            }
            if Set(machine.states.map(\.name)).contains(newName) {
                return .failure(AttributeError(
                    message: "Name must be unique.", path: MetaMachine.path.states[index].name
                ))
            }
            if machine.initialState == oldName {
                machine.initialState = newName
            }
            machine.states[index].name = newName
            let state = machine.states[index]
            var mutator = machine.mutator
            let result = mutator.didChangeStatesName(
                machine: &machine, state: state, index: index, oldName: oldName
            )
            machine.mutator = mutator
            return result
        }
    }

    /// Modify a specific attributes value.
    public mutating func modify<Path: PathProtocol>(attribute: Path, value: Path.Value) -> Result<Bool, AttributeError<MetaMachine>> where Path.Root == MetaMachine {
        return perform { machine in
            if let value = value as? String, let stateIndex = machine.states.indices.first(where: {
                (MetaMachine.path.states[$0].name).path == attribute.path
            }) {
                return machine.changeStateName(atIndex: stateIndex, to: value)
            }
            let oldValue = machine[keyPath: attribute.keyPath]
            machine[keyPath: attribute.path] = value
            var mutator = machine.mutator
            let result = mutator.didModify(attribute: attribute, oldValue: oldValue, newValue: value, machine: &machine)
            machine.mutator = mutator
            return result
        }
    }
    
    /// Are there any errors with the machine?
    public func validate() throws {
        try nonMutatingPerform { machine in
            try machine.mutator.validate(machine: machine)
        }
    }
                      
    private func generateNewStateName() -> String {
        let stateNames = Set(states.map(\.name))
        var newName = "State"
        var count = 0
        repeat {
            newName = "State\(count)"
            count += 1
        } while (stateNames.contains(newName))
        return newName
    }
    
    private func nonMutatingPerform(_ f: (MetaMachine) throws -> Void) throws {
        do {
            try f(self)
        } catch let e as AttributeError<MetaMachine> {
            throw e
        } catch let e {
            debugPrint("Unsupported error: \(e)")
            throw e
        }
    }
    
    private mutating func perform(_ f: (inout MetaMachine) throws -> Void) throws {
        let backup = self
        do {
            try f(&self)
            try mutator.validate(machine: self)
            self.errorBag.empty()
        } catch let e as AttributeError<MetaMachine> {
            self = backup
            self.errorBag.remove(includingDescendantsForPath: e.path)
            self.errorBag.insert(e)
            throw e
        } catch let e {
            self = backup
            debugPrint("Unsupported error: \(e)")
            throw e
        }
    }
    
    private func nonMutatingPerform(_ f: (MetaMachine) -> Result<Bool, AttributeError<MetaMachine>>) -> Result<Bool, AttributeError<MetaMachine>> {
        return f(self)
    }
    
    private mutating func perform(_ f: (inout MetaMachine) -> Result<Bool, AttributeError<MetaMachine>>) -> Result<Bool, AttributeError<MetaMachine>> {
        let backup = self
        let result = f(&self)
        switch result {
        case .failure(let e):
            self = backup
            self.errorBag.remove(includingDescendantsForPath: e.path)
            self.errorBag.insert(e)
            return result
        case .success:
            do {
                try mutator.validate(machine: self)
            } catch let e as AttributeError<MetaMachine> {
                self = backup
                self.errorBag.remove(includingDescendantsForPath: e.path)
                self.errorBag.insert(e)
                return .failure(e)
            } catch let e {
                self = backup
                debugPrint("Unsupported error: \(e)")
                return .failure(AttributeError(message: "\(e)", path: AnyPath(MetaMachine.path)))
            }
            self.errorBag.empty()
            return result
        }
    }
    
}

extension MetaMachine {

    public init(filePath: URL) throws {
        let parser = MachineParser()
        guard let machine = parser.parseMachine(atURL: filePath) else {
            throw ConversionError(
                message: parser.lastError ?? "Unable to load machine at path \(filePath.path)",
                path: MetaMachine.path
            )
        }
        self = machine
    }

    public init(from wrapper: FileWrapper) throws {
        let parser = MachineParser()
        guard let machine = parser.parseMachine(fromWrapper: wrapper) else {
            throw ConversionError(
                message: parser.lastError ?? "Unable to load machine", path: MetaMachine.path
            )
        }
        self = machine
    }

    public func fileWrapper() throws -> FileWrapper {
        let generator = MachineGenerator()
        guard let fileWrapper = generator.generate(self) else {
            throw ConversionError(
                message: generator.lastError ?? "Unable to create machine", path: MetaMachine.path
            )
        }
        return fileWrapper
    }

    public func save() throws {
        try self.validate()
        let generator = MachineGenerator()
        guard nil != generator.generate(self) else {
            throw ConversionError(message: generator.lastError ?? "Unable to save machine", path: MetaMachine.path)
        }
    }
    
}

extension MetaMachine: Equatable {

    public static func == (lhs: MetaMachine, rhs: MetaMachine) -> Bool {
        lhs.semantics == rhs.semantics
            && lhs.name == rhs.name
            && lhs.initialState == rhs.initialState
            && lhs.states == rhs.states
            && lhs.attributes == rhs.attributes
            && lhs.metaData == rhs.metaData
    }

}

extension MetaMachine: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.semantics)
        hasher.combine(self.name)
        hasher.combine(self.initialState)
        hasher.combine(self.states)
        hasher.combine(self.attributes)
        hasher.combine(self.metaData)
    }

}

extension MetaMachine: Codable {

    public enum CodingKeys: CodingKey {

        case semantics
        case name
        case initialState
        case states
        case transitions
        case attributes
        case metaData

    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let semantics = try container.decode(Semantics.self, forKey: .semantics)
        let name = try container.decode(String.self, forKey: .name)
        let initialState = try container.decode(StateName.self, forKey: .initialState)
        let states = try container.decode([State].self, forKey: .states)
        let attributes = try container.decode([AttributeGroup].self, forKey: .attributes)
        let metaData = try container.decode([AttributeGroup].self, forKey: .metaData)
        self.init(
            semantics: semantics,
            name: name,
            initialState: initialState,
            states: states,
            attributes: attributes,
            metaData: metaData
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.semantics, forKey: .semantics)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.initialState, forKey: .initialState)
        try container.encode(self.states, forKey: .states)
        try container.encode(self.attributes, forKey: .attributes)
        try container.encode(self.metaData, forKey: .metaData)
    }

}

extension MetaMachine {

    var vhdlSchema: VHDLSchema? {
        get {
            (self.mutator as? SchemaMutator<VHDLSchema>)?.schema
        }
        set {
            guard let newValue = newValue else {
                return
            }
            self.mutator = SchemaMutator(schema: newValue)
        }
    }

}
