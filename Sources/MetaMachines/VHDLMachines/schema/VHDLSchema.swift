//
//  File.swift
//  
//
//  Created by Morgan McColl on 7/6/21.
//

import Attributes
import Foundation
import VHDLMachines

/// The schema for VHDL machines.
struct VHDLSchema: MachineSchema {

    /// The layout of dependencies to this machine.
    var dependencyLayout: [Field]

    /// The schema for states.
    var stateSchema: VHDLStateSchema

    /// The schema for transitions.
    var transitionSchema: VHDLTransitionsSchema

    /// The machine variables.
    @Group
    var variables: VHDLVariablesGroup

    /// The machine parameters (for parameterised machines).
    @Group
    var parameters: VHDLParametersGroup

    /// The includes of the machine. This group handles the library dependencies of a VHDL machine.
    @Group
    var includes: VHDLIncludes

    /// The settings of the machine. This group includes the settings for defining the initial and suspended
    /// state.
    @Group
    var settings: VHDLSettings

    /// Create a new `VHDLSchema`.
    /// - Parameters:
    ///   - name: The name of the machine.
    ///   - initialState: The name of the initial state.
    ///   - states: The states of the machine.
    ///   - dependencies: The dependencies of the machine.
    ///   - attributes: The attributes of the machine. The attributes must have been created in accordance
    /// with the structure of this schema. This initialiser assumes that this has already been done and will
    /// cause runtime crashes if this is not the case.
    ///   - metaData: The metadata of the machine.
    /// - Note: This initialiser will mutate the schema to match the currently available attributes within
    /// the machine. This will include dictating the valid values for the initial and suspended states, as
    /// well as other properties that are dynamic in nature.
    /// - Warning: Make sure your attributes are consistent with the definition of this schema. You may have
    /// differing values, but the attributes must all be present. This schema will try and update itself with
    /// the current values in the attributes of the machine.
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
        let clocks: [String]
        if attributes.isEmpty {
            externals = []
            clocks = []
        } else {
            externals = attributes[0].attributes["external_signals"]?.tableValue.map {
                $0[2].lineValue
            } ?? []
            clocks = (attributes[0].attributes["clocks"]?.tableValue.compactMap {
                $0.first?.lineValue
            }) ?? []
        }
        self.variables.$drivingClock = EnumeratedProperty(label: "driving_clock", validValues: Set(clocks)) {
            $0.notEmpty()
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

    /// Create a new `VHDLSchema` with stored data. This initialiser simply sets the stored properties with
    /// the given values.
    /// - Parameters:
    ///   - dependencyLayout: The layout of dependencies to the VHDL machine.
    ///   - stateSchema: The state schema.
    ///   - transitionSchema: The transition schema.
    ///   - variables: The variables group.
    ///   - parameters: The parameters group.
    ///   - includes: The includes group.
    ///   - settings: The settings group.
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

    /// Initiate some triggers in response to the creation of a new state.
    /// - Parameters:
    ///   - machine: The machine containing the new state.
    ///   - state: The new state.
    ///   - index: The index of the new state.
    /// - Returns: Whether the triggers caused additional changes to the machine.
    func didCreateNewState(
        machine: inout MetaMachine, state: State, index: Int
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        let path = AnyPath(Path(MetaMachine.self).states[index])
        guard !path.isNil(machine) else {
            return .failure(AttributeError(message: "State does not exist!", path: path))
        }
        machine.states[index].attributes = VHDLMachines.State.defaultAttributes(in: machine)
        return statesTrigger(machine: &machine)
    }

    /// Initiate some triggers in response to the mutation of a states name.
    /// - Parameters:
    ///   - machine: The machine containing the state.
    ///   - state: The state that was mutated.
    ///   - index: The index of the state.
    ///   - oldName: The old name of the state.
    /// - Returns: Whether the triggers caused additional changes to the machine.
    func didChangeStatesName(
        machine: inout MetaMachine, state: State, index: Int, oldName: String
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        let path = AnyPath(Path(MetaMachine.self).states[index].name)
        guard self.trigger.isTriggerForPath(path, in: machine) else {
            return .success(false)
        }
        return self.trigger.performTrigger(&machine, for: path)
    }

    /// Initiate some triggers in response to the deletion of a state.
    /// - Parameters:
    ///   - machine: The machine the state was deleted from.
    ///   - state: The state that was deleted.
    ///   - at: The index of the state.
    /// - Returns: Whether the triggers caused additional changes to the machine.
    func didDeleteState(
        machine: inout MetaMachine, state: State, at: Int
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        statesTrigger(machine: &machine)
    }

    /// Initiate some triggers in response to the deletion of multiple states.
    /// - Parameters:
    ///   - machine: The machine the states were deleted from.
    ///   - state: The states that were deleted.
    ///   - at: The indices of the states.
    /// - Returns: Whether the triggers caused additional changes to the machine.
    func didDeleteStates(
        machine: inout MetaMachine, state: [State], at: IndexSet
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        statesTrigger(machine: &machine)
    }

    /// Update the schema with the changes in the meta machine.
    /// - Parameter metaMachine: The meta machine containing the changes.
    mutating func update(from metaMachine: MetaMachine) {
        self = metaMachine.vhdlSchema.wrappedValue
    }

    /// Initiates a trigger when the states array in the machine is modified.
    /// - Parameter machine: The machine containing the states.
    /// - Returns: Whether the triggers caused additional changes to the machine.
    private func statesTrigger(machine: inout MetaMachine) -> Result<Bool, AttributeError<MetaMachine>> {
        let path = AnyPath(Path(MetaMachine.self).states)
        guard self.trigger.isTriggerForPath(path, in: machine) else {
            return .success(false)
        }
        return self.trigger.performTrigger(&machine, for: path)
    }

}
