//
//  File.swift
//  
//
//  Created by Morgan McColl on 4/6/21.
//

import Attributes
import Foundation

/// A protocol that defines types that can react to the modification of a machine.
public protocol MachineModifier {

    /// Enact a function that executes when a machine is modified.
    /// - Parameters:
    ///   - attribute: The path to the attribute that was modified.
    ///   - oldValue: The value of the attribute before it was modified.
    ///   - newValue: The value of the attribute after it was modified.
    ///   - machine: The machine that was modified.
    /// - Returns: Whether this function was successful or not.
    mutating func didModify<Path: PathProtocol>(
        attribute: Path, oldValue: Path.Value, newValue: Path.Value, machine: inout MetaMachine
    ) -> Result<Bool, AttributeError<Path.Root>> where Path.Root == MetaMachine

    /// Validate the machine.
    /// - Parameter machine: The machine to validate.
    /// - Throws: An error if the machine is invalid.
    func validate(machine: MetaMachine) throws

}
