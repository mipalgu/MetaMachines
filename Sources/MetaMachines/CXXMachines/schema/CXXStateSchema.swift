//
//  File.swift
//  File
//
//  Created by Morgan McColl on 15/9/21.
//

import Foundation
import Attributes

public struct CXXStateSchema: SchemaProtocol {
    
    public typealias Root = MetaMachine
    
    @Group var stateVariables: CXXStateVariables
    
    init(semantics: CXXSemantics) {
        self.stateVariables = CXXStateVariables(semantics: semantics)
    }
    
}
