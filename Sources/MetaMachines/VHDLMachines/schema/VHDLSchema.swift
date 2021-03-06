//
//  File.swift
//  
//
//  Created by Morgan McColl on 7/6/21.
//

import Foundation
import Attributes

struct VHDLSchema: MachineSchema {
    
    var dependencyLayout: [Field]
    
    var stateSchema = VHDLStateSchema()
    
    var transitionSchema = VHDLTransitionsSchema()
    
    @Group
    var variables = VHDLVariablesGroup()
    
    @Group
    var parameters = VHDLParametersGroup()
    
    @Group
    var includes = VHDLIncludes()
    
    @Group
    var settings = VHDLSettings()
    
}
