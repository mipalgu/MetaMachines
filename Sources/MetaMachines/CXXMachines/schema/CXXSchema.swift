//
//  File.swift
//  File
//
//  Created by Morgan McColl on 15/9/21.
//

import Foundation
import Attributes

public struct CXXSchema: MachineSchema {
    
    public var dependencyLayout: [Field] = []
    
    public var stateSchema = CXXStateSchema()
    
    public var transitionSchema = EmptySchema<MetaMachine>()
    
    @Group var variables: CXXVariables
    
    @Group var funcRefs: CXXFuncRefs
    
    public init?(semantics: MetaMachine.Semantics) {
        guard let cxxSemantics = CXXSemantics(semantics: semantics) else {
            return nil
        }
        self.variables = CXXVariables(semantics: cxxSemantics)
        self.funcRefs = CXXFuncRefs(semantics: cxxSemantics)
    }
    
}
