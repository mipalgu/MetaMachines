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
public struct Machine: PathContainer {
    
    public enum Semantics: String, Hashable, Codable, CaseIterable {
        case other
        case swiftfsm
        case clfsm
        case vhdl
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
    public static var supportedSemantics: [Machine.Semantics] {
        return Machine.Semantics.allCases.filter { $0 != .other }
    }
    
    private let mutator: MachineMutator
    
    /// The underlying semantics which this meta machine follows.
    public internal(set) var semantics: Semantics
    
    /// The name of the machine.
    public var name: String {
        return self.filePath.lastPathComponent.components(separatedBy: ".")[0]
    }
    
    /// The path to the .machine directory on the file system.
    public internal(set) var filePath: URL
    
    /// The name of the initial state.
    ///
    /// The name should represent the name of a state within the `states` array.
    public internal(set) var initialState: StateName
    
    /// The accepting states of the machine.
    ///
    /// An accepting state is a state without any transitions.
    ///
    /// - Complexity: O(n * m) where n is the length of the `states` array and
    /// m is the length of the `transitions` array.
    public var acceptingStates: [State] {
        return self.states.filter { state in
            nil != self.transitions.first { $0.source == state.name }
        }
    }
    
    /// All states within the machine.
    public internal(set) var states: [State]
    
    /// All transitions within the machine --- attached or unattached to states.
    public internal(set) var transitions: [Transition]
    
    /// A list of attributes specifying additional fields that can change.
    ///
    /// The attribute list usually details extra fields necessary for additional
    /// semantics not covered in the general meta machine model. The meta
    /// machine model takes a minimalistic point of view where the meta model
    /// represents the common semantics between different schedulers
    /// (swiftfsm, clfsm for example). Obviously each scheduler has a different
    /// feature set. The features which are not common between schedulers
    /// should be facilitated through this attributes field.
    public internal(set) var attributes: [AttributeGroup]
    
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
    public internal(set) var metaData: [AttributeGroup]
    
    /// Fetches a keypath like structure for use when modifying and validating
    /// properties of machines.
    public var path: Path<Machine, Machine> {
        return Path(path: \.self, ancestors: [])
    }
    
    /// Fetches a keypath like structure for use when modifying and validating
    /// properties of machines.
    public static var path: Path<Machine, Machine> {
        return Path(path: \Machine.self, ancestors: [])
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
    /// - Parameter transitions: All transitions within the machine, even those
    /// that aren't attached to states.
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
        filePath: URL,
        initialState: StateName,
        states: [State] = [],
        transitions: [Transition] = [],
        attributes: [AttributeGroup],
        metaData: [AttributeGroup]
    ) {
        self.semantics = semantics
        switch semantics {
        case .clfsm:
            fatalError("clfsm semantics are not yet implemented.")
        case .swiftfsm:
            self.mutator = SwiftfsmConverter()
        case .vhdl:
            fatalError("vhdl semantics are not yet implemented.")
        case .other:
            fatalError("Use the mutator constructor if you wish to use an undefined semantics")
        }
        self.filePath = filePath
        self.initialState = initialState
        self.states = states
        self.transitions = transitions
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
    /// - Parameter transitions: All transitions within the machine, even those
    /// that aren't attached to states.
    ///
    /// - Parameter attributes: All attributes of the meta machine that detail
    /// additional fields for custom semantics provided by a particular
    /// scheduler.
    ///
    /// - Parameter metaData: Attributes which should be hidden from the user,
    /// but detail additional field for custom semantics provided by a
    /// particular scheduler.
    public init(
        mutator: MachineMutator,
        filePath: URL,
        initialState: StateName,
        states: [State] = [],
        transitions: [Transition] = [],
        attributes: [AttributeGroup],
        metaData: [AttributeGroup]
    ) {
        self.semantics = .other
        self.mutator = mutator
        self.filePath = filePath
        self.initialState = initialState
        self.states = states
        self.transitions = transitions
        self.attributes = attributes
        self.metaData = metaData
    }
    
    /// Setup an initial machine for a specific semantics.
    ///
    /// - Parameter semantics: The semantics which the machine should follow.
    ///
    /// - Warning: The value of `semantics` should exist in the
    /// `supportedSemantics` array.
    public static func initialMachine(forSemantics semantics: Machine.Semantics) -> Machine {
        switch semantics {
        case .clfsm:
            fatalError("clfsm semantics have not been implemented")
        case .swiftfsm:
            return SwiftfsmConverter().initial
        case .vhdl:
            fatalError("vhdl semantics have not been implemented")
        case .other:
            fatalError("You cannot create an initial machine for an unknown semantics")
        }
    }
    
    /// Add a new item to a table attribute.
    public mutating func addItem<Path: PathProtocol>(table attribute: Path) throws where Path.Root == Machine {
        try perform { [mutator] machine in
            try mutator.addItem(attribute: attribute, machine: &machine)
        }
    }
    
    /// Add a new empty state to the machine.
    public mutating func newState() throws {
        try perform { [mutator] machine in
            try mutator.newState(machine: &machine)
        }
    }
    
    /// Add a new empty transition to the machine.
    public mutating func newTransition(source: StateName, target: StateName, condition: Expression? = nil) throws {
        try perform { [mutator] machine in
            try mutator.newTransition(source: source, target: target, condition: condition, machine: &machine)
        }
    }
    
    /// Delete a specific item in a table attribute.
    public mutating func deleteItem<Path: PathProtocol>(table attribute: Path) throws where Path.Root == Machine {
        try perform { [mutator] machine in
            try mutator.deleteItem(attribute: attribute, machine: &machine)
        }
    }
    
    /// Delete a set of states and transitions.
    public mutating func delete(states: IndexSet, transitions: IndexSet) throws {
        try perform { [mutator] machine in
            try mutator.delete(states: states, transitions: transitions, machine: &machine)
        }
    }
    
    /// Delete a state at a specific index.
    public mutating func deleteState(atIndex index: Int) throws {
        try perform { [mutator] machine in
            try mutator.deleteState(atIndex: index, machine: &machine)
        }
    }
    
    /// Delete a transition at a specific index.
    public mutating func deleteTransition(atIndex index: Int) throws {
        try perform { [mutator] machine in
            try mutator.deleteTransition(atIndex: index, machine: &machine)
        }
    }
    
    /// Modify a specific attributes value.
    public mutating func modify<Path: PathProtocol>(attribute: Path, value: Path.Value) throws where Path.Root == Machine {
        try perform { [mutator] machine in
            try mutator.modify(attribute: attribute, value: value, machine: &machine)
        }
    }
    
    /// Are there any errors with the machine?
    public func validate() throws {
        try perform { machine in
            try self.mutator.validate(machine: machine)
        }
    }
    
    private func perform(_ f: (Machine) throws -> Void) throws {
        do {
            try f(self)
        } catch let e as ConversionError {
            throw MachinesError.conversionError(e)
        } catch let e as ValidationError<Machine> {
            throw MachinesError.validationError(e)
        } catch let e as MachinesError {
            throw e
        } catch let e {
            fatalError("Unsupported error: \(e)")
        }
    }
    
    private mutating func perform(_ f: (inout Machine) throws -> Void) throws {
        do {
            try f(&self)
        } catch let e as ConversionError {
            throw MachinesError.conversionError(e)
        } catch let e as ValidationError<Machine> {
            throw MachinesError.validationError(e)
        } catch let e as MachinesError {
            throw e
        } catch let e {
            fatalError("Unsupported error: \(e)")
        }
    }
    
}

extension Machine: Equatable {
    
    public static func == (lhs: Machine, rhs: Machine) -> Bool {
        return lhs.semantics == rhs.semantics
            && lhs.filePath == rhs.filePath
            && lhs.initialState == rhs.initialState
            && lhs.states == rhs.states
            && lhs.transitions == rhs.transitions
            && lhs.attributes == rhs.attributes
            && lhs.metaData == rhs.metaData
    }
    
}

extension Machine: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.semantics)
        hasher.combine(self.filePath)
        hasher.combine(self.initialState)
        hasher.combine(self.states)
        hasher.combine(self.transitions)
        hasher.combine(self.attributes)
        hasher.combine(self.metaData)
    }
    
}

extension Machine: Codable {
    
    public enum CodingKeys: CodingKey {
        
        case semantics
        case filePath
        case initialState
        case states
        case transitions
        case attributes
        case metaData
        
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let semantics = try container.decode(Semantics.self, forKey: .semantics)
        let filePath = try container.decode(URL.self, forKey: .filePath)
        let initialState = try container.decode(StateName.self, forKey: .initialState)
        let states = try container.decode([State].self, forKey: .states)
        let transitions = try container.decode([Transition].self, forKey: .transitions)
        let attributes = try container.decode([AttributeGroup].self, forKey: .attributes)
        let metaData = try container.decode([AttributeGroup].self, forKey: .metaData)
        self.init(
            semantics: semantics,
            filePath: filePath,
            initialState: initialState,
            states: states,
            transitions: transitions,
            attributes: attributes,
            metaData: metaData
        )
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.semantics, forKey: .semantics)
        try container.encode(self.filePath, forKey: .filePath)
        try container.encode(self.initialState, forKey: .initialState)
        try container.encode(self.states, forKey: .states)
        try container.encode(self.transitions, forKey: .transitions)
        try container.encode(self.attributes, forKey: .attributes)
        try container.encode(self.metaData, forKey: .metaData)
    }
    
}
