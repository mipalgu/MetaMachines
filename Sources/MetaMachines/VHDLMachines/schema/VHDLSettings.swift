//
//  File.swift
//  
//
//  Created by Morgan McColl on 23/7/21.
//

import Foundation
import Attributes

struct VHDLSettings: GroupProtocol {
    
    public typealias Root = MetaMachine
    
    let path = MetaMachine.path.attributes[3]
    
    @EnumeratedProperty(
        label: "suspended_state",
        validValues: []
    )
    var suspendedState
    
    @EnumeratedProperty(
        label: "initial_state",
        validValues: [],
        validation: { $0.notEmpty() }
    )
    var initialState
    
}
