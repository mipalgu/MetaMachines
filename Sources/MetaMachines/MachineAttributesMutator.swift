//
//  File.swift
//  
//
//  Created by Morgan McColl on 4/6/21.
//

import Foundation
import Attributes

public protocol MachineAttributesMutator {
    
    mutating func didAddItem<Path: PathProtocol, T>(_ item: T, to attribute: Path, machine: inout MetaMachine) -> Result<Bool, AttributeError<Path.Root>> where Path.Root == MetaMachine, Path.Value == [T]
    
    mutating func didMoveItems<Path: PathProtocol, T>(attribute: Path, machine: inout MetaMachine, from source: IndexSet, to destination: Int, items: [T]) -> Result<Bool, AttributeError<Path.Root>> where Path.Root == MetaMachine, Path.Value == [T]
    
    mutating func didDeleteItems<Path: PathProtocol, T>(table attribute: Path, indices: IndexSet, machine: inout MetaMachine, items: [T]) -> Result<Bool, AttributeError<Path.Root>> where Path.Root == MetaMachine, Path.Value == [T]
    
    mutating func didDeleteItem<Path: PathProtocol, T>(attribute: Path, atIndex: Int, machine: inout MetaMachine, item: T) -> Result<Bool, AttributeError<Path.Root>> where Path.Root == MetaMachine, Path.Value == [T]
}
