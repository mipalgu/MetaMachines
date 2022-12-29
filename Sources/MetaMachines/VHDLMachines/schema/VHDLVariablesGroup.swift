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
        newClocks
        // Need to add trigger for renaming clock
        // Need to add trigger for CUD operations on external variables -> Affects state external vars
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
            table.notEmpty()
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
            .expression(label: "value", language: .vhdl),
            .line(label: "comment")
        ]
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
            .expression(label: "value", language: .vhdl),
            .line(label: "comment")
        ]
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
            .expression(label: "value", language: .vhdl),
            .line(label: "comment")
        ]
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
            .expression(label: "value", language: .vhdl),
            .line(label: "comment")
        ]
    )
    var machineSignals

    /// The trigger used when a new clock is created. This trigger will update the driving clock attribute to
    /// include the new clock in its valid values.
    @TriggerBuilder<MetaMachine>
    private var newClocks: AnyTrigger<MetaMachine> {
        WhenChanged(clocks).sync(
            target: path.attributes["driving_clock"].wrappedValue
        ) { clocksAttribute, oldValue in
            let validValues = Set(clocksAttribute.tableValue.map { clockLine in
                clockLine[0].lineValue
            })
            let enumeratedOldValue = oldValue.enumeratedValue
            let selected = validValues.contains(enumeratedOldValue) ? enumeratedOldValue :
                validValues.min() ?? ""
            return Attribute.enumerated(selected, validValues: validValues)
        }
        WhenChanged(clocks).sync(
            target: MetaMachine.path.vhdlSchema.wrappedValue.variables.$drivingClock
        ) { clockAttribute, _ in
            let validValues = Set(clockAttribute.tableValue.map { clockLine in
                clockLine[0].lineValue
            })
            return EnumeratedProperty(label: "driving_clock", validValues: validValues) { $0.notEmpty() }
        }
    }

}
