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

    func didCreateNewState(
        machine: inout MetaMachine, state: State, index: Int
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        statesTrigger(machine: &machine)
    }

    func didChangeStatesName(
        machine: inout MetaMachine, state: State, index: Int, oldName: String
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        let path = AnyPath(Path(MetaMachine.self).states[index].name)
        guard self.trigger.isTriggerForPath(path, in: machine) else {
            return .success(false)
        }
        return self.trigger.performTrigger(&machine, for: path)
    }

    func didDeleteState(
        machine: inout MetaMachine, state: State, at: Int
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        statesTrigger(machine: &machine)
    }

    func didDeleteStates(
        machine: inout MetaMachine, state: [State], at: IndexSet
    ) -> Result<Bool, AttributeError<MetaMachine>> {
        statesTrigger(machine: &machine)
    }

    mutating func update(from metaMachine: MetaMachine) {
        self = metaMachine.vhdlSchema.wrappedValue
    }

    private func statesTrigger(machine: inout MetaMachine) -> Result<Bool, AttributeError<MetaMachine>> {
        let path = AnyPath(Path(MetaMachine.self).states)
        guard self.trigger.isTriggerForPath(path, in: machine) else {
            return .success(false)
        }
        return self.trigger.performTrigger(&machine, for: path)
    }

}
