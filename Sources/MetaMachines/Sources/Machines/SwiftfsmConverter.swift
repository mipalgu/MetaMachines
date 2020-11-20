/*
 * SwiftfsmConverter.swift
 * Machines
 *
 * Created by Callum McColl on 3/11/20.
 * Copyright © 2020 Callum McColl. All rights reserved.
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
import SwiftMachines
import Foundation

struct SwiftfsmConverter: Converter, MachineValidator {
    
    private let validator = SwiftfsmMachineValidator()
    
    var initial: Machine {
        let swiftMachine = SwiftMachines.Machine(
            name: "Untitled",
            filePath: URL(fileURLWithPath: "/tmp/Untitled.machine"),
            externalVariables: [],
            packageDependencies: [],
            swiftIncludeSearchPaths: [],
            includeSearchPaths: [],
            libSearchPaths: [],
            imports: "",
            includes: nil,
            vars: [],
            model: nil,
            parameters: nil,
            returnType: nil,
            initialState: SwiftMachines.State(
                name: "Initial",
                imports: "",
                externalVariables: nil,
                vars: [],
                actions: [SwiftMachines.Action(name: "onEntry", implementation: ""), SwiftMachines.Action(name: "onExit", implementation: ""), SwiftMachines.Action(name: "main", implementation: "")],
                transitions: []
            ),
            suspendState: SwiftMachines.State(
                name: "Suspend",
                imports: "",
                externalVariables: nil,
                vars: [],
                actions: [SwiftMachines.Action(name: "onEntry", implementation: ""), SwiftMachines.Action(name: "onExit", implementation: ""), SwiftMachines.Action(name: "main", implementation: "")],
                transitions: []
            ),
            states: [
                SwiftMachines.State(
                    name: "Initial",
                    imports: "",
                    externalVariables: nil,
                    vars: [],
                    actions: [SwiftMachines.Action(name: "onEntry", implementation: ""), SwiftMachines.Action(name: "onExit", implementation: ""), SwiftMachines.Action(name: "main", implementation: "")],
                    transitions: []
                ),
                SwiftMachines.State(
                    name: "Suspend",
                    imports: "",
                    externalVariables: nil,
                    vars: [],
                    actions: [SwiftMachines.Action(name: "onEntry", implementation: ""), SwiftMachines.Action(name: "onExit", implementation: ""), SwiftMachines.Action(name: "main", implementation: "")],
                    transitions: []
                )
            ],
            submachines: [],
            callableMachines: [],
            invocableMachines: []
        )
        return metaMachine(of: swiftMachine)
    }
    
    func metaMachine(of swiftMachine: SwiftMachines.Machine) -> Machine {
        var attributes: [AttributeGroup] = []
        let variables = AttributeGroup(
            name: "variables",
            fields: [
                "external_variables": .table(columns: [
                    ("label", .line),
                    ("type", .expression(language: .swift)),
                    ("value", .expression(language: .swift))
                ]),
                "fsm_variables": .table(columns: [
                    ("access_type", .enumerated(validValues: Set(SwiftMachines.Variable.AccessType.allCases.map { $0.rawValue }))),
                    ("label", .line),
                    ("type", .expression(language: .swift)),
                    ("initial_value", .expression(language: .swift))
                ]),
                "parameters": .complex(layout: swiftMachine.parameters == nil ? ["enable_parameters": .bool] : [
                    "enable_parameters": .bool,
                    "parameters": .table(columns: [
                        ("label", .line),
                        ("type", .expression(language: .swift)),
                        ("default_value", .expression(language: .swift))
                    ]),
                    "result_type": .expression(language: .swift)
                ])
            ],
            attributes: [
                "external_variables": .table(
                    swiftMachine.externalVariables.map {
                        [
                            .enumerated($0.accessType.rawValue, validValues: Set(SwiftMachines.Variable.AccessType.allCases.map { $0.rawValue })),
                            .line($0.label),
                            .expression(Expression($0.type), language: .swift),
                            .expression(Expression($0.initialValue ?? ""), language: .swift)
                        ]
                    },
                    columns: [
                        ("access_type", .enumerated(validValues: Set(SwiftMachines.Variable.AccessType.allCases.map { $0.rawValue }))),
                        ("label", .line),
                        ("type", .expression(language: .swift)),
                        ("value", .expression(language: .swift))
                    ]
                ),
                "machine_variables": .table(
                    swiftMachine.vars.map {
                        [
                            .enumerated($0.accessType.rawValue, validValues: Set(SwiftMachines.Variable.AccessType.allCases.map { $0.rawValue })),
                            .line($0.label),
                            .expression(Expression($0.type), language: .swift),
                            .expression(Expression($0.initialValue ?? ""), language: .swift)
                        ]
                    },
                    columns: [
                        ("access_type", .enumerated(validValues: Set(SwiftMachines.Variable.AccessType.allCases.map { $0.rawValue }))),
                        ("label", .line),
                        ("type", .expression(language: .swift)),
                        ("initial_value", .expression(language: .swift))
                    ]
                ),
                "parameters": .complex(swiftMachine.parameters == nil ? ["enable_parameters": .bool(false)] : [
                    "enable_parameters": .bool(true),
                    "parameters": .table(
                        (swiftMachine.parameters ?? []).map {
                            [
                                .line($0.label),
                                .expression(Expression($0.type), language: .swift),
                                .expression(Expression($0.initialValue ?? ""), language: .swift)
                            ]
                        },
                        columns: [
                            ("label", .line),
                            ("type", .expression(language: .swift)),
                            ("default_value", .expression(language: .swift))
                        ]
                    ),
                    "result_type": .expression(Expression(swiftMachine.returnType ?? ""), language: .swift)
                ], layout: swiftMachine.parameters == nil ? ["enable_parameters": .bool] : [
                    "enable_parameters": .bool,
                    "parameters": .table(columns: [
                        ("label", .line),
                        ("type", .expression(language: .swift)),
                        ("default_value", .expression(language: .swift))
                    ]),
                    "result_type": .expression(language: .swift)
                ])
            ]
        )
        attributes.append(variables)
        if let model = swiftMachine.model {
            let group = AttributeGroup(
                name: "ringlet",
                fields: [
                    "use_custom_ringlet": .bool,
                    "actions": .collection(type: .line),
                    "ringlet_variables": .table(columns: [
                        ("access_type", .enumerated(validValues: Set(SwiftMachines.Variable.AccessType.allCases.map { $0.rawValue }))),
                        ("label", .line),
                        ("type", .expression(language: .swift)),
                        ("initial_value", .expression(language: .swift))
                    ]),
                    "imports": .code(language: .swift),
                    "execute": .code(language: .swift)
                ],
                attributes: [
                    "use_custom_ringlet": .bool(true),
                    "actions": .collection(lines: model.actions),
                    "ringlet_variables": .table(
                        model.ringlet.vars.map {
                            [
                                .enumerated($0.accessType.rawValue, validValues: Set(SwiftMachines.Variable.AccessType.allCases.map { $0.rawValue })),
                                .line($0.label),
                                .expression(Expression($0.type), language: .swift),
                                .expression(Expression($0.initialValue ?? ""), language: .swift)
                            ]
                        },
                        columns: [
                            ("access_type", .enumerated(validValues: Set(SwiftMachines.Variable.AccessType.allCases.map { $0.rawValue }))),
                            ("label", .line),
                            ("type", .expression(language: .swift)),
                            ("initial_value", .expression(language: .swift))
                        ]
                    ),
                    "imports": .code(model.ringlet.imports, language: .swift),
                    "execute": .code(model.ringlet.execute, language: .swift)
                ]
            )
            attributes.append(group)
        } else {
            let group = AttributeGroup(
                name: "ringlet",
                fields: [
                    "use_custom_ringlet": .bool
                ],
                attributes: [
                    "use_custom_ringlet": .bool(false)
                ]
            )
            attributes.append(group)
        }
        let settings = AttributeGroup(
            name: "settings",
            fields: [
                "suspend_state": .enumerated(validValues: Set(swiftMachine.states.map(\.name) + [""])),
                "module_dependencies": .complex(layout: [
                    "packages": .collection(type: .complex(layout: [
                        "products": .collection(type: .line),
                        "qualifiers": .collection(type: .line),
                        "targets_to_import": .collection(type: .line),
                        "url": .line
                    ])),
                    "system_imports": .code(language: .swift),
                    "system_includes": .code(language: .c),
                    "swift_search_paths": .collection(type: .line),
                    "c_header_search_paths": .collection(type: .line),
                    "linker_search_paths": .collection(type: .line)
                ])
            ],
            attributes: [
                "suspend_state": Attribute.enumerated(swiftMachine.suspendState?.name ?? "", validValues: Set(swiftMachine.states.map(\.name) + [""])),
                "module_dependencies": .complex([
                    "packages": .collection(
                        complex: swiftMachine.packageDependencies.map {
                            [
                                "products": .collection(lines: $0.products),
                                "qualifiers": .collection(lines: $0.qualifiers),
                                "targets_to_import": .collection(lines: $0.targets),
                                "url": .line($0.url)
                            ]
                        },
                        layout: [
                            "products": .collection(type: .line),
                            "qualifiers": .collection(type: .line),
                            "targets_to_import": .collection(type: .line),
                            "url": .line
                        ]
                    ),
                    "system_imports": .code(swiftMachine.imports, language: .swift),
                    "system_includes": .code(swiftMachine.includes ?? "", language: .c),
                    "swift_search_paths": .collection(lines: swiftMachine.swiftIncludeSearchPaths),
                    "c_header_search_paths": .collection(lines: swiftMachine.includeSearchPaths),
                    "linker_search_paths": .collection(lines: swiftMachine.libSearchPaths)
                ], layout: [
                    "packages": .collection(type: .complex(layout: [
                        "products": .collection(type: .line),
                        "qualifiers": .collection(type: .line),
                        "targets_to_import": .collection(type: .line),
                        "url": .line
                    ])),
                    "system_imports": .code(language: .swift),
                    "system_includes": .code(language: .c),
                    "swift_search_paths": .collection(type: .line),
                    "c_header_search_paths": .collection(type: .line),
                    "linker_search_paths": .collection(type: .line)
                ])
            ],
            metaData: [:]
        )
        attributes.append(settings)
        let states = swiftMachine.states.map { (state) -> State in
            let settingsFields: [Field]
            let settingsAttributes: [String: Attribute]
            if let externals = state.externalVariables {
                settingsFields = [
                    "access_external_variables": .bool,
                    "external_variables": .enumerableCollection(validValues: Set(swiftMachine.externalVariables.map { $0.label })),
                    "imports": .text
                ]
                settingsAttributes = [
                    "access_external_variables": .bool(true),
                    "external_variables": .enumerableCollection(Set(externals.map { $0.label }), validValues: Set(swiftMachine.externalVariables.map { $0.label })),
                    "imports": .text(state.imports)
                ]
            } else {
                settingsFields = [
                    "access_external_variables": .bool
                ]
                settingsAttributes = [
                    "access_external_variables": .bool(false)
                ]
            }
            return State(
                name: state.name,
                actions: state.actions.map { Action(name: $0.name, implementation: Code($0.implementation), language: .swift) },
                attributes: [
                    AttributeGroup(
                        name: "variables",
                        fields: [
                            "state_variables": .table(columns: [
                                ("access_type", .enumerated(validValues: Set(SwiftMachines.Variable.AccessType.allCases.map { $0.rawValue }))),
                                ("label", .line),
                                ("type", .expression(language: .swift)),
                                ("initial_value", .expression(language: .swift))
                            ])
                        ],
                        attributes: [
                            "state_variables": .table(
                                state.vars.map {
                                    [
                                        .enumerated($0.accessType.rawValue, validValues: Set(SwiftMachines.Variable.AccessType.allCases.map { $0.rawValue })),
                                        .line($0.label),
                                        .expression(Expression($0.type), language: .swift),
                                        .expression(Expression($0.initialValue ?? ""), language: .swift)
                                    ]
                                },
                                columns: [
                                    ("access_type", .enumerated(validValues: Set(SwiftMachines.Variable.AccessType.allCases.map { $0.rawValue }))),
                                    ("label", .line),
                                    ("type", .expression(language: .swift)),
                                    ("initial_value", .expression(language: .swift))
                                ]
                            )
                        ]
                    ),
                    AttributeGroup(
                        name: "settings",
                        fields: settingsFields,
                        attributes: settingsAttributes
                    )
                ]
            )
        }
        let transitions = swiftMachine.states.flatMap { state in
            state.transitions.map {
                Transition(condition: $0.condition, source: state.name, target: $0.target)
            }
        }
        return Machine(
            semantics: .swiftfsm,
            filePath: swiftMachine.filePath,
            initialState: swiftMachine.initialState.name,
            states: states,
            transitions: transitions,
            attributes: attributes,
            metaData: []
        )
    }
    
    func convert(_ machine: Machine) throws -> SwiftMachines.Machine {
        try self.validator.validate(machine: machine)
        let ringletGroup = machine.attributes[1]
        let actions = Set(ringletGroup.attributes["actions"]?.collectionLines ?? ["onEntry", "onExit", "main"]).sorted().filter {
            $0.trimmingCharacters(in: .whitespacesAndNewlines) != ""
        }
        let model: SwiftMachines.Model?
        if (ringletGroup.attributes["use_custom_ringlet"]?.boolValue ?? false) {
            guard let imports = ringletGroup.attributes["imports"]?.codeValue else {
                throw ConversionError(message: "Missing required attribute ringlet.imports", path: Machine.path.attributes[1].attributes["imports"].wrappedValue)
            }
            guard let execute = ringletGroup.attributes["executes"]?.codeValue else {
                throw ConversionError(message: "Missing required attribute ringlet.execute", path: Machine.path.attributes[1].attributes["executes"].wrappedValue)
            }
            guard let vars = try ringletGroup.attributes["ringlet_variables"]?.tableValue.enumerated().map({ try self.parseVariable($1, path: Machine.path.attributes[1].attributes["ringlet_variables"].wrappedValue.tableValue[$0]) }) else {
                throw ConversionError(message: "Missing required variable list ringlet_variables", path: Machine.path.attributes[1].attributes["ringlet_variables"].wrappedValue)
            }
            model = SwiftMachines.Model(
                actions: actions,
                ringlet: SwiftMachines.Ringlet(imports: imports, vars: vars, execute: execute)
            )
        } else {
            model = nil
        }
        let resultType: String? = machine.attributes[1].attributes["result_type"]?.expressionValue
        guard let externalVariables = try machine.attributes[0].attributes["external_variables"]?.tableValue.enumerated().map({ try self.parseVariable($1, path: Machine.path.attributes[0].attributes["external_variables"].wrappedValue.tableValue[$0]) }) else {
            throw ConversionError(message: "Missing required variable list external_variables", path: Machine.path.attributes[0].attributes["external_variables"].wrappedValue)
        }
        let parameters: [SwiftMachines.Variable]? = (machine.attributes[0].attributes["parameters"]?.complexValue["enable_parameters"]?.boolValue ?? false)
            ? try machine.attributes[0].attributes["parameters"]?.complexValue["parameters"]?.tableValue.enumerated().map({ try self.parseParameters($1, path: Machine.path.attributes[0].attributes["parameters"].wrappedValue.complexValue["parameters"].wrappedValue.tableValue[$0]) })
            : nil
        guard let fsmVars = try machine.attributes[0].attributes["machine_variables"]?.tableValue.enumerated().map({ try self.parseVariable($1, path: Machine.path.attributes[0].attributes["machine_variables"].wrappedValue.tableValue[$0]) }) else {
            throw ConversionError(message: "Missing required variable list machine_variables", path: Machine.path.attributes[0].attributes["machine_variables"].wrappedValue)
        }
        var transitions: [String: [SwiftMachines.Transition]] = [:]
        transitions.reserveCapacity(machine.transitions.count)
        machine.transitions.forEach {
            guard let source = $0.source, let target = $0.target else {
                return
            }
            if nil == transitions[source] {
                transitions[source] = []
            }
            transitions[source]?.append(SwiftMachines.Transition(target: target, condition: $0.condition.map { String($0) }))
        }
        let states = try machine.states.enumerated().map { (index, state) -> SwiftMachines.State in
            let actions = state.actions.map { SwiftMachines.Action(name: $0.name, implementation: String($0.implementation)) }
            let settings = state.attributes[1]
            guard let vars = try state.attributes[0].attributes["state_variables"]?.tableValue.enumerated().map({ try self.parseVariable($1, path: Machine.path.states[index].attributes[0].attributes["state_variables"].wrappedValue.tableValue[$0]) }) else {
                throw ConversionError(message: "Missing required variable list state_variables", path: Machine.path.states[index].attributes[0].attributes["state_variables"].wrappedValue)
            }
            let externalVariablesSet: Set<String>? = settings.attributes["external_variables"]?.enumerableCollectionValue
            let externalVariables: [SwiftMachines.Variable]? = externalVariablesSet?.compactMap { label in externalVariables.first { $0.label == label } }
            return SwiftMachines.State(
                name: state.name,
                imports: settings.attributes["imports"]?.codeValue ?? "",
                externalVariables: externalVariables,
                vars: vars,
                actions: actions,
                transitions: transitions[state.name] ?? []
            )
        }
        guard let initialState = states.first(where: { $0.name == String(machine.initialState) }) else {
            throw ConversionError(message: "Initial state does not exist in the states array", path: Machine.path.initialState)
        }
        let suspendState = (machine.attributes[2].attributes["suspend_state"]?.enumeratedValue).map { stateName in
            return states.first(where: { stateName == $0.name })
        } ?? nil
        let moduleDependencies = machine.attributes[2].attributes["module_dependencies"]!.complexValue
        let packageDependencies = try (moduleDependencies["packages"]?.collectionComplex.enumerated().map {
            try self.parsePackageDependencies($1, attributePath: Machine.path.attributes[2].attributes["module_dependencies"].wrappedValue.complexValue)
        }) ?? []
        return SwiftMachines.Machine(
            name: machine.name,
            filePath: machine.filePath,
            externalVariables: externalVariables,
            packageDependencies: packageDependencies,
            swiftIncludeSearchPaths: moduleDependencies["swift_search_paths"]?.collectionLines ?? [],
            includeSearchPaths: moduleDependencies["c_header_search_paths"]?.collectionLines ?? [],
            libSearchPaths: moduleDependencies["linker_search_paths"]?.collectionLines ?? [],
            imports: moduleDependencies["system_imports"]?.codeValue ?? "",
            includes: moduleDependencies["system_includes"]?.codeValue,
            vars: fsmVars,
            model: model,
            parameters: parameters,
            returnType: resultType,
            initialState: initialState,
            suspendState: suspendState,
            states: states,
            submachines: [],
            callableMachines: [],
            invocableMachines: []
        )
    }
    
    private func parsePackageDependencies<Path: ReadOnlyPathProtocol>(_ attributes: [String: Attribute], attributePath: Path) throws -> SwiftMachines.PackageDependency where Path.Root == Machine, Path.Value == [String: Attribute] {
        let products = attributes["products"]?.collectionLines.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty } ?? []
        let qualifiers = attributes["qualifiers"]?.collectionLines.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty } ?? []
        let targets = attributes["targets_to_import"]?.collectionLines.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty } ?? []
        let url = attributes["url"]?.lineValue.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if products.isEmpty {
            throw ConversionError(message: "Missing required field", path: ReadOnlyPath(keyPath: attributePath.keyPath.appending(path: \.["products"]), ancestors: attributePath.fullPath))
        }
        if qualifiers.isEmpty {
            throw ConversionError(message: "Missing required field", path: ReadOnlyPath(keyPath: attributePath.keyPath.appending(path: \.["qualifiers"]), ancestors: attributePath.fullPath))
        }
        if targets.isEmpty {
            throw ConversionError(message: "Missing required field \(attributePath)", path: ReadOnlyPath(keyPath: attributePath.keyPath.appending(path: \.["targets"]), ancestors: attributePath.fullPath))
        }
        if url.isEmpty {
            throw ConversionError(message: "Missing required field \(attributePath)", path: ReadOnlyPath(keyPath: attributePath.keyPath.appending(path: \.["url"]), ancestors: attributePath.fullPath))
        }
        return SwiftMachines.PackageDependency(products: products, targets: targets, url: url, qualifiers: qualifiers)
    }
    
    private func parseParameters<Path: ReadOnlyPathProtocol>(_ variable: [LineAttribute], path: Path) throws -> SwiftMachines.Variable where Path.Root == Machine, Path.Value == [LineAttribute] {
        return try self.parseVariable(
            [
                LineAttribute.enumerated(
                    SwiftMachines.Variable.AccessType.readOnly.rawValue,
                    validValues: Set(SwiftMachines.Variable.AccessType.allCases.map(\.rawValue))
                )
            ] + variable,
            path: path
        )
    }
    
    private func parseVariable<Path: ReadOnlyPathProtocol>(_ variable: [LineAttribute], path: Path) throws -> SwiftMachines.Variable where Path.Root == Machine, Path.Value == [LineAttribute] {
        guard variable.count == 4 else {
            throw ConversionError(message: "Missing required fields", path: path)
        }
        guard let accessType = SwiftMachines.Variable.AccessType(rawValue: variable[0].enumeratedValue) else {
            throw ConversionError(message: "Invalid value", path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.[0]), ancestors: path.fullPath))
        }
        let label = String(variable[1].expressionValue)
        let type = String(variable[2].expressionValue)
        return SwiftMachines.Variable(accessType: accessType, label: label, type: type, initialValue: String(variable[3].expressionValue))
    }
    
}

extension SwiftfsmConverter: MachineMutator {

    func addItem<Path>(attribute: Path, machine: inout Machine) throws where Path : PathProtocol, Path.Root == Machine {
        throw ValidationError(message: "addItem is not yet implemented", path: attribute)
    }
    
    func moveItems<Path: PathProtocol, T>(attribute: Path, machine: inout Machine, from source: IndexSet, to destination: Int) throws where Path.Root == Machine, Path.Value == [T] {
        let original = machine[keyPath: attribute.path]
        var copy = original
        let descending = source.sorted(by: >)
        descending.forEach { index in copy.remove(at: index) }
        let index = destination - source.filter { $0 < destination }.count
        descending.forEach { source in
            copy.insert(original[source], at: index)
        }
        machine[keyPath: attribute.path] = original
    }
    
    func newState(machine: inout Machine) throws {
        try perform(on: &machine) { machine in
            if machine.semantics != .swiftfsm {
                throw MachinesError.unsupportedSemantics(machine.semantics)
            }
            let name = "State"
            if nil == machine.states.first(where: { $0.name == name }) {
                try machine.states.append(self.createState(named: name, forMachine: machine))
            }
            var num = 0
            var stateName: String
            repeat {
                stateName = name + "\(num)"
                num += 1
            } while (nil != machine.states.reversed().first(where: { $0.name == stateName }))
            try machine.states.append(self.createState(named: stateName, forMachine: machine))
            self.syncSuspendState(machine: &machine)
        }
    }
    
    func newTransition(source: StateName, target: StateName, condition: Expression? = nil, machine: inout Machine) throws {
        try perform(on: &machine) { machine in
            guard nil != machine.states.first(where: { $0.name == source }), nil != machine.states.first(where: { $0.name == target }) else {
                throw ValidationError(message: "You must attach a transition to a source and target state", path: Machine.path.transitions)
            }
            machine.transitions.append(
                Transition(
                    condition: condition,
                    source: source,
                    target: target
                )
            )
        }
    }
    
    func deleteItem<Path>(attribute: Path, machine: inout Machine) throws where Path : PathProtocol, Path.Root == Machine {
        throw ValidationError(message: "deleteItem is not yet implemented", path: attribute)
    }
    
    func delete(states: IndexSet, transitions: IndexSet, machine: inout Machine) throws {
        try self.perform(on: &machine) { machine in
            if
                let initialIndex = machine.states.enumerated().first(where: { $0.1.name == machine.initialState })?.0,
                states.contains(initialIndex)
            {
                throw ValidationError(message: "You cannot delete the initial state", path: Machine.path.states[initialIndex])
            }
            machine.transitions = machine.transitions.enumerated().filter { !transitions.contains($0.0) }.map { $1 }
            machine.states = machine.states.enumerated().filter { !states.contains($0.0) }.map { $1 }
            let stateNames = Set(machine.states.map { $0.name })
            machine.transitions.removeAll {
                if let source = $0.source, stateNames.contains(source) {
                    return true
                }
                if let target = $0.target, stateNames.contains(target) {
                    return true
                }
                return false
            }
            self.syncSuspendState(machine: &machine)
        }
    }
    
    func deleteState(atIndex index: Int, machine: inout Machine) throws {
        try perform(on: &machine) { machine in
            if machine.states.count >= index {
                throw ValidationError(message: "Can't delete state that doesn't exist", path: Machine.path.states)
            }
            if machine.states[index].name == machine.initialState {
                throw ValidationError(message: "Can't delete the initial state", path: Machine.path.states[index])
            }
            machine.transitions.removeAll { $0.source == machine.states[index].name || $0.target == machine.states[index].name }
            machine.states.remove(at: index)
            self.syncSuspendState(machine: &machine)
        }
    }
    
    func deleteTransition(atIndex index: Int, machine: inout Machine) throws {
        try perform(on: &machine) { machine in
            guard machine.transitions.count >= index else {
                throw ValidationError(message: "Cannot delete transition that does not exist", path: Machine.path.transitions)
            }
            machine.transitions.remove(at: index)
        }
    }
    
    func modify<Path>(attribute: Path, value: Path.Value, machine: inout Machine) throws where Path : PathProtocol, Path.Root == Machine {
        try perform(on: &machine) { machine in
            if let index = machine.states.indices.first(where: { Machine.path.states[$0].name.path == attribute.path }) {
                guard let stateName = value as? StateName else {
                    throw ValidationError(message: "Invalid value \(value)", path: attribute)
                }
                try self.changeName(ofState: index, to: stateName, machine: &machine)
            }
            switch attribute.path {
            case machine.path.attributes[1].attributes["use_custom_ringlet"].wrappedValue.path,
                 machine.path.attributes[1].attributes["use_custom_ringlet"].wrappedValue.boolValue.keyPath,
                 machine.path.attributes[1].attributes["use_custom_ringlet"].wrappedValue.lineAttribute.boolValue.keyPath:
                guard let boolValue = (value as? Attribute)?.boolValue ?? (value as? LineAttribute)?.boolValue ?? (value as? Bool) else {
                    throw ValidationError(message: "Invalid value \(value)", path: attribute)
                }
                self.toggleUseCustomRinglet(boolValue: boolValue, machine: &machine)
            default:
                machine[keyPath: attribute.path] = value
            }
        }
    }
    
    private func changeName(ofState index: Int, to stateName: StateName, machine: inout Machine) throws {
        if Set(machine.states.map(\.name)).contains(stateName) {
            throw ValidationError(message: "Cannot rename state to '\(stateName)' since a state with that name already exists", path: machine.path.states[index].name)
        }
        let currentName = machine.states[index].name
        machine[keyPath: machine.path.states[index].name.path] = stateName
        machine.transitions = machine.transitions.map {
            if $0.source != currentName {
                return $0
            }
            return Transition(condition: $0.condition, source: currentName, target: $0.target, attributes: $0.attributes, metaData: $0.metaData)
        }
        if machine.initialState == currentName {
            machine.initialState = stateName
        }
        if machine.attributes[2].attributes["suspend_state"]!.enumeratedValue == currentName {
            machine.attributes[2].attributes["suspend_state"]!.enumeratedValue = stateName
        }
        self.syncSuspendState(machine: &machine)
    }
    
    private func syncSuspendState(machine: inout Machine) {
        let validValues = Set(machine.states.map(\.name) + [""])
        let currentValue = machine.attributes[2].attributes["suspend_state"]?.enumeratedValue ?? ""
        let newValue = validValues.contains(currentValue) ? currentValue : ""
        machine.attributes[2].fields[0].type = .enumerated(validValues: validValues)
        machine.attributes[2].attributes["suspend_state"] = .enumerated(newValue, validValues: validValues)
    }
    
    private func toggleUseCustomRinglet(boolValue: Bool, machine: inout Machine) {
        machine.attributes[1].attributes["use_custom_ringlet"] = .bool(boolValue)
        if !boolValue {
            machine.attributes[1].fields = machine.attributes[1].fields.filter { $0.name == "use_custom_ringlet" }
            return
        }
        if nil != machine.attributes[1].fields.first(where: { $0.name == "actions" }) {
            return
        }
        machine.attributes[1].fields = [
            "use_custom_ringlet": .bool,
            "actions": .collection(type: .line),
            "ringlet_variables": .table(columns: [
                ("access_type", .enumerated(validValues: Set(SwiftMachines.Variable.AccessType.allCases.map { $0.rawValue }))),
                ("label", .line),
                ("type", .expression(language: .swift)),
                ("initial_value", .expression(language: .swift))
            ]),
            "imports": .code(language: .swift),
            "execute": .code(language: .swift)
        ]
        machine.attributes[1].attributes["actions"] = .collection(lines: ["onEntry", "main", "onExit"])
        machine.attributes[1].attributes["ringlet_variables"] = .table([], columns: [
            ("access_type", .enumerated(validValues: Set(SwiftMachines.Variable.AccessType.allCases.map { $0.rawValue }))),
            ("label", .line),
            ("type", .expression(language: .swift)),
            ("initial_value", .expression(language: .swift))
        ])
        machine.attributes[1].attributes["imports"] = .code(Code(), language: .swift)
        machine.attributes[1].attributes["execute"] = .code(Code(), language: .swift)
    }
    
    private func perform(on machine: inout Machine, _ f: (inout Machine) throws -> Void) throws {
        let backup = machine
        do {
            try f(&machine)
            try self.validate(machine: machine)
        } catch let e {
            machine = backup
            throw e
        }
    }
    
    private func createState(named name: String, forMachine machine: Machine) throws -> State {
        guard machine.attributes.count >= 3 else {
            throw ValidationError(message: "Missing attributes in machine", path: Machine.path.attributes)
        }
        let actions = machine.attributes[2].attributes["actions"]?.collectionValue.failMap { $0.lineValue } ?? ["onEntry", "main", "onExit"]
        return State(
            name: name,
            actions: actions.map { Action(name: $0, implementation: Code(""), language: .swift) },
            attributes: [
                AttributeGroup(
                    name: "variables",
                    fields: [
                        "state_variables": .table(columns: [
                            ("access_type", .enumerated(validValues: Set(SwiftMachines.Variable.AccessType.allCases.map { $0.rawValue }))),
                            ("label", .line),
                            ("type", .expression(language: .swift)),
                            ("initial_value", .expression(language: .swift))
                        ])
                    ],
                    attributes: [
                        "state_variables": .table(
                            [],
                            columns: [
                                ("access_type", .enumerated(validValues: Set(SwiftMachines.Variable.AccessType.allCases.map { $0.rawValue }))),
                                ("label", .line),
                                ("type", .expression(language: .swift)),
                                ("initial_value", .expression(language: .swift))
                            ]
                        )
                    ]
                ),
                AttributeGroup(
                    name: "settings",
                    fields: [
                        "access_external_variables": .bool
                    ],
                    attributes: [
                        "access_external_variables": .bool(false)
                    ]
                )
            ]
        )
    }
    
    func validate(machine: Machine) throws {
        try self.validator.validate(machine: machine)
    }
    
}
