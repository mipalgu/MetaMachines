//
//  File.swift
//  File
//
//  Created by Morgan McColl on 15/9/21.
//

import Foundation
import Attributes

struct CXXVariables: GroupProtocol {
    
    public typealias Root = MetaMachine
    
    public let path = MetaMachine.path.attributes[0]
    
    @TableProperty
    var machineVariables: SchemaAttribute
    
    init(semantics: CXXSemantics) {
        self._machineVariables = TableProperty(
            label: "machine_variables",
            columns: [
                .expression(label: "type", language: semantics.language, validation: .required().maxLength(255).notEmpty()),
                .line(label: "name", validation: .required().notEmpty().maxLength(255)),
                .expression(label: "value", language: semantics.language, validation: .required().maxLength(255)),
                .line(label: "comment", validation: .required().maxLength(255))
            ],
            validation: { table in
                table.unique { $0.map { $0[1].lineValue } }
            }
        )
    }
    
}
