//
//  File.swift
//  File
//
//  Created by Morgan McColl on 28/7/21.
//

import Attributes
import Foundation

struct VHDLStateVariables: GroupProtocol {

    public typealias Root = MetaMachine

    let path = CollectionSearchPath(
        collectionPath: MetaMachine.path.states, elementPath: Path(State.self).attributes[0]
    )

    @EnumerableCollectionProperty(label: "externals", validValues: [], validation: { $0.unique() })
    var externals

    @TableProperty(
        label: "state_signals",
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
        ],
        validation: { $0.unique { $0.map { $0[1] } } }
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
                    .greyList(VHDLReservedWords.variableTypes)
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
        ],
        validation: { $0.unique { $0.map { $0[3] } } }
    )
    var stateVariables

}
