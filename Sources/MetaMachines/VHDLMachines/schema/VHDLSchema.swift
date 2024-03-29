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

    /// The paths to the machine variable names.
    private var namePaths: [CollectionSearchPath<MetaMachine, [[LineAttribute]], LineAttribute>] {
        [
            CollectionSearchPath(
                collectionPath: variables.path.attributes["clocks"].wrappedValue.tableValue,
                elementPath: Path([LineAttribute].self)[0]
            ),
            CollectionSearchPath(
                collectionPath: variables.path.attributes["external_signals"].wrappedValue.tableValue,
                elementPath: Path([LineAttribute].self)[2]
            ),
            CollectionSearchPath(
                collectionPath: variables.path.attributes["generics"].wrappedValue.tableValue,
                elementPath: Path([LineAttribute].self)[3]
            ),
            CollectionSearchPath(
                collectionPath: variables.path.attributes["machine_variables"].wrappedValue.tableValue,
                elementPath: Path([LineAttribute].self)[3]
            ),
            CollectionSearchPath(
                collectionPath: variables.path.attributes["machine_signals"].wrappedValue.tableValue,
                elementPath: Path([LineAttribute].self)[1]
            ),
            CollectionSearchPath(
                collectionPath: parameters.path.attributes["parameter_signals"].wrappedValue.tableValue,
                elementPath: Path([LineAttribute].self)[1]
            ),
            CollectionSearchPath(
                collectionPath: parameters.path.attributes["returnable_signals"].wrappedValue.tableValue,
                elementPath: Path([LineAttribute].self)[1]
            )
        ]
    }

    /// A validator that ensures all variables names are unique.
    private var uniqueValidator: AnyValidator<MetaMachine> {
        AnyValidator<MetaMachine> { machine in
            try self.names(in: machine)
        }
    }

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
        let stateNames = states.map(\.name)
        self.settings.$initialState.update(validValues: Set(stateNames)) { $0.notEmpty() }
        self.settings.$suspendedState.update(validValues: Set(stateNames + [""]))
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
            table.notEmpty().maxLength(128)
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

    /// Make the validator for the meta machine.
    /// - Parameter root: The meta machine to validate.
    /// - Returns: The validator that validates the meta machine.
    func makeValidator(root: MetaMachine) -> AnyValidator<MetaMachine> {
        let groups: [AnyGroup<Root>] = self.groups
        return AnyValidator([
            AnyValidator(groups.enumerated().map { groupIndex, group in
                let path: ReadOnlyPath<Root, AttributeGroup> = Root.path.attributes[groupIndex]
                let propertiesValidator = AnyValidator<MetaMachine> {
                    try chainValidator(in: $0, path: path, validator: group.propertiesValidator)
                }
                let groupValidator = AnyValidator<MetaMachine> {
                    try chainValidator(in: $0, path: path, validator: group.groupValidation)
                }
                let rootValidator = group.rootValidation
                return AnyValidator([AnyValidator([propertiesValidator, groupValidator]), rootValidator])
            }),
            AnyValidator(self.uniqueValidator)
        ])
    }

    /// Update the schema with the changes in the meta machine.
    /// - Parameter metaMachine: The meta machine containing the changes.
    mutating func update(from metaMachine: MetaMachine) {
        self = metaMachine.vhdlSchema.wrappedValue
    }

    /// Create a validator that is similar to a `ChainValidator` from `Attributes`.
    /// - Parameters:
    ///   - root: The machine to validate.
    ///   - path: The path of the group to validate.
    ///   - validator: The validator that works on that group.
    /// - Throws: A `ValidationError`.
    private func chainValidator(
        in root: MetaMachine,
        path: ReadOnlyPath<VHDLSchema.Root, AttributeGroup>,
        validator: AnyValidator<AttributeGroup>
    ) throws {
        guard !path.isNil(root) else {
            throw ValidationError(message: "Path is nil!", path: path)
        }
        let machineGroup = root[keyPath: path.keyPath]
        do {
            try validator.performValidation(machineGroup)
        } catch let e as AttributeError<AttributeGroup> {
            // swiftlint:disable:next force_unwrapping
            throw ValidationError(message: e.message, path: AnyPath(path).appending(e.path)!)
        }
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

    /// Verify that all variables names within a meta machine are unique.
    /// - Parameter root: The meta machine containing the variables.
    /// - Throws: ``ValidationError``.
    private func names(in root: MetaMachine) throws {
        let paths = namePaths + stateNamePaths(in: root)
        try paths.forEach {
            var names: Set<LineAttribute> = []
            try $0.paths(in: root).forEach {
                let name = root[keyPath: $0.keyPath]
                if names.contains(name) {
                    throw ValidationError(message: "All variable names must be unique", path: $0)
                }
                names.insert(name)
            }
        }
    }

    /// Get the paths for the names of the variables and actions within a state.
    /// - Parameter root: The object containing the variables of interest.
    /// - Returns: The paths.
    private func stateNamePaths(
        in root: MetaMachine
    ) -> [CollectionSearchPath<MetaMachine, [[LineAttribute]], LineAttribute>] {
        stateSchema.variables.path.paths(in: root).flatMap { variablePath in
            [
                CollectionSearchPath(
                    collectionPath: variablePath.attributes["state_signals"].wrappedValue.tableValue,
                    elementPath: Path([LineAttribute].self)[1]
                ),
                CollectionSearchPath(
                    collectionPath: variablePath.attributes["state_variables"].wrappedValue.tableValue,
                    elementPath: Path([LineAttribute].self)[3]
                )
            ]
        } + stateSchema.actions.path.paths(in: root).flatMap { actionPath in
            [
                CollectionSearchPath(
                    collectionPath: actionPath.attributes["action_names"].wrappedValue.tableValue,
                    elementPath: Path([LineAttribute].self)[0]
                )
            ]
        }
    }

}
