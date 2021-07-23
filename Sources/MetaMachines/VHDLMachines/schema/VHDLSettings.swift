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
    
    let path = MetaMachine.path.attributes[2]
    
    @EnumeratedProperty(label: "suspended_state", validValues: [], validation: .required())
    var suspendedState
    
    @EnumeratedProperty(label: "initial_state", validValues: [], validation: .required().notEmpty())
    var initialState
    
}
