/*
 * LineAttribute.swift
 * Machines
 *
 * Created by Callum McColl on 31/10/20.
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

public enum LineAttribute: Hashable, Codable {
    
    public enum CodingKeys: CodingKey {
        case type
        case value
    }
    
    case bool(Bool)
    case integer(Int)
    case float(Double)
    case expression(Expression)
    case line(String)
    
    public var type: LineAttributeType {
        switch self {
        case .bool:
            return .bool
        case .integer:
            return .integer
        case .float:
            return .float
        case .expression:
            return .expression
        case .line:
            return .line
        }
    }
    
    public init?(type: LineAttributeType, value: String) {
        switch type {
        case .bool:
            guard let value = Bool(value) else {
                return nil
            }
            self = .bool(value)
        case .integer:
            guard let value = Int(value) else {
                return nil
            }
            self = .integer(value)
        case .float:
            guard let value = Double(value) else {
                return nil
            }
            self = .float(value)
        case .expression:
            self = .expression(Expression(value))
        case .line:
            self = .line(value)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "bool":
            let value = try container.decode(Bool.self, forKey: .value)
            self = .bool(value)
        case "integer":
            let value = try container.decode(Int.self, forKey: .value)
            self = .integer(value)
        case "float":
            let value = try container.decode(Double.self, forKey: .value)
            self = .float(value)
        case "expression":
            let value = try container.decode(String.self, forKey: .value)
            self = .expression(value)
        case "line":
            let value = try container.decode(String.self, forKey: .value)
            self = .line(value)
        default:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.type], debugDescription: "Invalid value \(type)"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .bool(let value):
            try container.encode("bool", forKey: .type)
            try container.encode(value, forKey: .value)
        case .integer(let value):
            try container.encode("integer", forKey: .type)
            try container.encode(value, forKey: .value)
        case .float(let value):
            try container.encode("float", forKey: .type)
            try container.encode(value, forKey: .value)
        case .expression(let value):
            try container.encode("expression", forKey: .type)
            try container.encode(value, forKey: .value)
        case .line(let value):
            try container.encode("line", forKey: .type)
            try container.encode(value, forKey: .value)
        }
    }
    
}
