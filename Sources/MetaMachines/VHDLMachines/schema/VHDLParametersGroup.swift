//
//  File.swift
//  
//
//  Created by Morgan McColl on 7/6/21.
//

import Foundation
import Attributes

struct VHDLParametersGroup: GroupProtocol {
  
    public typealias Root = MetaMachine
    
    let path = MetaMachine.path.attributes[0]
    
    @TriggerBuilder<MetaMachine>
    var triggers: some TriggerProtocol {
        WhenChanged(isParameterised).sync(target: path(for: somethingElse))
        WhenChanged(isParameterised).sync(target: path(for: somethingElse))
    }
    
    @BoolProperty(label: "is_parameterised", validation: .required())
    var isParameterised
    
    @BoolProperty(label: "something_else", validation: .required())
    var somethingElse
    
}
