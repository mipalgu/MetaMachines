/*
 * Action.swift
 * Machines
 *
 * Created by Callum McColl on 16/11/20.
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

/// An action is a piece of code that can be executed by a machine when it is in a particular state.
/// A state may contain many actions with a particular order that they are executed in.
public struct Action: Hashable, Codable {

    /// The name of the action.
    public var name: String

    /// The code within the action.
    public var implementation: Code

    /// The language that the actions code is written in.
    public var language: Language

    /// Creates a new action with the given name, implementation and language.
    /// - Parameters:
    ///   - name: The name of the action.
    ///   - implementation: The code within the action.
    ///   - language: The language that the actions code is written in.
    public init(name: String, implementation: Code, language: Language) {
        self.name = name
        self.implementation = implementation
        self.language = language
    }

    /// Creates an onEntry action with the given implementation and language.
    /// - Parameters:
    ///   - language: The language that the actions code is written in.
    ///   - code: The code within the action.
    /// - Returns: An action called `onEntry` with the given implementation and language.
    public static func onEntry(language: Language, code: Code = "") -> Action {
        Action(name: "onEntry", implementation: code, language: language)
    }

    /// Creates an onExit action with the given implementation and language.
    /// - Parameters:
    ///   - language: The language that the actions code is written in.
    ///   - code: The code within the action.
    /// - Returns: An action called `onExit` with the given implementation and language.
    public static func onExit(language: Language, code: Code = "") -> Action {
        Action(name: "onExit", implementation: code, language: language)
    }

    /// Creates an internal action with the given implementation and language.
    /// - Parameters:
    ///   - language: The language that the actions code is written in.
    ///   - code: The code within the action.
    /// - Returns: An action called `internal` with the given implementation and language.
    public static func `internal`(language: Language, code: Code = "") -> Action {
        Action(name: "internal", implementation: code, language: language)
    }

    /// Creates an onResume action with the given implementation and language.
    /// - Parameters:
    ///   - language: The language that the actions code is written in.
    ///   - code: The code within the action.
    /// - Returns: An action called `onResume` with the given implementation and language.
    public static func onResume(language: Language, code: Code = "") -> Action {
        Action(name: "onResume", implementation: code, language: language)
    }

    /// Creates an onSuspend action with the given implementation and language.
    /// - Parameters:
    ///   - language: The language that the actions code is written in.
    ///   - code: The code within the action.
    /// - Returns: An action called `onSuspend` with the given implementation and language.
    public static func onSuspend(language: Language, code: Code = "") -> Action {
        Action(name: "onSuspend", implementation: code, language: language)
    }

}
