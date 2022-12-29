//
//  File.swift
//  
//
//  Created by Morgan McColl on 7/6/21.
//

import Attributes
import Foundation

struct VHDLSchema: MachineSchema {

    var dependencyLayout: [Field]

    var stateSchema: VHDLStateSchema

    var transitionSchema: VHDLTransitionsSchema

    @Group
    var variables: VHDLVariablesGroup

    @Group
    var parameters: VHDLParametersGroup

    @Group
    var includes: VHDLIncludes

    @Group
    var settings: VHDLSettings

    init(
        name: String,
        initialState: StateName,
        states: [State],
        dependencies: [MachineDependency],
        attributes: [AttributeGroup],
        metaData: [AttributeGroup]
    ) {
        self.init()
        let stateNames = Set(states.map(\.name))
        self.settings.$initialState.update(validValues: stateNames) { $0.notEmpty() }
        self.settings.$suspendedState.update(validValues: stateNames)
        let externals: [String]
        if attributes.isEmpty {
            externals = []
        } else {
            externals = attributes[0].attributes["external_signals"]?.tableValue.map {
                $0[2].lineValue
            } ?? []
        }
        self.stateSchema.variables.$externals.update(validValues: Set(externals))
        let stateActions = states.first?.actions.map(\.name) ??
            ["OnEntry", "OnExit", "Internal", "OnSuspend", "OnResume"]
        self.stateSchema.actions.$actionOrder.update(
            columns: [
                .integer(label: "timeslot", validation: .required().between(min: 0, max: 255)),
                .enumerated(label: "action", validValues: Set(stateActions), validation: .required())
            ]
        ) { table in
            table.notEmpty()
        }
    }

    init(
        dependencyLayout: [Field] = [],
        stateSchema: VHDLStateSchema = VHDLStateSchema(),
        transitionSchema: VHDLTransitionsSchema = VHDLTransitionsSchema(),
        variables: VHDLVariablesGroup = VHDLVariablesGroup(),
        parameters: VHDLParametersGroup = VHDLParametersGroup(),
        includes: VHDLIncludes = VHDLIncludes(),
        settings: VHDLSettings = VHDLSettings()
    ) {
        self.dependencyLayout = dependencyLayout
        self.stateSchema = stateSchema
        self.transitionSchema = transitionSchema
        self.variables = variables
        self.parameters = parameters
        self.includes = includes
        self.settings = settings
    }

    func didChangeStatesName(
        machine: inout MetaMachine, state: State, index: Int, oldName: String
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        let result1 = updateSettingsStateName(
            machine: &machine, state: state, oldName: oldName, property: settings.initialState.label
        )
        let result2 = updateSettingsStateName(
            machine: &machine, state: state, oldName: oldName, property: settings.suspendedState.label
        )
        if case .failure = result1 {
            return result1
        }
        if case .failure = result2 {
            return result2
        }
        return .success(true)
    }

    func didCreateNewState(
        machine: inout MetaMachine, state: State, index: Int
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        let result1 = addState(machine: &machine, state: state, for: settings.initialState.label)
        let result2 = addState(machine: &machine, state: state, for: settings.suspendedState.label)
        if case .failure = result1 {
            return result1
        }
        if case .failure = result2 {
            return result2
        }
        return .success(true)
    }

    func didDeleteState(
        machine: inout MetaMachine, state: State, at: Int
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        let result1 = deleteState(machine: &machine, state: state, for: settings.initialState.label)
        let result2 = deleteState(machine: &machine, state: state, for: settings.suspendedState.label)
        if case .failure = result1 {
            return result1
        }
        if case .failure = result2 {
            return result2
        }
        return .success(true)
    }

    func didDeleteStates(
        machine: inout MetaMachine, state: [State], at: IndexSet
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        let result1 = deleteStates(machine: &machine, states: state, for: settings.initialState.label)
        let result2 = deleteStates(machine: &machine, states: state, for: settings.suspendedState.label)
        if case .failure = result1 {
            return result1
        }
        if case .failure = result2 {
            return result2
        }
        return .success(true)
    }

    private func deleteStates(
        machine: inout MetaMachine, states: [State], for key: String
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        let validValuePath = attributePath(for: key).enumeratedValidValues.changeRoot(path: settings.path)
        guard !validValuePath.isNil(machine) else {
            return .failure(AttributeError(message: "Path is nil", path: validValuePath))
        }
        var validValues = machine[keyPath: validValuePath.keyPath]
        let stateNames = Set(states.map(\.name))
        validValues.subtract(stateNames)
        let result = machine.modify(attribute: validValuePath, value: validValues)
        guard case .success = result else {
            return result
        }
        let valuePath = attributePath(for: key).enumeratedValue.changeRoot(path: settings.path)
        guard !valuePath.isNil(machine) else {
            return .failure(AttributeError(message: "Path is nil", path: valuePath))
        }
        let value = machine[keyPath: valuePath.keyPath]
        if stateNames.contains(value) {
            return machine.modify(attribute: valuePath, value: validValues.first ?? "")
        }
        return .success(true)
    }

    private func deleteState(
        machine: inout MetaMachine, state: State, for key: String
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        let validValuePath = attributePath(for: key).enumeratedValidValues.changeRoot(path: settings.path)
        guard !validValuePath.isNil(machine) else {
            return .failure(AttributeError(message: "Path is nil", path: validValuePath))
        }
        var validValues = machine[keyPath: validValuePath.keyPath]
        validValues.remove(state.name)
        let result = machine.modify(attribute: validValuePath, value: validValues)
        guard case .success = result else {
            return result
        }
        let valuePath = attributePath(for: key).enumeratedValue.changeRoot(path: settings.path)
        guard !valuePath.isNil(machine) else {
            return .failure(AttributeError(message: "Path is nil", path: valuePath))
        }
        let value = machine[keyPath: valuePath.keyPath]
        if value == state.name {
            return machine.modify(attribute: valuePath, value: validValues.first ?? "")
        }
        return .success(true)
    }

    private func addState(
        machine: inout MetaMachine, state: State, for key: String
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        let validValuePath = attributePath(for: key).enumeratedValidValues.changeRoot(path: settings.path)
        guard !validValuePath.isNil(machine) else {
            return .failure(AttributeError(message: "Path is nil", path: validValuePath))
        }
        var validValues = machine[keyPath: validValuePath.keyPath]
        validValues.insert(state.name)
        return machine.modify(attribute: validValuePath, value: validValues)
    }

    private func attributePath(for key: String) -> Path<AttributeGroup, Attribute> {
        settings.pathToAttributes[key].wrappedValue
    }

    private func updateSettingsStateName(
        machine: inout MetaMachine, state: State, oldName: String, property key: String
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        let attributePath = attributePath(for: key)
        let currentInitialStatePath = attributePath.enumeratedValue.changeRoot(path: settings.path)
        let validValuesPath = attributePath.enumeratedValidValues.changeRoot(path: settings.path)
        guard !currentInitialStatePath.isNil(machine) else {
            return .failure(AttributeError(message: "Path is nil", path: currentInitialStatePath))
        }
        guard !validValuesPath.isNil(machine) else {
            return .failure(AttributeError(message: "Path is nil", path: validValuesPath))
        }
        var validValues = machine[keyPath: validValuesPath.keyPath]
        validValues.remove(oldName)
        validValues.insert(state.name)
        let result = machine.modify(attribute: validValuesPath, value: validValues)
        guard case .success = result else {
            return result
        }
        let currentInitialState = machine[keyPath: currentInitialStatePath.keyPath]
        if currentInitialState == oldName {
            let result = machine.modify(attribute: currentInitialStatePath, value: state.name)
            guard case .success = result else {
                return result
            }
        }
        return .success(true)
    }

}
