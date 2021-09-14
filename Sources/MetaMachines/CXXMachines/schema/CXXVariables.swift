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
    
    let semantics: CXXSemantics
    
    @TableProperty
    var machineVariables: SchemaAttribute
    
    init(semantics: CXXSemantics) {
        self.semantics = semantics
        let language: (CXXSemantics) -> Language = {
            switch $0 {
            case .spartanfsm:
                return .vhdl
            default:
                return .cxx
            }
        }
        self._machineVariables = TableProperty(
            label: "type",
            columns: [
                .expression(label: "type", language: language(semantics), validation: .required().maxLength(255).notEmpty()),
                .line(label: "name", validation: .required().notEmpty()),
                .expression(label: "value", language: language(semantics), validation: .optional().maxLength(255)),
                .line(label: "comment", validation: .optional().maxLength(255))
            ],
            validation: { table in
                table.unique { $0.map { $0[1].lineValue } }
            }
        )
    }
    
}
