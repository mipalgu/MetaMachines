//
//  File.swift
//  File
//
//  Created by Morgan McColl on 28/7/21.
//

import Attributes
import Foundation

/// The settings for a states actions.
struct VHDLStateActions: GroupProtocol {

    /// The root is a ``MetaMachine``.
    typealias Root = MetaMachine

    /// The search path that points to the group this schema represents.
    let path = CollectionSearchPath(
        collectionPath: MetaMachine.path.states, elementPath: Path(State.self).attributes[1]
    )

    /// The names of the actions in the state.
    @TableProperty(
        label: "action_names",
        columns: [
            .line(
                label: "name",
                validation:
                    .required()
                    .alphaunderscore()
                    .alphaunderscorefirst()
                    .minLength(1)
                    .maxLength(32)
                    .blacklist(VHDLReservedWords.allReservedWords)
            )
        ],
        validation: { $0.unique().maxLength(128) }
    )
    var actionNames

    /// The order the actions are executed in the state.
    @TableProperty(
        label: "action_order",
        columns: [
            .integer(label: "timeslot", validation: .required().between(min: 0, max: 255)),
            .enumerated(label: "action", validValues: [], validation: .required())
        ],
        validation: { table in
            table.notEmpty().maxLength(128)
        }
    )
    var actionOrder

}
