// PortSignal+externalInit.swift
// MetaMachines
// 
// Created by Morgan McColl.
// Copyright © 2023 Morgan McColl. All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above
//    copyright notice, this list of conditions and the following
//    disclaimer in the documentation and/or other materials
//    provided with the distribution.
// 
// 3. All advertising materials mentioning features or use of this
//    software must display the following acknowledgement:
// 
//    This product includes software developed by Morgan McColl.
// 
// 4. Neither the name of the author nor the names of contributors
//    may be used to endorse or promote products derived from this
//    software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// 
// -----------------------------------------------------------------------
// This program is free software; you can redistribute it and/or
// modify it under the above terms or under the terms of the GNU
// General Public License as published by the Free Software Foundation;
// either version 2 of the License, or (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, see http://www.gnu.org/licenses/
// or write to the Free Software Foundation, Inc., 51 Franklin Street,
// Fifth Floor, Boston, MA  02110-1301, USA.
// 

import Attributes
import VHDLParsing

extension PortSignal {

    init(
        externalSignal path: ValidationPath<ReadOnlyPath<Attribute, [LineAttribute]>>, root: Attribute
    ) throws {
        guard !path.path.isNil(root) else {
            throw ValidationError(message: "Found nil path.", path: path.path)
        }
        let row = root[keyPath: path.path.keyPath]
        guard row.count == 5 else {
            throw ValidationError(message: "Expected 5 attributes, found \(row.count).", path: path.path)
        }
        guard case .enumerated(let value, _) = row[0] else {
            throw ValidationError(message: "Expected enumerated value, found \(row[0]).", path: path.path[0])
        }
        guard let mode = Mode(rawValue: value) else {
            throw ValidationError(
                message: "Expected enumerated value to be one of \(Mode.allCases), found \(value).",
                path: path.path[0]
            )
        }
        guard case .expression(let value, let language) = row[1] else {
            throw ValidationError(message: "Expected expression, found \(row[1]).", path: path.path[1])
        }
        guard language == .vhdl else {
            throw ValidationError(message: "Expected VHDL expression, found \(language).", path: path.path[1])
        }
        guard let type = SignalType(rawValue: value) else {
            throw ValidationError(
                message: "Cannot create signal type from \(value).", path: path.path[1]
            )
        }
        guard case .line(let nameValue) = row[2] else {
            throw ValidationError(message: "Expected line, found \(row[2]).", path: path.path[2])
        }
        guard let name = VariableName(rawValue: nameValue) else {
            throw ValidationError(
                message: "Cannot create variable name from \(nameValue).", path: path.path[2]
            )
        }
        guard case .expression(let value, let language) = row[3] else {
            throw ValidationError(message: "Expected expression, found \(row[3]).", path: path.path[3])
        }
        guard language == .vhdl else {
            throw ValidationError(message: "Expected VHDL expression, found \(language).", path: path.path[3])
        }
        let defaultValue = Expression(rawValue: value)
        guard case .line(let commentValue) = row[4] else {
            throw ValidationError(message: "Expected line, found \(row[4]).", path: path.path[4])
        }
        let comment = Comment(rawValue: "-- " + commentValue)
        self.init(type: type, name: name, mode: mode, defaultValue: defaultValue, comment: comment)
    }

}
