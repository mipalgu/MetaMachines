//
//  File.swift
//  File
//
//  Created by Morgan McColl on 15/9/21.
//

import Foundation
import Attributes

public struct CXXSchema: MachineSchema {
    
    public var dependencyLayout: [Field] = []
    
    public var stateSchema: CXXStateSchema
    
    public var transitionSchema = EmptySchema<MetaMachine>()
    
    @Group var variables: CXXVariables
    
    @Group var funcRefs: CXXFuncRefs
    
    @Group var includes: CXXIncludes
    
    @Group var settings = CXXSettings()
    
    public init?(semantics: MetaMachine.Semantics) {
        guard let cxxSemantics = CXXSemantics(semantics: semantics) else {
            return nil
        }
        self.stateSchema = CXXStateSchema(semantics: cxxSemantics)
        self.variables = CXXVariables(semantics: cxxSemantics)
        self.funcRefs = CXXFuncRefs(semantics: cxxSemantics)
        self.includes = CXXIncludes(semantics: cxxSemantics)
    }
    
    public mutating func update(from metaMachine: MetaMachine) {
        self.settings.update(from: metaMachine)
    }
    
    public mutating func didCreateNewState(machine: inout MetaMachine, state: State, index: Int) -> Result<Bool, AttributeError<MetaMachine>> {
        syncSuspendList(machine: &machine)
        return .success(true)
    }
    
    
    public mutating func didDeleteState(machine: inout MetaMachine, state: State, at: Int) -> Result<Bool, AttributeError<MetaMachine>> {
        syncSuspendList(machine: &machine)
        return .success(true)
    }
    
    public mutating func didChangeStatesName(machine: inout MetaMachine, state: State, index: Int, oldName: String) -> Result<Bool, AttributeError<MetaMachine>> {
        syncSuspendList(machine: &machine)
        return .success(true)
    }
    
    public mutating func didDeleteStates(machine: inout MetaMachine, state: [State], at: IndexSet) -> Result<Bool, AttributeError<MetaMachine>> {
        syncSuspendList(machine: &machine)
        return .success(true)
    }
    
    private mutating func syncSuspendList(machine: inout MetaMachine) {
        let validValues = Set(machine.states.map(\.name) + [""])
        let currentValue = machine.attributes[3].attributes["suspended_state"]?.enumeratedValue ?? ""
        let newValue = validValues.contains(currentValue) ? currentValue : ""
        machine.attributes[3].fields[0].type = .enumerated(validValues: validValues)
        machine.attributes[3].attributes["suspended_state"] = .enumerated(newValue, validValues: validValues)
        self.settings.updateSuspendValues(validValues)
    }
    
}
