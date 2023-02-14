//
//  File.swift
//  
//
//  Created by Morgan McColl on 23/7/21.
//

import Attributes
import Foundation
import VHDLMachines

/// The group for defining variables and signals that have machine scope. This group also handles the external
/// variables that the machine is using.
struct VHDLVariablesGroup: GroupProtocol {

    /// The root is the `MetaMachine` that this group is a part of.
    typealias Root = MetaMachine

    /// The group that this schema is responsible for.
    let path = MetaMachine.path.attributes[0]

    /// The triggers for this group.
    @TriggerBuilder<MetaMachine>
    var triggers: AnyTrigger<Root> {
        renameClocks
        newClocks
        renameExternalVariable
        newExternalVariable
    }

    /// All of the clocks available to this machine.
    @TableProperty(
        label: "clocks",
        columns: [
            .line(
                label: "name",
                validation:
                    .required()
                    .alphaunderscore()
                    .alphaunderscorefirst()
                    .minLength(1)
                    .maxLength(255)
                    .blacklist(VHDLReservedWords.allReservedWords)
            ),
            .integer(
                label: "frequency",
                validation: .required().between(min: 1, max: 999)
            ),
            .enumerated(
                label: "unit",
                validValues: Set(
                    VHDLMachines.Clock.FrequencyUnit.allCases.map { $0.rawValue }
                ),
                validation: .required()
            )
        ],
        validation: { table in
            table.notEmpty().unique { $0.map { $0[0] } }.maxLength(128)
        }
    )
    var clocks

    /// The clock causing the machine to execute. The machine will continuously check the rising edge of the
    /// driving clock to control it's states execution.
    @EnumeratedProperty(
        label: "driving_clock",
        validValues: [],
        validation: { $0.notEmpty() }
    )
    var drivingClock

    /// The external signals available to the machine. These signals are not owned by the machine, but are
    /// used by the machine to drive/control external actuators/sensors.
    @TableProperty(
        label: "external_signals",
        columns: [
            .enumerated(
                label: "mode",
                validValues: Set(VHDLMachines.Mode.allCases.map { $0.rawValue }),
                validation: .required()
            ),
            .expression(
                label: "type",
                language: .vhdl,
                validation:
                    .required()
                    .greyList(VHDLReservedWords.signalTypes)
                    .blacklist(VHDLReservedWords.variableTypes)
                    .blacklist(VHDLReservedWords.reservedWords)
            ),
            .line(
                label: "name",
                validation:
                    .required()
                    .alphaunderscore()
                    .alphaunderscorefirst()
                    .minLength(1)
                    .maxLength(255)
                    .blacklist(VHDLReservedWords.allReservedWords)
            ),
            .expression(label: "value", language: .vhdl, validation: .optional().maxLength(128)),
            .line(label: "comment", validation: .optional().maxLength(128))
        ],
        validation: { table in
            table.unique { $0.map { $0[2] } }.maxLength(128)
        }
    )
    var externalVariables

    /// The generics that generalise the behaviour of the machine. This property directly maps to the generics
    /// in the entity statement of a VHDL file.
    @TableProperty(
        label: "generics",
        columns: [
            .expression(
                label: "type",
                language: .vhdl,
                validation:
                    .required()
                    .whitelist(VHDLReservedWords.variableTypes)
                    .blacklist(VHDLReservedWords.signalTypes)
                    .blacklist(VHDLReservedWords.reservedWords)
            ),
            .line(label: "lower_range", validation: .optional().numeric().maxLength(255)),
            .line(label: "upper_range", validation: .optional().numeric().maxLength(255)),
            .line(
                label: "name",
                validation:
                    .required()
                    .alphaunderscore()
                    .alphaunderscorefirst()
                    .minLength(1)
                    .maxLength(255)
                    .blacklist(VHDLReservedWords.allReservedWords)
            ),
            .expression(label: "value", language: .vhdl, validation: .optional().maxLength(128)),
            .line(label: "comment", validation: .optional().maxLength(128))
        ],
        validation: { table in
            table.unique { $0.map { $0[3] } }.maxLength(128)
        }
    )
    var generics

    /// The machine variables defined local to the machine and accessible to every state within the machine.
    /// Please note that these variables are not true signals, and therefore do not execute asynchronously
    /// like signals do. They are instead updated immediately with the machines clock without jitter.
    @TableProperty(
        label: "machine_variables",
        columns: [
            .expression(
                label: "type",
                language: .vhdl,
                validation:
                    .required()
                    .whitelist(VHDLReservedWords.variableTypes)
                    .blacklist(VHDLReservedWords.signalTypes)
                    .blacklist(VHDLReservedWords.reservedWords)
            ),
            .line(label: "lower_range", validation: .optional().numeric().maxLength(255)),
            .line(label: "upper_range", validation: .optional().numeric().maxLength(255)),
            .line(
                label: "name",
                validation:
                    .required()
                    .alphaunderscore()
                    .alphaunderscorefirst()
                    .minLength(1)
                    .maxLength(255)
                    .blacklist(VHDLReservedWords.allReservedWords)
            ),
            .expression(label: "value", language: .vhdl, validation: .optional().maxLength(128)),
            .line(label: "comment", validation: .optional().maxLength(128))
        ],
        validation: { table in
            table.unique { $0.map { $0[3] } }.maxLength(128)
        }
    )
    var machineVariables

    /// The machine signals local to the machine and accessible to every state within the machine.
    @TableProperty(
        label: "machine_signals",
        columns: [
            .expression(
                label: "type",
                language: .vhdl,
                validation:
                    .required()
                    .greyList(VHDLReservedWords.signalTypes)
                    .blacklist(VHDLReservedWords.variableTypes)
                    .blacklist(VHDLReservedWords.reservedWords)
            ),
            .line(
                label: "name",
                validation:
                    .required()
                    .alphaunderscore()
                    .alphaunderscorefirst()
                    .minLength(1)
                    .maxLength(255)
                    .blacklist(VHDLReservedWords.allReservedWords)
            ),
            .expression(label: "value", language: .vhdl, validation: .optional().maxLength(128)),
            .line(label: "comment", validation: .optional().maxLength(128))
        ],
        validation: { table in
            table.unique { $0.map { $0[1] } }.maxLength(128)
        }
    )
    var machineSignals

    /// A trigger that updates a machines states when an external variable is renamed.
    @TriggerBuilder<MetaMachine>
    private var renameExternalVariable: AnyTrigger<MetaMachine> {
        // swiftlint:disable closure_body_length
        AnyTrigger(
            Attributes.ForEach(CollectionSearchPath(
                collectionPath: path.attributes["external_signals"].wrappedValue.tableValue,
                elementPath: Path([LineAttribute].self)[2].lineValue
            )) { externalNamePath in
                Attributes.WhenChanged(externalNamePath).custom { machine in
                    guard
                        !machine.attributes.isEmpty,
                        let externals = machine.attributes[0].attributes["external_signals"],
                        var schema = machine.vhdlSchema
                    else {
                        return .failure(AttributeError(
                            message: "Cannot find external variables", path: AnyPath(externalNamePath)
                        ))
                    }
                    let externalNames = Set(externals.tableValue.compactMap {
                        $0.count >= 3 ? $0[2].lineValue : nil
                    })
                    schema.stateSchema.variables.$externals = EnumerableCollectionProperty(
                        label: "externals",
                        validValues: externalNames
                    ) {
                        $0.unique()
                    }
                    machine.vhdlSchema = schema
                    machine.states.indices.forEach { index in
                        if let fieldIndex = machine.states[index].attributes[0].fields.firstIndex(
                            where: { $0.name == "externals" }
                        ) {
                            machine.states[index].attributes[0].fields[fieldIndex].type =
                                .enumerableCollection(validValues: externalNames)
                        }
                        let existingExternals = machine.states[index].attributes[0].attributes["externals"]?
                            .enumerableCollectionValue ?? []
                        machine.states[index].attributes[0].attributes["externals"] = .enumerableCollection(
                            existingExternals.filter { externalNames.contains($0) },
                            validValues: externalNames
                        )
                    }
                    return .success(true)
                }
            }
        )
        // swiftlint:enable closure_body_length
    }

    /// Triggers that update the states external variables when a new one is added to the machine.
    @TriggerBuilder<MetaMachine>
    private var newExternalVariable: AnyTrigger<MetaMachine> {
        WhenChanged(externalVariables).sync(
            target: Path(MetaMachine.self).vhdlSchema.wrappedValue.stateSchema.variables.$externals
        ) { externalsNow, _ in
            let newExternals = Set(externalsNow.tableValue.map { $0[2].lineValue })
            return EnumerableCollectionProperty(label: "externals", validValues: newExternals) { $0.unique() }
        }
        WhenChanged(externalVariables).sync(
            target: CollectionSearchPath(
                collectionPath: Path(MetaMachine.self).states,
                elementPath: Path(State.self).attributes[0].attributes["externals"].wrappedValue
            )
        ) { externalsNow, oldStateExternals in
            let newExternals = Set(externalsNow.tableValue.map { $0[2].lineValue })
            let newValues = oldStateExternals.enumerableCollectionValue.filter { newExternals.contains($0) }
            return Attribute.enumerableCollection(newValues, validValues: newExternals)
        }
        WhenChanged(externalVariables).sync(target: CollectionSearchPath(
            collectionPath: Path(MetaMachine.self).states,
            elementPath: Path(State.self).attributes[0].fields
        )) { externalsNow, oldFields in
            guard let fieldIndex = (oldFields.firstIndex { $0.name == "externals" }) else {
                return oldFields
            }
            let newExternals = Set(externalsNow.tableValue.map { $0[2].lineValue })
            var newFields = oldFields
            let oldValue = newFields.remove(at: fieldIndex)
            newFields.append(
                Field(name: oldValue.name, type: .enumerableCollection(validValues: newExternals))
            )
            return newFields.sorted { $0.name < $1.name }
        }
    }

    // swiftlint:disable closure_body_length

    /// The trigger that causes the driving clock valid values to update when a clock is renamed.
    @TriggerBuilder<MetaMachine>
    private var renameClocks: AnyTrigger<MetaMachine> {
        AnyTrigger(Attributes.ForEach(
            CollectionSearchPath(
                collectionPath: path.attributes["clocks"].wrappedValue.tableValue,
                elementPath: Path([LineAttribute].self)[0].lineValue
            )
        ) { clockNamePath in
            Attributes.WhenChanged(clockNamePath).custom { machine in
                guard
                    !clockNamePath.isNil(machine),
                    let clockAttribute = machine.attributes[0].attributes["clocks"],
                    let drivingClock = machine.attributes[0].attributes["driving_clock"],
                    var schema = machine.vhdlSchema
                else {
                    return .failure(
                        AttributeError(message: "Cannot find clocks", path: AnyPath(clockNamePath))
                    )
                }
                let validValues = Set(clockAttribute.tableValue.map { clockLine in
                    clockLine[0].lineValue
                })
                if let drivingClockIndex = machine.attributes[0].fields.firstIndex(
                    where: { $0.name == "driving_clock" }
                ) {
                    machine.attributes[0].fields[drivingClockIndex].type = .enumerated(
                        validValues: validValues
                    )
                }
                let enumeratedOldValue = drivingClock.enumeratedValue
                let selected = validValues.contains(enumeratedOldValue) ? enumeratedOldValue :
                    machine[keyPath: clockNamePath.keyPath]
                machine.attributes[0].attributes["driving_clock"] = Attribute.enumerated(
                    selected, validValues: validValues
                )
                schema.variables.$drivingClock = syncSchema(clockAttribute: clockAttribute)
                machine.vhdlSchema = schema
                return .success(true)
            }
        })
    }

    // swiftlint:enable closure_body_length

    /// The trigger used when a new clock is created. This trigger will update the driving clock attribute to
    /// include the new clock in its valid values.
    @TriggerBuilder<MetaMachine>
    private var newClocks: AnyTrigger<MetaMachine> {
        WhenChanged(clocks).sync(
            target: path.attributes["driving_clock"].wrappedValue
        ) { clocksAttribute, oldValue in
            syncAttributes(clocksAttribute: clocksAttribute, oldValue: oldValue)
        }
        WhenChanged(clocks).sync(
            target: MetaMachine.path.vhdlSchema.wrappedValue.variables.$drivingClock
        ) { clockAttribute, _ in
            syncSchema(clockAttribute: clockAttribute)
        }
        WhenChanged(clocks).sync(target: self.path.fields) { newClocks, oldFields in
            guard let drivingClockIndex = oldFields.firstIndex(where: { $0.name == "driving_clock" }) else {
                return oldFields
            }
            let validValues = Set(newClocks.tableValue.map { $0[0].lineValue })
            var newFields = oldFields
            let oldValue = newFields.remove(at: drivingClockIndex)
            newFields.append(Field(name: oldValue.name, type: .enumerated(validValues: validValues)))
            return newFields.sorted { $0.name < $1.name }
        }
    }

    /// Update the driving_clock attributes from the clocks attribute.
    private func syncAttributes(clocksAttribute: Attribute, oldValue: Attribute) -> Attribute {
        let validValues = Set(clocksAttribute.tableValue.map { clockLine in
            clockLine[0].lineValue
        })
        let enumeratedOldValue = oldValue.enumeratedValue
        let selected = validValues.contains(enumeratedOldValue) ? enumeratedOldValue :
            validValues.min() ?? ""
        return Attribute.enumerated(selected, validValues: validValues)
    }

    /// Update the driving_clock schema property from the clocks attribute.
    private func syncSchema(clockAttribute: Attribute) -> EnumeratedProperty {
        let validValues = Set(clockAttribute.tableValue.map { clockLine in
            clockLine[0].lineValue
        })
        return EnumeratedProperty(label: "driving_clock", validValues: validValues) { $0.notEmpty() }
    }

}
