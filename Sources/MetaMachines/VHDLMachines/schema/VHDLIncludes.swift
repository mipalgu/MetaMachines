//
//  File.swift
//  
//
//  Created by Morgan McColl on 23/7/21.
//

import Attributes
import Foundation

/// The includes group that allows user to specify the includes for the VHDL code. This group also allows
/// users to add in custom code in the architecture head and body.
struct VHDLIncludes: GroupProtocol {

    /// The root is a meta machine.
    typealias Root = MetaMachine

    /// This group is located at index 2 in the attributes array of the meta machine.
    let path = MetaMachine.path.attributes[2]

    /// The custom architecture body code of this machine.
    @CodeProperty(label: "architecture_body", language: .vhdl, validation: { $0.maxLength(1024) })
    var architectureBody

    /// The custom architecture head code of this machine.
    @CodeProperty(label: "architecture_head", language: .vhdl, validation: { $0.maxLength(1024) })
    var architectureHead

    /// The includes of this machine.
    @CodeProperty(label: "includes", language: .vhdl, validation: { $0.maxLength(1024) })
    var includes

}
