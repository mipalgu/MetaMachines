//
//  File.swift
//  File
//
//  Created by Morgan McColl on 15/9/21.
//

import Foundation
import Attributes

public struct CXXSchema: MachineSchema {

    let semantics: CXXSemantics
    
    public var dependencyLayout: [Field] = []
    
    public var stateSchema = CXXStateSchema()
    
    public var transitionSchema = EmptySchema<MetaMachine>()
    
    @Group var variables: CXXVariables
    
    public init?(semantics: MetaMachine.Semantics) {
        guard let cxxSemantics = CXXSemantics(semantics: semantics) else {
            return nil
        }
        self.semantics = cxxSemantics
        self.variables = CXXVariables(semantics: cxxSemantics)
    }
    
}
