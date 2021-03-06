//
//  File.swift
//  
//
//  Created by Morgan McColl on 23/7/21.
//

import Foundation
import Attributes
import VHDLMachines

struct VHDLVariablesGroup: GroupProtocol {
    
    public typealias Root = MetaMachine
    
    let path = MetaMachine.path.attributes[0]
    
    @TriggerBuilder<MetaMachine>
    var trigger: some TriggerProtocol {
        //Trigger for adding and deleting clocks
        WhenChanged(clocks).sync(target: path.attributes["driving_clock"].wrappedValue, transform: { (clocksAttribute, oldValue) in
            let validValues = Set(clocksAttribute.tableValue.map { clockLine in
                clockLine[0].lineValue
            })
            let enumeratedOldValue = oldValue.enumeratedValue
            let selected = validValues.contains(enumeratedOldValue) ? enumeratedOldValue : validValues.first ?? ""
            return Attribute.enumerated(selected, validValues: validValues)
        })
        //Need to add trigger for renaming clock
        
        //Need to add trigger for CUD operations on external variables -> Affects state external vars
    }
    
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
                validation: .required().between(min: 0, max: 999)
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
    
    @EnumeratedProperty(
        label: "driving_clock",
        validValues: [],
        validation: { $0.notEmpty() }
    )
    var drivingClock
    
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
                    .greylist(VHDLReservedWords.signalTypes)
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
    
    @TableProperty(
        label: "generics",
        columns: [
            .expression(
                label: "type",
                language: .vhdl,
                validation:
                    .required()
                    .greylist(VHDLReservedWords.variableTypes)
                    .blacklist(VHDLReservedWords.signalTypes)
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
    var generics
    
    @TableProperty(
        label: "machine_variables",
        columns: [
            .expression(
                label: "type",
                language: .vhdl,
                validation:
                    .required()
                    .greylist(VHDLReservedWords.variableTypes)
                    .blacklist(VHDLReservedWords.signalTypes)
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
    var machineVariables
    
    @TableProperty(
        label: "machine_signals",
        columns: [
            .expression(
                label: "type",
                language: .vhdl,
                validation:
                    .required()
                    .greylist(VHDLReservedWords.signalTypes)
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
    
}
