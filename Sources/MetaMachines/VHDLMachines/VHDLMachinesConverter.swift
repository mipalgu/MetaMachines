//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation
import VHDLMachines
import Attributes

struct VHDLMachinesConverter {

    func convert(machine: MetaMachine) throws -> VHDLMachines.Machine {
        let validator = VHDLMachinesValidator()
        try validator.validate(machine: machine)
        let vhdlStates = machine.states.map(VHDLMachines.State.init)
        let suspendedState = machine.attributes.first { $0.name == "settings" }?.attributes["suspended_state"]?.enumeratedValue
        let suspendedStateName = suspendedState == "" ? nil : suspendedState
        let suspendedIndex = suspendedStateName == nil ? nil : vhdlStates.firstIndex { $0.name == suspendedStateName! }
        return VHDLMachines.Machine(
            name: machine.name,
            path: URL(fileURLWithPath: "\(machine.name).machine", isDirectory: true), //fix later
            includes: machine.vhdlIncludes,
            externalSignals: machine.vhdlExternalSignals,
            generics: machine.vhdlVariables(for: "generics"),
            clocks: machine.vhdlClocks,
            drivingClock: machine.vhdlDrivingClock,
            dependentMachines: [:],//getDependentMachines(machine: machine),
            machineVariables: machine.vhdlMachineVariables,
            machineSignals: machine.vhdlMachineSignals,
            isParameterised: machine.vhdlIsParameterised,
            parameterSignals: machine.vhdlParameters(for: "parameter_signals"),
            returnableSignals: machine.vhdlParameterOutputs(for: "returnable_signals"),
            states: machine.states.map(VHDLMachines.State.init),
            transitions: machine.vhdlTransitions,
            initialState: machine.states.firstIndex(where: { machine.initialState == $0.name }) ?? 0,
            suspendedState: suspendedIndex,
            architectureHead: getCodeIncludes(machine: machine, key: "architecture_head"),
            architectureBody: getCodeIncludes(machine: machine, key: "architecture_body")
        )
    }

    func toMachine(machine: VHDLMachines.Machine) -> MetaMachine {
        MetaMachine(
            semantics: .vhdl,
            name: machine.name,
            initialState: machine.states[machine.initialState].name,
            states: machine.states.map { State(vhdl: $0, in: machine) },
            dependencies: [],
            attributes: machine.attributes,
            metaData: []
        )
    }
    
    private func addNewline(lhs: String, rhs: String) -> String {
        if lhs == "" {
            return rhs
        }
        if rhs == "" {
            return lhs
        }
        return lhs + "\n" + rhs
    }

    private func toAction(actionName: String, code: String) -> Action {
        Action(name: actionName, implementation: code, language: .vhdl)
    }
    
    private func getDependentMachines(machine: MetaMachine, relativeto machineDir: URL) -> [MachineName: URL] {
        var machines: [MachineName: URL] = [:]
        machine.dependencies.forEach {
            machines[$0.name] = $0.filePath(relativeTo: machineDir)
        }
        return machines
    }
    
    private func getCodeIncludes(machine: MetaMachine, key: String) -> String? {
        guard let val = machine.attributes[1].attributes[key]?.codeValue else {
            return nil
        }
        return val == "" ? nil : val
    }

}
