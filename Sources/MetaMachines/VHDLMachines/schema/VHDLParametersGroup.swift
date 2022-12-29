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
    
    @BoolProperty(label: "is_parameterised")
    var isParameterised
    
    @TableProperty(
        label: "parameter_signals",
        columns: [
            .expression(
                label: "type",
                language: .vhdl,
                validation:
                    .required()
                    .greyList(VHDLReservedWords.signalTypes)
                    .blacklist(VHDLReservedWords.variableTypes)
                    .blacklist(VHDLReservedWords.reservedWords)
            ),
            .line(
                label: "name",
                validation:
                    .required()
                    .alphaunderscore()
                    .alphaunderscorefirst()
                    .minLength(1)
                    .maxLength(255)
                    .blacklist(VHDLReservedWords.allReservedWords)
            ),
            .expression(label: "value", language: .vhdl),
            .line(label: "comment")
        ]
    )
    var parameters
    
    @TableProperty(
        label: "returnable_signals",
        columns: [
            .expression(
                label: "type",
                language: .vhdl,
                validation:
                    .required()
                    .greyList(VHDLReservedWords.signalTypes)
                    .blacklist(VHDLReservedWords.variableTypes)
                    .blacklist(VHDLReservedWords.reservedWords)
            ),
            .line(
                label: "name",
                validation:
                    .required()
                    .alphaunderscore()
                    .alphaunderscorefirst()
                    .minLength(1)
                    .maxLength(255)
                    .blacklist(VHDLReservedWords.allReservedWords)
            ),
            .line(label: "comment")
        ]
    )
    var returns
    
    @TriggerBuilder<MetaMachine>
    var triggers: AnyTrigger<MetaMachine> {
        WhenTrue(isParameterised, makeAvailable: parameters)
        WhenTrue(isParameterised, makeAvailable: returns)
        WhenFalse(isParameterised, makeUnavailable: parameters)
        WhenFalse(isParameterised, makeUnavailable: returns)
    }
    
}
