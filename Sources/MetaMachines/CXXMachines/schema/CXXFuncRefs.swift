//
//  File.swift
//  File
//
//  Created by Morgan McColl on 15/9/21.
//

import Foundation
import Attributes

public struct CXXFuncRefs: GroupProtocol {
    
    public typealias Root = MetaMachine
    
    public let path = MetaMachine.path.attributes[1]
    
    @CodeProperty
    var funcRefs: SchemaAttribute
    
    init(semantics: CXXSemantics) {
        self._funcRefs = CodeProperty(
            label: "func_refs",
            language: semantics.language,
            validation: { code in
                code.maxLength(4096)
            }
        )
    }
    
}
