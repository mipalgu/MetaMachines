//
//  File.swift
//  File
//
//  Created by Morgan McColl on 28/7/21.
//

import Foundation
import Attributes

struct VHDLStateSchema: SchemaProtocol {
    
    typealias Root = MetaMachine
    
    //Need to create triggers for state CUD operations
    
    @Group
    var variables = VHDLStateVariables()
    
    @Group
    var actions = VHDLStateActions()
    
}
