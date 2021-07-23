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
    
    let path = MetaMachine.path.attributes[1]
    
    @TableProperty(
        label: "parameters",
        columns: [
            .expression(label: "type", language: .vhdl, validation: .required().greylist(VHDLReservedWords.signalTypes).blacklist(VHDLReservedWords.variableTypes)),
            .line(label: "name", validation: .required().alphaunderscore().alphaunderscorefirst().minLength(1).maxLength(255)),
            .expression(label: "value", language: .vhdl),
            .line(label: "comment")
        ]
    )
    var parameters
    
    @TableProperty(
        label: "returns",
        columns: [
            .expression(label: "type", language: .vhdl, validation: .required().greylist(VHDLReservedWords.signalTypes).blacklist(VHDLReservedWords.variableTypes)),
            .line(label: "name", validation: .required().alphaunderscore().alphaunderscorefirst().minLength(1).maxLength(255)),
            .expression(label: "value", language: .vhdl),
            .line(label: "comment")
        ]
    )
    var returns
    
    @TriggerBuilder<MetaMachine>
    var triggers: some TriggerProtocol {
        WhenTrue(isParameterised, makeAvailable: parameters)
        WhenTrue(isParameterised, makeAvailable: returns)
        WhenFalse(isParameterised, makeUnavailable: parameters)
        WhenFalse(isParameterised, makeUnavailable: returns)
    }
    
    @BoolProperty(label: "is_parameterised", validation: .required())
    var isParameterised
    
}
