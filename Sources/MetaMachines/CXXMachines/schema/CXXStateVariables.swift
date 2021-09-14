//
//  File.swift
//  File
//
//  Created by Morgan McColl on 15/9/21.
//

import Foundation
import Attributes

public struct CXXStateVariables: GroupProtocol {
    
    public typealias Root = MetaMachine
    
    public let path = CollectionSearchPath(
        collectionPath: MetaMachine.path.states,
        elementPath: Path(State.self).attributes[0]
    )
    
    @TableProperty
    var stateVariables: SchemaAttribute
    
    init(semantics: CXXSemantics) {
        self._stateVariables = TableProperty(
            label: "variables",
            columns: [
                .expression(label: "type", language: semantics.language, validation: .required().maxLength(255).notEmpty()),
                .line(label: "name", validation: .required().notEmpty().maxLength(255)),
                .expression(label: "value", language: semantics.language, validation: .optional().maxLength(255)),
                .line(label: "comment", validation: .optional().maxLength(255))
            ],
            validation: { table in
                table.unique { $0.map { $0[1].lineValue } }
            }
        )
    }
    
}
