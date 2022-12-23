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
            includes: getIncludes(machine: machine),
            externalSignals: getExternalSignals(machine: machine),
            generics: getVHDLVariables(machine: machine, key: "generics"),
            clocks: getClocks(machine: machine),
            drivingClock: getDrivingClock(machine: machine),
            dependentMachines: [:],//getDependentMachines(machine: machine),
            machineVariables: getMachineVariables(machine: machine),
            machineSignals: getMachineSignals(machine: machine),
            isParameterised: isParameterised(machine: machine),
            parameterSignals: getParameters(machine: machine, key: "parameter_signals"),
            returnableSignals: getOutputs(machine: machine, key: "returnable_signals"),
            states: machine.states.map(VHDLMachines.State.init),
            transitions: getTransitions(machine: machine),
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
    
    private func getIncludes(machine: MetaMachine) -> [String] {
        guard
            machine.attributes.count == 4,
            let includes = machine.attributes[2].attributes["includes"]?.codeValue
        else {
            fatalError("Cannot retrieve includes")
        }
        return includes.split(separator: ";").map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines) + ";"
        }
    }
    
    private func getExternalSignals(machine: MetaMachine) -> [ExternalSignal] {
        guard
            machine.attributes.count == 4,
            let signals = machine.attributes[0].attributes["external_signals"]?.tableValue
        else {
            fatalError("Cannot retrieve external signals")
        }
        return signals.map {
            let value = $0[3].expressionValue == "" ? nil : $0[3].expressionValue
            let comment = $0[4].lineValue == "" ? nil : $0[4].lineValue
            guard let mode = Mode(rawValue: $0[0].enumeratedValue) else {
                fatalError("Cannot convert Mode!")
            }
            return ExternalSignal(type: $0[1].expressionValue, name: $0[2].lineValue, mode: mode, defaultValue: value, comment: comment)
        }
    }
    
    private func getVHDLVariables(machine: MetaMachine, key: String) -> [VHDLVariable] {
        guard
            machine.attributes.count == 4,
            let variables = machine.attributes[0].attributes[key]?.tableValue
        else {
            fatalError("Cannot retrieve external variables")
        }
        return variables.map {
            VHDLVariable(
                type: $0[0].expressionValue,
                name: $0[1].lineValue,
                defaultValue: $0[2].expressionValue == "" ? nil : $0[2].expressionValue,
                range: nil,
                comment: $0[3].lineValue == "" ? nil : $0[3].lineValue
            )
        }
    }
    
    private func getExternalVariables(machine: MetaMachine) -> [ExternalVariable] {
        guard
            machine.attributes.count == 4,
            let variables = machine.attributes[0].attributes["external_variables"]?.tableValue
        else {
            fatalError("Cannot retrieve external variables")
        }
        return variables.map {
            ExternalVariable(
                type: $0[1].expressionValue,
                name: $0[2].lineValue,
                mode: Mode(rawValue: $0[0].enumeratedValue)!,
                range: nil,
                defaultValue: $0[3].expressionValue == "" ? nil : $0[2].expressionValue,
                comment: $0[4].lineValue == "" ? nil : $0[3].lineValue
            )
        }
    }
    
    private func getParameters(machine: MetaMachine, key: String) -> [Parameter] {
        guard
            machine.attributes.count == 4,
            let variables = machine.attributes[1].attributes[key]?.tableValue
        else {
            fatalError("Cannot retrieve external variables")
        }
        return variables.map {
            Parameter(
                type: $0[0].expressionValue,
                name: $0[1].lineValue,
                defaultValue: $0[2].expressionValue == "" ? nil : $0[2].expressionValue,
                comment: $0[3].lineValue == "" ? nil : $0[3].lineValue
            )
        }
    }
    
    private func getClocks(machine: MetaMachine) -> [Clock] {
        guard
            machine.attributes.count == 4,
            let clocks = machine.attributes[0].attributes["clocks"]?.tableValue
        else {
            fatalError("Cannot retrieve clocks")
        }
        return clocks.map {
            guard let unit = Clock.FrequencyUnit(rawValue: $0[2].enumeratedValue) else {
                fatalError("Clock unit is invalid: \($0[2])")
            }
            return Clock(name: $0[0].lineValue, frequency: UInt(clamping: $0[1].integerValue), unit: unit)
        }
    }
    
    private func getDrivingClock(machine: MetaMachine) -> Int {
        guard
            machine.attributes.count == 4,
            let clock = machine.attributes[0].attributes["driving_clock"]?.enumeratedValue,
            let index = machine.attributes[0].attributes["clocks"]?.tableValue.firstIndex(where: { $0[0].lineValue == clock })
        else {
            fatalError("Cannot retrieve driving clock")
        }
        return index
    }
    
    private func getDependentMachines(machine: MetaMachine, relativeto machineDir: URL) -> [MachineName: URL] {
        var machines: [MachineName: URL] = [:]
        machine.dependencies.forEach {
            machines[$0.name] = $0.filePath(relativeTo: machineDir)
        }
        return machines
    }
    
    private func getMachineVariables(machine: MetaMachine) -> [VHDLVariable] {
        guard
            machine.attributes.count == 4,
            let variables = machine.attributes[0].attributes["machine_variables"]?.tableValue
        else {
            fatalError("Cannot retrieve machine variables")
        }
        return variables.map {
            VHDLVariable(
                type: $0[0].expressionValue,
                name: $0[1].lineValue,
                defaultValue: $0[2].expressionValue == "" ? nil : $0[2].expressionValue,
                range: nil,
                comment: $0[3].lineValue == "" ? nil : $0[3].lineValue
            )
        }
    }
    
    private func getMachineSignals(machine: MetaMachine) -> [MachineSignal] {
        guard
            machine.attributes.count == 4,
            let signals = machine.attributes[0].attributes["machine_signals"]?.tableValue
        else {
            fatalError("Cannot retrieve machine signals")
        }
        return signals.map {
            MachineSignal(
                type: $0[0].expressionValue,
                name: $0[1].lineValue,
                defaultValue: $0[2].expressionValue == "" ? nil : $0[2].expressionValue,
                comment: $0[3].lineValue == "" ? nil : $0[3].lineValue
            )
        }
    }

    private func getTransitions(machine: MetaMachine) -> [VHDLMachines.Transition] {
        machine.states.indices.flatMap { stateIndex in
            machine.states[stateIndex].transitions.map { transition in
                guard let targetIndex = machine.states.firstIndex(where: { transition.target == $0.name }) else {
                    fatalError("Cannot find target state \(transition.target) for transition \(transition) from state \(machine.states[stateIndex].name)")
                }
                return VHDLMachines.Transition(condition: transition.condition ?? "true", source: stateIndex, target: targetIndex)
            }
        }
    }
    
    private func getCodeIncludes(machine: MetaMachine, key: String) -> String? {
        guard let val = machine.attributes[1].attributes[key]?.codeValue else {
            return nil
        }
        return val == "" ? nil : val
    }
    
    private func getOutputs(machine: MetaMachine, key: String) -> [ReturnableVariable] {
        guard
            machine.attributes.count == 4,
            let returns = machine.attributes[1].attributes[key]?.tableValue
        else {
            fatalError("No outputs")
        }
        return returns.map {
            let comment = $0[2].lineValue
            return ReturnableVariable(type: $0[0].expressionValue, name: $0[1].lineValue, comment: comment == "" ? nil : comment)
        }
    }
    
    private func isParameterised(machine: MetaMachine) -> Bool {
        guard let isParameterised = machine.attributes[1].attributes["is_parameterised"]?.boolValue else {
            fatalError("Cannot discern if machine is parameterised")
        }
        return isParameterised
    }

}
