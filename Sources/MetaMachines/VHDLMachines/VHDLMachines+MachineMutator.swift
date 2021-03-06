//
//  File.swift
//  
//
//  Created by Morgan McColl on 19/5/21.
//

import Foundation
import Attributes
import VHDLMachines

extension VHDLMachinesConverter: MachineMutator {
    
    
    var dependencyLayout: [Field] {
        []
    }

    func addItem<Path, T>(_ item: T, to attribute: Path, machine: inout MetaMachine) -> Result<Bool, AttributeError<Path.Root>> where Path : PathProtocol, Path.Root == MetaMachine, Path.Value == [T] {
        if attribute.path == machine.path.attributes[0].attributes["clocks"].wrappedValue.blockAttribute.tableValue.path {
            machine[keyPath: attribute.path].append(item)
            guard
                let clock = item as? [LineAttribute],
                let currentDrivingClock = machine.attributes[0].attributes["driving_clock"]
            else {
                fatalError("Failed to add clocks")
            }
            let inserted = clock[0].lineValue
            var validValues = currentDrivingClock.enumeratedValidValues
            validValues.insert(inserted)
            machine.attributes[0].attributes["driving_clock"] = Attribute(lineAttribute: .enumerated(currentDrivingClock.enumeratedValue, validValues: validValues))
            return .success(true)
        }
        let signalPath = machine.path.attributes[0].attributes["external_signals"].wrappedValue.blockAttribute.tableValue.path
        if attribute.path == signalPath {
            guard let variableName = (item as? [LineAttribute])?[2].lineValue else {
                fatalError("Item does not fit format for external signal")
            }
            guard
                let signals = machine.attributes[0].attributes["external_signals"]?.tableValue.map({ $0[2].lineValue })
            else {
                fatalError("Cannot find external variables and signals")
            }
            let validValues = Set(signals + [variableName])
            machine[keyPath: attribute.path].append(item)
            machine.states.indices.forEach {
                guard let currentValues = machine.states[$0].attributes[0].attributes["externals"]?.enumerableCollectionValue else {
                    fatalError("Cannot find externals for state \(machine.states[$0].name)")
                }
                let _ = machine.modify(
                    attribute: MetaMachine.path.states[$0].attributes[0].attributes["externals"],
                    value: Attribute(blockAttribute: .enumerableCollection(currentValues, validValues: validValues))
                )
            }
            return .success(false)
            
        }
        machine[keyPath: attribute.path].append(item)
        return .success(false)
    }

    func moveItems<Path, T>(attribute: Path, machine: inout MetaMachine, from source: IndexSet, to destination: Int) -> Result<Bool, AttributeError<Path.Root>> where Path : PathProtocol, Path.Root == MetaMachine, Path.Value == [T] {
        machine[keyPath: attribute.path].move(fromOffsets: source, toOffset: destination)
        return .success(false)
    }
    
    func newDependency(_ dependency: MachineDependency, machine: inout MetaMachine) -> Result<Bool, AttributeError<MetaMachine>> {
        .failure(AttributeError<MetaMachine>(message: "Currently not supported.", path: machine.path.dependencies))
    }

    private func createState(named name: String, forMachine machine: MetaMachine) throws -> State {
        guard
            machine.attributes.count == 3,
            machine.semantics == .vhdl
        else {
            throw ValidationError(message: "Missing attributes in machine", path: MetaMachine.path.attributes)
        }
        let actions = ["OnEntry", "OnExit", "Internal", "OnSuspend", "OnResume"]
        guard
            let variables = machine.attributes.first(where: { $0.name == "variables" }),
            let externalSignals = variables.attributes["external_signals"]?.tableValue
        else {
            fatalError("Cannot find variables when creating new state.")
        }
        let externals = externalSignals.map { $0[2].lineValue }
        let defaultActionOrder = [["OnResume", "OnEntry"], ["OnExit", "Internal"], ["OnSuspend"]]
        return State(
            name: name,
            actions: actions.map { Action(name: $0, implementation: Code(""), language: .vhdl) },
            transitions: [],
            attributes: [
                AttributeGroup(
                    name: "variables",
                    fields: [
                        Field(name: "externals", type: .table(columns: [
                            ("name", .enumerated(validValues: Set(externals)))
                        ])),
                        Field(name: "state_signals", type: .table(columns: [
                            ("type", .expression(language: .vhdl)),
                            ("name", .line),
                            ("value", .expression(language: .vhdl)),
                            ("comment", .line)
                        ])),
                        Field(name: "state_variables", type: .table(columns: [
                            ("type", .expression(language: .vhdl)),
                            ("lower_range", .line),
                            ("upper_range", .line),
                            ("name", .line),
                            ("value", .expression(language: .vhdl)),
                            ("comment", .line)
                        ]))
                    ],
                    attributes: [
                        "externals": .table([], columns: [
                            ("name", .enumerated(validValues: Set(externals)))
                        ]),
                        "state_signals": .table(
                            [],
                            columns: [
                                ("type", .expression(language: .vhdl)),
                                ("name", .line),
                                ("value", .expression(language: .vhdl)),
                                ("comment", .line)
                            ]
                        ),
                        "state_variables": .table(
                            [],
                            columns: [
                                ("type", .expression(language: .vhdl)),
                                ("lower_range", .line),
                                ("upper_range", .line),
                                ("name", .line),
                                ("value", .expression(language: .vhdl)),
                                ("comment", .line)
                            ]
                        )
                    ],
                    metaData: [:]
                ),
                AttributeGroup(
                    name: "actions",
                    fields: [
                        Field(name: "action_names", type: .table(columns: [
                            ("name", .line)
                        ])),
                        Field(name: "action_order", type: .table(columns: [
                            ("timeslot", .integer),
                            ("action", .enumerated(validValues: Set(actions)))
                        ]))
                    ],
                    attributes: [
                        "action_names": .table(actions.map { [LineAttribute.line($0)] }, columns: [
                            ("name", .line)
                        ]),
                        "action_order": .table(toLineAttribute(actionOrder: defaultActionOrder, validValues: Set(actions)), columns: [
                            ("timeslot", .integer),
                            ("action", .enumerated(validValues: Set(actions)))
                        ])
                    ],
                    metaData: [:]
                )
            ]
        )
    }

    func newState(machine: inout MetaMachine) -> Result<Bool, AttributeError<MetaMachine>> {
        let name = "State"
        if nil == machine.states.first(where: { $0.name == name }) {
            do {
                machine.states.append(try self.createState(named: name, forMachine: machine))
            } catch let e as AttributeError<MetaMachine> {
                return .failure(e)
            } catch {
                return .failure(AttributeError(message: "Unable to create new state", path: MetaMachine.path.states))
            }
            self.syncSuspendState(machine: &machine)
            return .success(true)
        }
        var num = 0
        var stateName: String
        repeat {
            stateName = name + "\(num)"
            num += 1
        } while (nil != machine.states.reversed().first(where: { $0.name == stateName }))
        do {
            try machine.states.append(self.createState(named: stateName, forMachine: machine))
        } catch let e as AttributeError<MetaMachine> {
            return .failure(e)
        } catch {
            return .failure(AttributeError(message: "Unable to create new state", path: MetaMachine.path.states))
        }
        self.syncSuspendState(machine: &machine)
        return .success(true)
    }

    private func syncSuspendState(machine: inout MetaMachine) {
        let validValues = Set(machine.states.map(\.name) + [""])
        let currentValue = machine.attributes[3].attributes["suspended_state"]?.enumeratedValue ?? ""
        let newValue = validValues.contains(currentValue) ? currentValue : ""
        machine.attributes[3].fields[1].type = .enumerated(validValues: validValues)
        machine.attributes[3].attributes["suspended_state"] = .enumerated(newValue, validValues: validValues)
    }

    func newTransition(source: StateName, target: StateName, condition: Expression?, machine: inout MetaMachine) -> Result<Bool, AttributeError<MetaMachine>> {
        guard
            let index = machine.states.indices.first(where: { machine.states[$0].name == source }),
            nil != machine.states.first(where: { $0.name == target })
        else {
            return .failure(ValidationError(message: "You must attach a transition to a source and target state", path: MetaMachine.path))
        }
        machine.states[index].transitions.append(Transition(condition: condition, target: target))
        return .success(false)
    }
    
    func delete(dependencies: IndexSet, machine: inout MetaMachine) -> Result<Bool, AttributeError<MetaMachine>> {
        .failure(AttributeError<MetaMachine>(message: "Currently not supported.", path: machine.path.dependencies))
    }

    func delete(states: IndexSet, machine: inout MetaMachine) -> Result<Bool, AttributeError<MetaMachine>> {
        if
            let initialIndex = machine.states.enumerated().first(where: { $0.1.name == machine.initialState })?.0,
            states.contains(initialIndex)
        {
            return .failure(ValidationError(message: "You cannot delete the initial state", path: MetaMachine.path.states[initialIndex]))
        }
        machine.states = machine.states.enumerated().filter { !states.contains($0.0) }.map { $1 }
        self.syncSuspendState(machine: &machine)
        return .success(true)
    }
    
    func delete(transitions: IndexSet, attachedTo sourceState: StateName, machine: inout MetaMachine) -> Result<Bool, AttributeError<MetaMachine>> {
        guard let stateIndex = machine.states.firstIndex(where: { $0.name == sourceState }) else {
            return .failure(ValidationError(message: "Unable to find state with name \(sourceState)", path: MetaMachine.path.states))
        }
        machine.states[stateIndex].transitions = machine.states[stateIndex].transitions.enumerated().filter { !transitions.contains($0.0) }.map { $1 }
        return .success(false)
    }
    
    func deleteDependency(atIndex index: Int, machine: inout MetaMachine) -> Result<Bool, AttributeError<MetaMachine>> {
        .failure(AttributeError<MetaMachine>(message: "Currently not supported.", path: machine.path.dependencies))
    }

    func deleteState(atIndex index: Int, machine: inout MetaMachine) -> Result<Bool, AttributeError<MetaMachine>> {
        if machine.states.count >= index {
            return .failure(ValidationError(message: "Can't delete state that doesn't exist", path: MetaMachine.path.states))
        }
        if machine.states[index].name == machine.initialState {
            return .failure(ValidationError(message: "Can't delete the initial state", path: MetaMachine.path.states[index]))
        }
        machine.states.remove(at: index)
        self.syncSuspendState(machine: &machine)
        return .success(true)
    }

    func deleteTransition(atIndex index: Int, attachedTo sourceState: StateName, machine: inout MetaMachine) -> Result<Bool, AttributeError<MetaMachine>> {
        guard let index = machine.states.indices.first(where: { machine.states[$0].name == sourceState }) else {
            return .failure(ValidationError(message: "Cannot delete a transition attached to a state that does not exist", path: MetaMachine.path.states))
        }
        guard machine.states[index].transitions.count >= index else {
            return .failure(ValidationError(message: "Cannot delete transition that does not exist", path: MetaMachine.path.states[index].transitions))
        }
        machine.states[index].transitions.remove(at: index)
        return .success(false)
    }

    func deleteItem<Path, T>(attribute: Path, atIndex index: Int, machine: inout MetaMachine) -> Result<Bool, AttributeError<Path.Root>> where Path : PathProtocol, Path.Root == MetaMachine, Path.Value == [T] {
        if machine[keyPath: attribute.path].count <= index || index < 0 {
            return .failure(ValidationError(message: "Invalid index '\(index)'", path: attribute))
        }
        if attribute.path == machine.path.attributes[0].attributes["clocks"].wrappedValue.blockAttribute.tableValue.path {
            guard let clocks = machine.attributes[0].attributes["clocks"]?.tableValue else {
                fatalError("No clocks")
            }
            guard clocks.count > index else {
                return .failure(ValidationError(message: "Trying to delete clock that doesn't exist", path: attribute))
            }
            guard
                let old = machine.attributes[0].attributes["driving_clock"]?.enumeratedValue,
                var validValues = machine.attributes[0].attributes["driving_clock"]?.enumeratedValidValues
            else {
                fatalError("Machine does not have a driving clock")
            }
            let clock = clocks[index][0].lineValue
            guard old != clock else {
                return .failure(ValidationError(message: "Cannot remove driving clock", path: attribute))
            }
            machine[keyPath: attribute.path].remove(at: index)
            validValues.remove(clock)
            machine.attributes[0].attributes["driving_clock"] = Attribute(lineAttribute: .enumerated(old, validValues: validValues))
            return .success(true)
        }
        let signalPath = machine.path.attributes[0].attributes["external_signals"].wrappedValue.blockAttribute.tableValue.path
        if attribute.path == signalPath {
            guard
                machine.attributes[0].attributes["external_signals"].wrappedValue.tableValue.count > index
            else {
                fatalError("Failed to get signal name")
            }
            let variableName = machine.attributes[0].attributes["external_signals"].wrappedValue.tableValue[index][2].lineValue
            machine[keyPath: attribute.path].remove(at: index)
            machine.states.indices.forEach {
                machine.states[$0].attributes[0].attributes["externals"]?.enumerableCollectionValidValues.remove(variableName)
                machine.states[$0].attributes[0].attributes["externals"]?.enumerableCollectionValue.remove(variableName)
            }
            return .success(false)
        }
        machine[keyPath: attribute.path].remove(at: index)
        return .success(false)
    }

    private func changeName(ofState index: Int, to stateName: StateName, machine: inout MetaMachine) throws {
        let currentName = machine.states[index].name
        if currentName == stateName {
            return
        }
        if Set(machine.states.map(\.name)).contains(stateName) {
            throw ValidationError(message: "Cannot rename state to '\(stateName)' since a state with that name already exists", path: machine.path.states[index].name)
        }
        machine[keyPath: machine.path.states[index].name.path] = stateName
        if machine.initialState == currentName {
            machine.initialState = stateName
        }
        if machine.attributes[3].attributes["suspended_state"]!.enumeratedValue == currentName {
            machine.attributes[3].attributes["suspended_state"]!.enumeratedValue = stateName
        }
        self.syncSuspendState(machine: &machine)
    }

    private func whitelist(forMachine machine: MetaMachine) -> [AnyPath<MetaMachine>] {
        let machinePaths = [
            AnyPath(machine.path.name),
            AnyPath(machine.path.initialState),
            AnyPath(machine.path.attributes[0].attributes),
            AnyPath(machine.path.attributes[1].attributes),
            AnyPath(machine.path.attributes[2].attributes),
            AnyPath(machine.path.attributes[3].attributes)
        ]
        let statePaths: [AnyPath<MetaMachine>] = machine.states.indices.flatMap { (stateIndex) -> [AnyPath<MetaMachine>] in
            let attributes = [
                AnyPath(machine.path.states[stateIndex].name),
                AnyPath(machine.path.states[stateIndex].attributes[0].attributes),
                AnyPath(machine.path.states[stateIndex].attributes[1].attributes)
            ]
            let actions = machine.states[stateIndex].actions.indices.map {
                AnyPath(machine.path.states[stateIndex].actions[$0].implementation)
            }
            let transitions = machine.states[stateIndex].transitions.indices.flatMap {
                return [
                    AnyPath(machine.path.states[stateIndex].transitions[$0].condition),
                    AnyPath(machine.path.states[stateIndex].transitions[$0].target)
                ]
            }
            return attributes + actions + transitions
        }
        return machinePaths + statePaths
    }

    func modify<Path>(attribute: Path, value: Path.Value, machine: inout MetaMachine) -> Result<Bool, AttributeError<Path.Root>> where Path : PathProtocol, Path.Root == MetaMachine {
        if let index = machine.states.indices.first(where: { MetaMachine.path.states[$0].name.path == attribute.path }) {
            guard let stateName = value as? StateName else {
                return .failure(ValidationError(message: "Invalid value \(value)", path: attribute))
            }
            do {
                try self.changeName(ofState: index, to: stateName, machine: &machine)
            } catch let e as AttributeError<MetaMachine> {
                return .failure(e)
            } catch {
                return .failure(AttributeError(message: "Unable to change name of state", path: attribute))
            }
            machine[keyPath: attribute.path] = value
            return .success(true)
        }
        if let _ = machine.attributes[0].attributes["clocks"].wrappedValue.tableValue.indices.first(where: { (index) -> Bool in
            let clocksPath = MetaMachine.path.attributes[0].attributes["clocks"].wrappedValue.blockAttribute.tableValue
            return clocksPath[index][0].path == attribute.path ||
                clocksPath[index][0].lineValue.path == attribute.path
        }) {
            guard let newValue = (value as? Attribute)?.lineValue ?? (value as? LineAttribute)?.lineValue ?? (value as? String) else {
                return .failure(ValidationError(message: "Invalid value \(value)", path: attribute))
            }
            guard
                let drivingClock = machine.attributes[0].attributes["driving_clock"]?.enumeratedValue,
                var validValues = machine.attributes[0].attributes["driving_clock"]?.enumeratedValidValues
            else {
                fatalError("No driving clock")
            }
            guard
                let currentValue = (machine[keyPath: attribute.path] as? Attribute)?.lineValue ??
                    (machine[keyPath: attribute.path] as? LineAttribute)?.lineValue ??
                    (machine[keyPath: attribute.path] as? String)
            else {
                return .failure(ValidationError(message: "Failed to cast value to string", path: attribute))
            }
            validValues.remove(currentValue)
            validValues.insert(newValue)
            if drivingClock == currentValue {
                machine.attributes[0].attributes["driving_clock"] = Attribute(lineAttribute: .enumerated(newValue, validValues: validValues))
            } else {
                machine.attributes[0].attributes["driving_clock"] = Attribute(lineAttribute: .enumerated(drivingClock, validValues: validValues))
            }
            machine[keyPath: attribute.path] = value
            return .success(true)
        }
        if let _ = machine.attributes[0].attributes["external_signals"].wrappedValue.tableValue.indices.first(where: {
            let signalPath = machine.path.attributes[0].attributes["external_signals"].wrappedValue.blockAttribute.tableValue
            return signalPath[$0][2].path == attribute.path ||
                signalPath[$0][2].lineValue.path == attribute.path
        }) {
            guard let newValue = (value as? Attribute)?.lineValue ?? (value as? LineAttribute)?.lineValue ?? (value as? String) else {
                return .failure(ValidationError(message: "Invalid value \(value)", path: attribute))
            }
            guard
                let currentValue = (machine[keyPath: attribute.path] as? Attribute)?.lineValue ??
                    (machine[keyPath: attribute.path] as? LineAttribute)?.lineValue ??
                    (machine[keyPath: attribute.path] as? String)
            else {
                return .failure(ValidationError(message: "Failed to cast value to string", path: attribute))
            }
            machine[keyPath: attribute.path] = value
            machine.states.indices.forEach {
                if machine.states[$0].attributes[0].attributes["externals"]?.enumerableCollectionValue.contains(currentValue) ?? false {
                    machine.states[$0].attributes[0].attributes["externals"]?.enumerableCollectionValue.remove(currentValue)
                    machine.states[$0].attributes[0].attributes["externals"]?.enumerableCollectionValue.insert(newValue)
                }
                machine.states[$0].attributes[0].attributes["externals"]?.enumerableCollectionValidValues.remove(currentValue)
                machine.states[$0].attributes[0].attributes["externals"]?.enumerableCollectionValidValues.insert(newValue)
            }
            return .success(false)
        }
//        if let _ = machine.attributes[0].attributes["external_variables"].wrappedValue.tableValue.indices.first(where: {
//            let variablePath = machine.path.attributes[0].attributes["external_variables"].wrappedValue.blockAttribute.tableValue
//            return variablePath[$0][1].path == attribute.path ||
//                variablePath[$0][1].lineValue.path == attribute.path
//        }) {
//            guard let newValue = (value as? Attribute)?.lineValue ?? (value as? LineAttribute)?.lineValue ?? (value as? String) else {
//                return .failure(ValidationError(message: "Invalid value \(value)", path: attribute))
//            }
//            guard
//                let currentValue = (machine[keyPath: attribute.path] as? Attribute)?.lineValue ??
//                    (machine[keyPath: attribute.path] as? LineAttribute)?.lineValue ??
//                    (machine[keyPath: attribute.path] as? String)
//            else {
//                return .failure(ValidationError(message: "Failed to cast value to string", path: attribute))
//            }
//            machine[keyPath: attribute.path] = value
//            machine.states.indices.forEach {
//                if machine.states[$0].attributes[0].attributes["externals"]?.enumerableCollectionValue.contains(currentValue) ?? false {
//                    machine.states[$0].attributes[0].attributes["externals"]?.enumerableCollectionValue.remove(currentValue)
//                    machine.states[$0].attributes[0].attributes["externals"]?.enumerableCollectionValue.insert(newValue)
//                }
//                machine.states[$0].attributes[0].attributes["externals"]?.enumerableCollectionValidValues.remove(currentValue)
//                machine.states[$0].attributes[0].attributes["externals"]?.enumerableCollectionValidValues.insert(newValue)
//            }
//            return .success(false)
//        }
        machine[keyPath: attribute.path] = value
        return .success(false)
    }

    func validate(machine: MetaMachine) throws {
        try VHDLMachinesValidator().validate(machine: machine)
    }


}
