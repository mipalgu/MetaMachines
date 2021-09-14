//
//  File.swift
//  File
//
//  Created by Morgan McColl on 15/9/21.
//

import Foundation
import Attributes

public struct CXXSettings: GroupProtocol {
    
    public typealias Root = MetaMachine
    
    public let path = MetaMachine.path.attributes[3]
    
    @EnumeratedProperty(
        label: "suspended_state",
        validValues: [],
        validation: { state in
            state.maxLength(255)
        }
    )
    var suspendedState
    
}
