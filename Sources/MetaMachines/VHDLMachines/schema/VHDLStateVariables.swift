//
//  File.swift
//  File
//
//  Created by Morgan McColl on 28/7/21.
//

import Foundation
import Attributes

struct VHDLStateVariables: GroupProtocol {
    
    public typealias Root = MetaMachine
    
    let path = CollectionSearchPath(collectionPath: MetaMachine.path.states, elementPath: Path(State.self).attributes[0])
    
    @EnumeratedProperty(label: "externals", validValues: [], validation: .required())
    var externals
    
    @TableProperty(
        label: "state_signals",
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
        ],
        validation: .required()
    )
    var stateSignals
    
    @TableProperty(
        label: "state_variables",
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
                label: "lower_range",
                validation: .optional().numeric().minLength(1).maxLength(255)
            ),
            .line(
                label: "upper_range",
                validation: .optional().numeric().minLength(1).maxLength(255)
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
    var stateVariables
    
}
