//
//  File.swift
//  
//
//  Created by Morgan McColl on 23/7/21.
//

import Attributes
import Foundation

/// A group for additional machine settings. This group specifies the initial and suspended state of the
/// machine.
struct VHDLSettings: GroupProtocol {

    /// The root is a ``MetaMachine``.
    typealias Root = MetaMachine

    /// The path to the group containing these settings.
    let path = MetaMachine.path.attributes[3]

    /// A property for setting the suspended state of the machine.
    @EnumeratedProperty(
        label: "suspended_state",
        validValues: []
    )
    var suspendedState

    /// A property for setting the initial state of the machine.
    @EnumeratedProperty(
        label: "initial_state",
        validValues: [],
        validation: { $0.notEmpty() }
    )
    var initialState

}
