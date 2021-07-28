//
//  File.swift
//  File
//
//  Created by Morgan McColl on 28/7/21.
//

import Foundation
import Attributes

struct VHDLStateActions: GroupProtocol {
    
    public typealias Root = MetaMachine
    
    let path = CollectionSearchPath(collectionPath: MetaMachine.path.states, elementPath: Path(State.self).attributes[1])
    
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
                    .maxLength(255)
                    .blacklist(VHDLReservedWords.allReservedWords)
            )
        ],
        validation: .required()
    )
    var actionNames
    
    @TableProperty(
        label: "action_order",
        columns: [
            .integer(label: "timeslot", validation: .required().between(min: 0, max: 255)),
            .enumerated(label: "action", validValues: [], validation: .required())
        ],
        validation: .required()
    )
    var actionOrder
    
}
