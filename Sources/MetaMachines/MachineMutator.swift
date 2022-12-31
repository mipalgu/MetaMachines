/*
 * MachineMutator.swift
 * Machines
 *
 * Created by Callum McColl on 13/11/20.
 * Copyright © 2020 Callum McColl. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above
 *    copyright notice, this list of conditions and the following
 *    disclaimer in the documentation and/or other materials
 *    provided with the distribution.
 *
 * 3. All advertising materials mentioning features or use of this
 *    software must display the following acknowledgement:
 *
 *        This product includes software developed by Callum McColl.
 *
 * 4. Neither the name of the author nor the names of contributors
 *    may be used to endorse or promote products derived from this
 *    software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * -----------------------------------------------------------------------
 * This program is free software; you can redistribute it and/or
 * modify it under the above terms or under the terms of the GNU
 * General Public License as published by the Free Software Foundation;
 * either version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, see http://www.gnu.org/licenses/
 * or write to the Free Software Foundation, Inc., 51 Franklin Street,
 * Fifth Floor, Boston, MA  02110-1301, USA.
 *
 */

import Attributes
import Foundation

/// A protocol for defining types that can mutate a ``MetaMachine``.
public protocol MachineMutator: DependencyLayoutContainer {

    /// Add an item to a table attributes in the machine.
    /// - Parameters:
    ///   - item: The item to add.
    ///   - attribute: The path to the table attribute.
    ///   - machine: The machine that contains the table attribute.
    /// - Returns: A result indicating whether the item was added successfully.
    func addItem<Path, T>(
        _ item: T, to attribute: Path, machine: inout MetaMachine
    ) -> Result<Bool, AttributeError<Path.Root>> where Path: PathProtocol,
        Path.Root == MetaMachine, Path.Value == [T]

    /// Move items within a table attribute in the machine.
    /// - Parameters:
    ///   - attribute: The path to the table attribute.
    ///   - machine: The machine that contains the table attribute.
    ///   - source: The indices of the items to move.
    ///   - destination: The index to move the items to.
    /// - Returns: Whether the items were moved successfully.
    func moveItems<Path: PathProtocol, T>(
        attribute: Path, machine: inout MetaMachine, from source: IndexSet, to destination: Int
    ) -> Result<Bool, AttributeError<Path.Root>> where Path.Root == MetaMachine, Path.Value == [T]

    /// Add a new dependency to the machine.
    /// - Parameters:
    ///   - dependency: The dependency to add.
    ///   - machine: The machine to add the dependency to.
    /// - Returns: Whether the dependency was added successfully.
    func newDependency(
        _ dependency: MachineDependency, machine: inout MetaMachine
    ) -> Result<Bool, AttributeError<MetaMachine>>

    /// Add a new state to the machine.
    /// - Parameter machine: The machine to add the state to.
    /// - Returns: Whether the state was added successfully.
    func newState(machine: inout MetaMachine) -> Result<Bool, AttributeError<MetaMachine>>

    /// Add a new transition to the machine.
    /// - Parameters:
    ///   - source: The name of the source state.
    ///   - target: The name of the target state.
    ///   - condition: The condition that must be met for the transition to occur.
    ///   - machine: The machine to add the transition to.
    /// - Returns: Whether the transition was added successfully.
    func newTransition(
        source: StateName, target: StateName, condition: Expression?, machine: inout MetaMachine
    ) -> Result<Bool, AttributeError<MetaMachine>>

    /// Delete multiple dependencies within a machine.
    /// - Parameters:
    ///   - dependencies: The indices of the dependencies to delete.
    ///   - machine: The machine to delete the dependencies from.
    /// - Returns: Whether the dependencies were deleted successfully.
    func delete(
        dependencies: IndexSet, machine: inout MetaMachine
    ) -> Result<Bool, AttributeError<MetaMachine>>

    /// Delete multiple states within a machine.
    /// - Parameters:
    ///   - states: The indices of the states to delete.
    ///   - machine: The machine to delete the states from.
    /// - Returns: Whether the states were deleted successfully.
    func delete(states: IndexSet, machine: inout MetaMachine) -> Result<Bool, AttributeError<MetaMachine>>

    /// Delete multiple transitions within a machine.
    /// - Parameters:
    ///   - transitions: The indices of the transitions to delete.
    ///   - sourceState: The name of the source state.
    ///   - machine: The machine to delete the transitions from.
    /// - Returns: Whether the transitions were deleted successfully.
    func delete(
        transitions: IndexSet, attachedTo sourceState: StateName, machine: inout MetaMachine
    ) -> Result<Bool, AttributeError<MetaMachine>>

    /// Delete a dependency from a machine.
    /// - Parameters:
    ///   - index: The index of the dependency to delete.
    ///   - machine: The machine to delete the dependency from.
    /// - Returns: Whether the dependency was deleted successfully.
    func deleteDependency(
        atIndex index: Int, machine: inout MetaMachine
    ) -> Result<Bool, AttributeError<MetaMachine>>

    /// Delete a state from a machine.
    /// - Parameters:
    ///   - index: The index of the state to delete.
    ///   - machine: The machine to delete the state from.
    /// - Returns: Whether the state was deleted successfully.
    func deleteState(
        atIndex index: Int, machine: inout MetaMachine
    ) -> Result<Bool, AttributeError<MetaMachine>>

    /// Delete a transition from a machine.
    /// - Parameters:
    ///   - index: The index of the transition to delete.
    ///   - sourceState: The name of the source state.
    ///   - machine: The machine to delete the transition from.
    /// - Returns: Whether the transition was deleted successfully.
    func deleteTransition(
        atIndex index: Int, attachedTo sourceState: StateName, machine: inout MetaMachine
    ) -> Result<Bool, AttributeError<MetaMachine>>

    /// Delete multiple items from a table attribute in the machine.
    /// - Parameters:
    ///   - attribute: The path to the table attribute.
    ///   - items: The indices of the items to delete.
    ///   - machine: The machine that contains the table attribute.
    /// - Returns: Whether the items were deleted successfully.
    func deleteItems<Path: PathProtocol, T>(
        table attribute: Path, items: IndexSet, machine: inout MetaMachine
    ) -> Result<Bool, AttributeError<Path.Root>> where Path.Root == MetaMachine, Path.Value == [T]

    /// Delete an item from a table attribute in the machine.
    /// - Parameters:
    ///   - attribute: The path to the table attribute.
    ///   - atIndex: The index of the item to delete.
    ///   - machine: The machine that contains the table attribute.
    /// - Returns: Whether the item was deleted successfully.
    func deleteItem<Path: PathProtocol, T>(
        attribute: Path, atIndex: Int, machine: inout MetaMachine
    ) -> Result<Bool, AttributeError<Path.Root>> where Path.Root == MetaMachine, Path.Value == [T]

    /// Mutate a value within an attribute in the machine.
    /// - Parameters:
    ///   - attribute: The path to the attribute.
    ///   - value: The new value for the attribute.
    ///   - machine: The machine that contains the attribute.
    /// - Returns: Whether the attribute was mutated successfully.
    func modify<Path: PathProtocol>(
        attribute: Path, value: Path.Value, machine: inout MetaMachine
    ) -> Result<Bool, AttributeError<Path.Root>> where Path.Root == MetaMachine

    /// Validate a machine.
    /// - Parameter machine: The machine to validate.
    /// - Throws: An error if the machine is invalid. 
    func validate(machine: MetaMachine) throws

}

/// MachineMutator default implementations.
extension MachineMutator {

    /// Delete multiple items from a table attribute in the machine.
    /// - Parameters:
    ///   - attribute: The path to the table attribute.
    ///   - items: The indices of the items to delete.
    ///   - machine: The machine that contains the table attribute.
    /// - Returns: Whether the items were deleted successfully.
    public func deleteItems<Path: PathProtocol, T>(
        table attribute: Path, items: IndexSet, machine: inout MetaMachine
    ) -> Result<Bool, AttributeError<Path.Root>> where Path.Root == MetaMachine, Path.Value == [T] {
        var triggers = false
        for index in items.sorted(by: >) {
            switch self.deleteItem(attribute: attribute, atIndex: index, machine: &machine) {
            case .failure(let error):
                return .failure(error)
            case .success(let triggersActivated):
                triggers = triggers || triggersActivated
            }
        }
        return .success(triggers)
    }

}
