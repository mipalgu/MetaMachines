//
//  File.swift
//  
//
//  Created by Morgan McColl on 23/7/21.
//

import Attributes
import Foundation

/// A group for additional machine settings. This group specifies the initial and suspended state of the
/// machine.
struct VHDLSettings: GroupProtocol {

    /// The root is a ``MetaMachine``.
    typealias Root = MetaMachine

    /// The path to the group containing these settings.
    let path = MetaMachine.path.attributes[3]

    /// A property for setting the suspended state of the machine.
    @EnumeratedProperty(
        label: "suspended_state",
        validValues: []
    )
    var suspendedState

    /// A property for setting the initial state of the machine.
    @EnumeratedProperty(
        label: "initial_state",
        validValues: [],
        validation: { $0.notEmpty() }
    )
    var initialState

    /// Triggers that update initial and suspended state settings when new states are added.
    @TriggerBuilder<MetaMachine>
    var triggers: AnyTrigger<MetaMachine> {
        // swiftlint:disable closure_body_length
        Attributes.ForEach(CollectionSearchPath(
            collectionPath: Path(MetaMachine.self).states, elementPath: Path(State.self).name
        )) { namePath in
            Attributes.WhenChanged(namePath).custom { machine in
                let stateNamesArray = machine.states.map(\.name)
                let stateNames = Set(stateNamesArray)
                let suspendedNames = Set(stateNamesArray + [""])
                guard
                    !namePath.isNil(machine),
                    machine.attributes.count >= 4,
                    let initialState = machine.attributes[3].attributes["initial_state"],
                    let suspendedState = machine.attributes[3].attributes["suspended_state"],
                    var schema = machine.vhdlSchema
                else {
                    return .failure(AttributeError(message: "Cannot find attributes.", path: namePath))
                }
                let newName = machine[keyPath: namePath.keyPath]
                let oldInitial = initialState.enumeratedValue
                let newInitial = stateNames.contains(oldInitial) ? oldInitial : newName
                machine.attributes[3].attributes["initial_state"] = .enumerated(
                    newInitial, validValues: stateNames
                )
                let oldSuspended = suspendedState.enumeratedValue
                let newSuspended = suspendedNames.contains(oldSuspended) ? oldSuspended : newName
                machine.attributes[3].attributes["suspended_state"] = .enumerated(
                    newSuspended, validValues: suspendedNames
                )
                if let initialFieldIndex = machine.attributes[3].fields.firstIndex(
                    where: { $0.name == "initial_state" }
                ) {
                    machine.attributes[3].fields[initialFieldIndex] = Field(
                        name: "initial_state", type: .enumerated(validValues: stateNames)
                    )
                }
                if let suspendedFieldIndex = machine.attributes[3].fields.firstIndex(
                    where: { $0.name == "suspended_state" }
                ) {
                    machine.attributes[3].fields[suspendedFieldIndex] = Field(
                        name: "suspended_state", type: .enumerated(validValues: suspendedNames)
                    )
                }
                schema.settings.$initialState = EnumeratedProperty(
                    label: "initial_state",
                    validValues: stateNames
                ) {
                    $0.notEmpty()
                }
                schema.settings.$suspendedState = EnumeratedProperty(
                    label: "suspended_state",
                    validValues: suspendedNames
                )
                machine.vhdlSchema = schema
                return .success(true)
            }
        }
        // swiftlint:enable closure_body_length
        Attributes.WhenChanged(Path(MetaMachine.self).states).sync(
            target: self.path(for: initialState)
        ) { states, oldValue in
            let oldName = oldValue.enumeratedValue
            let newValidValues = Set(states.map(\.name))
            let newName = newValidValues.contains(oldName) ? oldName : newValidValues.min() ?? ""
            return Attribute.enumerated(newName, validValues: newValidValues)
        }
        Attributes.WhenChanged(Path(MetaMachine.self).states).sync(
            target: self.path.fields
        ) { states, oldFields in
            guard let initialField = (oldFields.first { $0.name == "initial_state" }) else {
                return oldFields
            }
            let newValidValues = Set(states.map(\.name))
            let newFields = oldFields.drop { $0 == initialField }
            return newFields + [
                Field(name: initialField.name, type: .enumerated(validValues: newValidValues))
            ].sorted { $0.name < $1.name }
        }
        Attributes.WhenChanged(Path(MetaMachine.self).states).sync(
            target: self.path.fields
        ) { states, oldFields in
            guard let suspendedField = (oldFields.first { $0.name == "suspended_state" }) else {
                return oldFields
            }
            let newValidValues = Set(states.map(\.name) + [""])
            let newFields = oldFields.drop { $0 == suspendedField }
            return newFields + [
                Field(name: suspendedField.name, type: .enumerated(validValues: newValidValues))
            ].sorted { $0.name < $1.name }
        }
        Attributes.WhenChanged(Path(MetaMachine.self).states).sync(
            target: Path(MetaMachine.self).vhdlSchema.wrappedValue.settings.$initialState
        ) { states, _ in
            let newValidValues = Set(states.map(\.name))
            return EnumeratedProperty(label: "initial_state", validValues: newValidValues) { $0.notEmpty() }
        }
        Attributes.WhenChanged(Path(MetaMachine.self).states).sync(
            target: self.path(for: suspendedState)
        ) { states, oldValue in
            let oldName = oldValue.enumeratedValue
            let newValidValues = Set(states.map(\.name) + [""])
            let newName = newValidValues.contains(oldName) ? oldName : ""
            return Attribute.enumerated(newName, validValues: newValidValues)
        }
        Attributes.WhenChanged(Path(MetaMachine.self).states).sync(
            target: Path(MetaMachine.self).vhdlSchema.wrappedValue.settings.$suspendedState
        ) { states, _ in
            let newValidValues = Set(states.map(\.name) + [""])
            return EnumeratedProperty(label: "suspended_state", validValues: newValidValues)
        }
    }

}
