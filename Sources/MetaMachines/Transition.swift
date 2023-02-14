/*
 * Transition.swift
 * Machines
 *
 * Created by Callum McColl on 29/10/20.
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

/// A transition represents a logical condition that will cause a machine to change state. For most
/// implementations, the condition is a boolean expression that is evaluated to determine whether
/// the transition should fire.
public struct Transition: Hashable, Codable {

    /// The condition that will cause the transition to fire.
    public var condition: Expression?

    /// The state that the machine will transition to if the condition is true.
    public var target: StateName

    /// The attributes for the transition view.
    public var attributes: [AttributeGroup]

    /// The meta data for the transition view.
    public var metaData: [AttributeGroup]

    /// Creates a new transition with the given condition, target state, attributes and meta data.
    /// - Parameters:
    ///  - condition: The condition that will cause the transition to fire.
    ///  - target: The state that the machine will transition to if the condition is true.
    ///  - attributes: The attributes for the transition view.
    ///  - metaData: The meta data for the transition view.
    public init(
        condition: Code? = nil,
        target: StateName,
        attributes: [AttributeGroup] = [],
        metaData: [AttributeGroup] = []
    ) {
        self.condition = condition
        self.target = target
        self.attributes = attributes
        self.metaData = metaData
    }

    /// The target state a machine will transition to when this transition fires.
    /// - Parameter machine: The machine that this transition belongs to.
    /// - Returns: The target state of this transition.
    public func targetState(in machine: MetaMachine) -> State {
        machine.states.first { $0.name == target }!
    }

}
