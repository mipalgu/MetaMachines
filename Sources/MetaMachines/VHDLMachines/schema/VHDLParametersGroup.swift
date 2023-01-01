//
//  File.swift
//  
//
//  Created by Morgan McColl on 7/6/21.
//

import Attributes
import Foundation

/// The group responsible for defining the signals for a *parameterised* VHDL machine.
struct VHDLParametersGroup: GroupProtocol {

    /// The root is a `MetaMachine`.
    typealias Root = MetaMachine

    /// The path to the group this schema corresponds too.
    let path = MetaMachine.path.attributes[1]

    /// The input signals to the parameterised machine.
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
        ],
        validation: { $0.unique { $0.map { $0[1] } }.maxLength(128) }
    )
    var parameters

    /// The signals returned by the parameterised machine.
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
        ],
        validation: { $0.unique { $0.map { $0[1] } }.maxLength(128) }
    )
    var returns

    /// Whether the machine is parameterised.
    @BoolProperty(label: "is_parameterised")
    var isParameterised

    /// The triggers that make the signals available/unavailable when the machine is parameterised.
    @TriggerBuilder<MetaMachine>
    var triggers: AnyTrigger<MetaMachine> {
        WhenTrue(isParameterised, makeAvailable: parameters)
        WhenTrue(isParameterised, makeAvailable: returns)
        WhenFalse(isParameterised, makeUnavailable: parameters)
        WhenFalse(isParameterised, makeUnavailable: returns)
    }

}
