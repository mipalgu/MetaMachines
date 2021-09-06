//
//  File.swift
//  
//
//  Created by Morgan McColl on 4/6/21.
//

import Foundation
import Attributes

public protocol MachineModifier {
    
    mutating func didModify<Path: PathProtocol>(attribute: Path, oldValue: Path.Value, newValue: Path.Value, machine: inout MetaMachine) -> Result<Bool, AttributeError<Path.Root>> where Path.Root == MetaMachine
    
    func validate(machine: MetaMachine) throws
    
}
