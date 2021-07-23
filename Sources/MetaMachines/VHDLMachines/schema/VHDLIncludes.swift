//
//  File.swift
//  
//
//  Created by Morgan McColl on 23/7/21.
//

import Foundation
import Attributes

struct VHDLIncludes: GroupProtocol {
    
    public typealias Root = MetaMachine
    
    let path = MetaMachine.path.attributes[2]
    
    @CodeProperty(label: "includes", language: .vhdl)
    var includes
    
    @CodeProperty(label: "architecture_head", language: .vhdl)
    var architectureHead
    
    @CodeProperty(label: "architecture_body", language: .vhdl)
    var architectureBody
    
}
