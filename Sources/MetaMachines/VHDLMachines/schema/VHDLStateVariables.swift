//
//  File.swift
//  File
//
//  Created by Morgan McColl on 28/7/21.
//

import Attributes
import Foundation

/// The group providing the state variables for a particular state in a VHDL machine.
struct VHDLStateVariables: GroupProtocol {

    /// The root is a ``MetaMachine``.
    typealias Root = MetaMachine

    /// The search path to the attribute group this ``GroupProtocol`` represents.
    let path = CollectionSearchPath(
        collectionPath: MetaMachine.path.states, elementPath: Path(State.self).attributes[0]
    )

    /// Helper property for getting external variables.
    var externalValidValues: Set<String>? {
        guard
            case AttributeType.block(let attributes) = self.externals.type,
            case BlockAttributeType.enumerableCollection(let values) = attributes
        else {
            return nil
        }
        return values
    }

    /// The external variables used in this states execution.
    @EnumerableCollectionProperty(label: "externals", validValues: [], validation: { $0.unique() })
    var externals

    /// Any signals local to this state.
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

    /// Any variables local to this state.
    @TableProperty(
        label: "state_variables",
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
            .line(
                label: "lower_range",
                validation: .optional().numeric().maxLength(255)
            ),
            .line(
                label: "upper_range",
                validation: .optional().numeric().maxLength(255)
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
