//
//  File.swift
//  File
//
//  Created by Morgan McColl on 28/7/21.
//

import Attributes
import Foundation

/// The schema for a VHDL state.
struct VHDLStateSchema: SchemaProtocol {

    /// The root is a ``MetaMachine``.
    typealias Root = MetaMachine

    // Need to create triggers for state CUD operations

    /// The variables local to the state.
    @Group
    var variables = VHDLStateVariables()

}
