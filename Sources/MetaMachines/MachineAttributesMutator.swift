//
//  File.swift
//  
//
//  Created by Morgan McColl on 4/6/21.
//

import Attributes
import Foundation

/// A protocol for defining types that can respond to the modification of a machine's attributes.
public protocol MachineAttributesMutator {

    /// Enact a function that executes when an attribute is added to a collection.
    /// - Parameters:
    ///   - item: The item that was added.
    ///   - attribute: The path to the attribute that was modified.
    ///   - machine: The machine that was modified.
    /// - Returns: Whether this function was successful or not.
    mutating func didAddItem<Path: PathProtocol, T>(
        _ item: T, to attribute: Path, machine: inout MetaMachine
    ) -> Result<Bool, AttributeError<Path.Root>> where Path.Root == MetaMachine, Path.Value == [T]

    /// Enact a function that executes when items within a table attribute are moved.
    /// - Parameters:
    ///   - attribute: The path to the attribute that was modified.
    ///   - machine: The machine that was modified.
    ///   - source: The indices of the items that were moved.
    ///   - destination: The index of the destination of the items.
    ///   - items: The items that were moved.
    /// - Returns: Whether this function was successful or not.
    mutating func didMoveItems<Path: PathProtocol, T>(
        attribute: Path, machine: inout MetaMachine, from source: IndexSet, to destination: Int, items: [T]
    ) -> Result<Bool, AttributeError<Path.Root>> where Path.Root == MetaMachine, Path.Value == [T]

    /// Enact a function that executes when multiple attributes are deleted.
    /// - Parameters:
    ///   - attribute: The path to the attribute that was modified.
    ///   - indices: The indices of the items that were deleted.
    ///   - machine: The machine that was modified.
    ///   - items: The items that were deleted.
    /// - Returns: Whether this function was successful or not.
    mutating func didDeleteItems<Path: PathProtocol, T>(
        table attribute: Path, indices: IndexSet, machine: inout MetaMachine, items: [T]
    ) -> Result<Bool, AttributeError<Path.Root>> where Path.Root == MetaMachine, Path.Value == [T]

    /// Enact a function that executes when an attribute is deleted from a collection.
    /// - Parameters:
    ///   - attribute: The path to the attribute that was modified.
    ///   - atIndex: The index of the item that was deleted.
    ///   - machine: The machine that was modified.
    ///   - item: The item that was deleted.
    /// - Returns: Whether this function was successful or not.
    mutating func didDeleteItem<Path: PathProtocol, T>(
        attribute: Path, atIndex: Int, machine: inout MetaMachine, item: T
    ) -> Result<Bool, AttributeError<Path.Root>> where Path.Root == MetaMachine, Path.Value == [T]

}
