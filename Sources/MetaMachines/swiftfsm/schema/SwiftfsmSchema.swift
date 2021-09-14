/*
 * SwiftfsmSchema.swift
 * Machines
 *
 * Created by Callum McColl on 21/6/21.
 * Copyright © 2021 Callum McColl. All rights reserved.
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

import Attributes
import Foundation
import SwiftMachines

public struct SwiftfsmSchema: MachineSchema {
    
    public var dependencyLayout: [Field] = []
    
    public var stateSchema = SwiftfsmStateSchema()
    
    public var transitionSchema = EmptySchema<MetaMachine>()
    
    @Group(wrappedValue: SwiftfsmVariables())
    var variables
    
    @Group(wrappedValue: SwiftfsmRinglet())
    var ringlet
    
    @Group(wrappedValue: SwiftfsmSettings())
    var settings
    
    public mutating func update(from metaMachine: MetaMachine) {
        self.stateSchema.update(from: metaMachine)
        self.variables.update(from: metaMachine)
        self.ringlet.update(from: metaMachine)
        self.settings.update(from: metaMachine)
    }
    
    public mutating func didCreateNewState(machine: inout MetaMachine, state: State, index: Int) -> Result<Bool, AttributeError<MetaMachine>> {
        syncSuspendList(machine: &machine)
        return .success(true)
    }
    
    public mutating func didDeleteStates(machine: inout MetaMachine, state: [State], at: IndexSet) -> Result<Bool, AttributeError<MetaMachine>> {
        syncSuspendList(machine: &machine)
        return .success(true)
    }
    
    public mutating func didChangeStatesName(machine: inout MetaMachine, state: State, index: Int, oldName: String) -> Result<Bool, AttributeError<MetaMachine>> {
        if machine.attributes[2].attributes["suspend_state"]?.enumeratedValue == oldName {
            machine.attributes[2].attributes["suspend_state"]?.enumeratedValue = state.name
        }
        syncSuspendList(machine: &machine)
        return .success(true)
    }
    
    private mutating func syncSuspendList(machine: inout MetaMachine) {
        let validValues = Set(machine.states.map(\.name) + [""])
        let currentValue = machine.attributes[2].attributes["suspend_state"]?.enumeratedValue ?? ""
        let newValue = validValues.contains(currentValue) ? currentValue : ""
        machine.attributes[2].fields[0].type = .enumerated(validValues: validValues)
        machine.attributes[2].attributes["suspend_state"] = .enumerated(newValue, validValues: validValues)
        self.settings.updateSuspendValues(validValues)
    }
    
}

public struct SwiftfsmStateSchema: SchemaProtocol {
    
    public typealias Root = MetaMachine
    
    @Group(wrappedValue: SwiftfsmStateVariables())
    var variables
    
    @Group(wrappedValue: SwiftfsmStateSettings())
    var settings
    
    mutating func update(from metaMachine: MetaMachine) {
        self.settings.update(from: metaMachine)
    }
    
}

public struct SwiftfsmStateVariables: GroupProtocol {
    
    public typealias Root = MetaMachine
    
    public let path = CollectionSearchPath(
        collectionPath: MetaMachine.path.states,
        elementPath: Path(State.self).attributes[0]
    )
    
    @TableProperty(
        label: "state_variables",
        columns: [
            .enumerated(label: "access_type", validValues: ["let", "var"]),
            .line(label: "label", validation: ValidatorFactory.required().alphaunderscore().notEmpty()),
            .expression(label: "type", language: .swift, validation: ValidatorFactory.required().alphaunderscore().notEmpty()),
            .expression(label: "initial_value", language: .swift, validation: ValidatorFactory.required())
        ],
        validation: { table in
            table.unique {
                $0.map { $0[1].lineValue }
            }
            table.each { (_, stateVariable) in
                stateVariable[0].enumeratedValue.in(["let", "var"])
                stateVariable[1].lineValue.notEmpty().maxLength(128)
                stateVariable[2].expressionValue.notEmpty().maxLength(128)
                stateVariable[3].expressionValue.maxLength(128)
            }
        }
    )
    var stateVariables
    
}

public struct SwiftfsmStateSettings: GroupProtocol {
    
    public typealias Root = MetaMachine
    
    public let path = CollectionSearchPath(
        collectionPath: MetaMachine.path.states,
        elementPath: Path(State.self).attributes[1]
    )
    
    @EnumerableCollectionProperty(
        label: "external_variables",
        validValues: []
    )
    var externalVariables
    
    @CodeProperty(
        label: "imports",
        language: .swift,
        validation: { code in
            code.maxLength(10240)
        }
    )
    var imports
    
    mutating func update(from metaMachine: MetaMachine) {
        let externals = Set(metaMachine.attributes[0].attributes["external_variables"]?.tableValue.map { $0[1].lineValue } ?? [])
        self._externalVariables.wrappedValue.type = AttributeType.enumerableCollection(validValues: externals)
    }

}

public struct SwiftfsmVariables: GroupProtocol {
    
    public typealias Root = MetaMachine
    
    public let path = MetaMachine.path.attributes[0]
    
    @TriggerBuilder<MetaMachine>
    public var triggers: AnyTrigger<MetaMachine> {
        AnyTrigger(WhenChanged(externalVariables).sync(
            target: CollectionSearchPath(
                collectionPath: MetaMachine.path.states,
                elementPath: Path(State.self).attributes[1].attributes["external_variables"]
            ),
            transform: { (attribute, oldValue) in
                let validValues = Set(attribute.tableValue.map { row in
                    row[1].lineValue
                })
                let currentValues = (oldValue?.enumerableCollectionValue ?? []).filter({ validValues.contains($0) })
                return .enumerableCollection(currentValues, validValues: validValues)
            }
        ))
    }
    
//    public var allTriggers: AnyTrigger<MetaMachine> {
//        AnyTrigger([AnyTrigger(triggers), AnyTrigger(parameters.triggers)])
//    }

    @TableProperty(
        label: "external_variables",
        columns: [
            .enumerated(label: "access_type", validValues: ["sensor", "actuator", "environment"]),
            .line(label: "label", validation: ValidatorFactory.required().alphaunderscore().notEmpty()),
            .expression(label: "type", language: .swift, validation: ValidatorFactory.required().alphaunderscore().notEmpty()),
            .expression(label: "value", language: .swift, validation: ValidatorFactory.required())
        ],
        validation: { table in
            table.unique({ $0.map { $0[1].lineValue } })
            table.each { (_, externalVariables) in
                externalVariables[0].enumeratedValue.in(["actuator", "sensor", "external"])
                externalVariables[1].lineValue.notEmpty().maxLength(128)
                externalVariables[2].expressionValue.notEmpty().maxLength(128)
                externalVariables[3].expressionValue.notEmpty().maxLength(128)
            }
        }
    )
    var externalVariables
    
    @TableProperty(
        label: "machine_variables",
        columns: [
            .enumerated(label: "access_type", validValues: ["let", "var"]),
            .line(label: "label", validation: ValidatorFactory.required().alphaunderscore().notEmpty()),
            .expression(label: "type", language: .swift, validation: ValidatorFactory.required().alphaunderscore().notEmpty()),
            .expression(label: "initial_value", language: .swift, validation: ValidatorFactory.required())
        ],
        validation: { table in
            table.unique() { $0.map { $0[1].lineValue } }
            table.each { (_, machineVariables) in
                machineVariables[0].enumeratedValue.in(["let", "var"])
                machineVariables[1].lineValue.notEmpty().maxLength(128)
                machineVariables[2].expressionValue.notEmpty().maxLength(128)
                machineVariables[3].expressionValue.maxLength(128)
            }
        }
    )
    var machineVariables
    
    @ComplexProperty(base: SwiftfsmParameters(), label: "parameters")
    var parameters
    
    mutating func update(from metaMachine: MetaMachine) {
        self.parameters.update(from: metaMachine)
    }
    
}

public struct SwiftfsmParameters: ComplexProtocol {
    
    public typealias Root = MetaMachine
    
    public let path = MetaMachine.path.attributes[0].attributes["parameters"].wrappedValue
    
    public private(set) var available: Set<String> = ["enable_parameters"]
    
    @TriggerBuilder<MetaMachine>
    public var triggers: AnyTrigger<MetaMachine> {
        WhenTrue(enableParameters, makeAvailable: parameters)
        WhenTrue(enableParameters, makeAvailable: resultType)
        WhenFalse(enableParameters, makeUnavailable: parameters)
        WhenFalse(enableParameters, makeUnavailable: resultType)
    }
    
    @BoolProperty(label: "enable_parameters")
    var enableParameters
    
    @TableProperty(
        label: "parameters",
        columns: [
            .line(label: "label", validation: ValidatorFactory.required().alphaunderscore().notEmpty()),
            .expression(label: "type", language: .swift, validation: ValidatorFactory.required().alphaunderscore().notEmpty()),
            .expression(label: "default_value", language: .swift, validation: ValidatorFactory.required())
        ],
        validation: { table in
            table.unique() { $0.map { $0[0].lineValue } }
            table.each { (_, parameters) in
                parameters[0].lineValue.notEmpty().maxLength(128)
                parameters[1].expressionValue.notEmpty().maxLength(128)
                parameters[2].expressionValue.maxLength(128)
            }
        }
    )
    var parameters
    
    @ExpressionProperty(
        label: "result_type",
        language: .swift,
        validation: { expression in
            expression.maxLength(128)
        }
    )
    var resultType
    
    mutating func update(from metaMachine: MetaMachine) {
        self.available = Set((metaMachine.attributes[0].attributes["parameters"]?.complexFields ?? []).map(\.name))
    }
    
}

public struct SwiftfsmRinglet: GroupProtocol {
    
    public let path = MetaMachine.path.attributes[1]
    
    public private(set) var available: Set<String> = ["use_custom_ringlet"]
    
    @TriggerBuilder<MetaMachine>
    public var triggers: AnyTrigger<MetaMachine> {
        WhenTrue(useCustomRinglet, makeAvailable: actions)
        WhenTrue(useCustomRinglet, makeAvailable: ringletVariables)
        WhenTrue(useCustomRinglet, makeAvailable: imports)
        WhenTrue(useCustomRinglet, makeAvailable: execute)
        WhenFalse(useCustomRinglet, makeUnavailable: actions)
        WhenFalse(useCustomRinglet, makeUnavailable: ringletVariables)
        WhenFalse(useCustomRinglet, makeUnavailable: imports)
        WhenFalse(useCustomRinglet, makeUnavailable: execute)
    }
    
    @BoolProperty(label: "use_custom_ringlet")
    var useCustomRinglet
    
    @CollectionProperty(label: "actions", lines: ValidatorFactory.optional())//.alphaunderscore().notEmpty())
    var actions
    
    @TableProperty(
        label: "ringlet_variables",
        columns: [
            .enumerated(label: "access_type", validValues: ["let", "var"], validation: .required()),
            .line(label: "label", validation: ValidatorFactory.required().alphaunderscore().notEmpty()),
            .expression(label: "type", language: .swift, validation: ValidatorFactory.required().alphaunderscorefirst().notEmpty()),
            .expression(label: "initial_value", language: .swift, validation: ValidatorFactory.required().alphaunderscorefirst().notEmpty())
        ],
        validation: { table in
            table.unique() { $0.map { $0[1].lineValue } }
            table.each { (_, ringletVariables) in
                ringletVariables[0].enumeratedValue.in(["let", "var"])
                ringletVariables[1].lineValue.notEmpty().maxLength(128)
                ringletVariables[2].expressionValue.notEmpty().maxLength(128)
                ringletVariables[3].expressionValue.maxLength(128)
            }
        }
    )
    var ringletVariables
    
    @CodeProperty(
        label: "imports",
        language: .swift,
        validation: { code in
            code.maxLength(10240)
        }
    )
    var imports
    
    @CodeProperty(
        label: "execute",
        language: .swift,
        validation: { code in
            code.maxLength(10240)
        }
    )
    var execute
    
    mutating func update(from metaMachine: MetaMachine) {
        self.available = Set(metaMachine.attributes[1].fields.map(\.name))
    }
    
}

public struct SwiftfsmSettings: GroupProtocol {
    
    public typealias Root = MetaMachine
    
    public let path = MetaMachine.path.attributes[2]
    
    @EnumeratedProperty(
        label: "suspend_state",
        validValues: []
    )
    var suspendState
    
    @ComplexProperty(base: SwiftfsmModuleDependencies(), label: "module_dependencies")
    var moduleDependencies
    
    public mutating func update(from metaMachine: MetaMachine) {
        let names = metaMachine.states.map(\.name)
        let validValues = Set(names)
        self.updateSuspendValues(validValues)
    }
    
    public mutating func updateSuspendValues(_ validValues: Set<String>) {
        self.suspendState.type = .enumerated(validValues: validValues)
    }
    
}

public struct SwiftfsmModuleDependencies: ComplexProtocol {
    
    public typealias Root = MetaMachine
    
    public let path = MetaMachine.path.attributes[2].attributes["module_dependencies"].wrappedValue
    
    //@ComplexCollectionProperty(base: SwiftfsmPackage(), label: "packages")
    //var packages
    
    @CodeProperty(
        label: "system_imports",
        language: .swift,
        validation: { code in
            code.maxLength(10240)
        }
    )
    var systemImports
    
    @CodeProperty(
        label: "system_includes",
        language: .swift,
        validation: { code in
            code.maxLength(10240)
        }
    )
    var systemIncludes
    
}

public struct SwiftfsmPackage: ComplexProtocol {
    
    public typealias Root = MetaMachine
    
    public let path = CollectionSearchPath(
        MetaMachine.path
            .attributes[2]
            .attributes["module_dependencies"]
            .wrappedValue
            .complexValue["packages"]
            .wrappedValue
            .collectionValue
    )
    
    @CollectionProperty(label: "products", lines: .required())
    var products
    
    @CollectionProperty(label: "qualifiers", lines: .required())
    var qualifiers
    
    @CollectionProperty(label: "targets_to_import", lines: .required())
    var targetsToImport
    
    @LineProperty(label: "url")
    var url
    
}
