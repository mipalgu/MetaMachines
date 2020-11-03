/*
 * BlockAttribute.swift
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

import XMI
import swift_helpers

public enum BlockAttribute: Hashable {
    
    case code(_ value: String, language: Language)
    
    case text(_ value: String)
    
    indirect case collection(_ values: [Attribute], type: AttributeType)
    
    indirect case complex(_ data: [String: Attribute], layout: [String: AttributeType])
    
    case enumerableCollection(_ values: Set<String>, validValues: Set<String>)
    
    public var type: BlockAttributeType {
        switch self {
        case .code(_, let language):
            return .code(language: language)
        case .text:
            return .text
        case .collection(_, let type):
            return .collection(type: type)
        case .complex(_, let layout):
            return .complex(layout: layout)
        case .enumerableCollection(_, let validValues):
            return .enumerableCollection(validValues: validValues)
        }
    }
    
    public var codeValue: String? {
        switch self {
        case .code(let value, _):
            return value
        default:
            return nil
        }
    }
    
    public var textValue: String? {
        switch self {
        case .text(let value):
            return value
        default:
            return nil
        }
    }
    
    public var collectionValue: ([Attribute], type: AttributeType)? {
        switch self {
        case .collection(let value, let type):
            return (value, type)
        default:
            return nil
        }
    }
    
    public var complexValue: ([String: Attribute], layout: [String: AttributeType])? {
        switch self {
        case .complex(let values, let layout):
            return (values, layout)
        default:
            return nil
        }
    }
    
    public var enumerableCollectionValue: (Set<String>, validValues: Set<String>)? {
        switch self {
        case .enumerableCollection(let values, let validValues):
            return (values, validValues)
        default:
            return nil
        }
    }
    
    public var collectionBools: [Bool]? {
        switch self {
        case .collection(let values, type: let type):
            switch type {
            case .bool:
                return values.failMap { $0.boolValue }
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    public var collectionIntegers: [Int]? {
        switch self {
        case .collection(let values, type: let type):
            switch type {
            case .integer:
                return values.failMap { $0.integerValue }
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    public var collectionFloats: [Double]? {
        switch self {
        case .collection(let values, type: let type):
            switch type {
            case .float:
                return values.failMap { $0.floatValue }
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    public var collectionExpressions: [Expression]? {
        switch self {
        case .collection(let values, type: let type):
            switch type {
            case .line(.expression):
                return values.failMap { $0.expressionValue }
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    public var collectionEnumerated: ([String], validValues: Set<String>)? {
        switch self {
        case .collection(let values, type: let type):
            switch type {
            case .line(.enumerated(let validValues)):
                guard let values: [String] = values.failMap({
                    guard let (elementValue, elementValidValues) = $0.enumeratedValue, elementValidValues == validValues else {
                        return nil
                    }
                    return elementValue
                }) else {
                    return nil
                }
                return (values, validValues)
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    public var collectionLines: [String]? {
        switch self {
        case .collection(let values, type: let type):
            switch type {
            case .line:
                return values.failMap { $0.lineValue }
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    public var collectionCode: [String]? {
        switch self {
        case .collection(let values, type: let type):
            switch type {
            case .block(.code):
                return values.failMap { $0.codeValue }
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    public var collectionText: [String]? {
        switch self {
        case .collection(let values, type: let type):
            switch type {
            case .text:
                return values.failMap { $0.textValue }
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    public var collectionComplex: ([[String: Attribute]], layout: [String: AttributeType])? {
        switch self {
        case .collection(let values, type: let type):
            switch type {
            case .block(.complex(let layout)):
                guard let values: [[String: Attribute]] = values.failMap({
                    guard let (elementValues, elementLayout) = $0.complexValue, elementLayout == layout else {
                        return nil
                    }
                    return elementValues
                }) else {
                    return nil
                }
                return (values, layout)
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    public var collectionEnumerableCollection: ([Set<String>], validValues: Set<String>)? {
        switch self {
        case .collection(let values, type: let type):
            switch type {
            case .block(.enumerableCollection(let validValues)):
                guard let values: [Set<String>] = values.failMap({
                    guard let (elementValues, elementValidValues) = $0.enumerableCollectionValue, elementValidValues == validValues else {
                        return nil
                    }
                    return elementValues
                }) else {
                    return nil
                }
                return (values, validValues)
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
}

extension BlockAttribute: Codable {
    
    public enum CodingKeys: CodingKey {
        case type
        case value
    }
    
    public init(from decoder: Decoder) throws {
        if let code = try? CodeAttribute(from: decoder) {
            self = .code(code.value, language: code.language)
            return
        }
        if let text = try? TextAttribute(from: decoder) {
            self = .text(text.value)
            return
        }
        if let collection = try? CollectionAttribute(from: decoder) {
            self = .collection(collection.values, type: collection.type)
        }
        if let complex = try? ComplexAttribute(from: decoder) {
            self = .complex(complex.values, layout: complex.layout)
        }
        if let enumCollection = try? EnumCollectionAttribute(from: decoder) {
            self = .enumerableCollection(enumCollection.values, validValues: enumCollection.cases)
        }
        throw DecodingError.dataCorrupted(
            DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Unsupported Value"
            )
        )
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .code(let value, let language):
            try CodeAttribute(value: value, language: language).encode(to: encoder)
        case .text(let value):
            try TextAttribute(value).encode(to: encoder)
        case .collection(let values, let type):
            try CollectionAttribute(type: type, values: values).encode(to: encoder)
        case .complex(let values, let layout):
            try ComplexAttribute(values: values, layout: layout).encode(to: encoder)
        case .enumerableCollection(let values, let cases):
            try EnumCollectionAttribute(cases: cases, values: values).encode(to: encoder)
        }
    }
    
    private struct CodeAttribute: Hashable, Codable {
        
        var value: String
        
        var language: Language
        
    }
    
    private struct TextAttribute: Hashable, Codable {
        
        var value: String
        
        init(_ value: String) {
            self.value = value
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.value = try container.decode(String.self)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(self.value)
        }
        
    }
    
    private struct CollectionAttribute: Hashable, Codable {
        
        var type: AttributeType
        
        var values: [Attribute]
        
    }
    
    private struct ComplexAttribute: Hashable, Codable {
        
        var values: [String: Attribute]
        
        var layout: [String: AttributeType]
        
    }
    
    private struct EnumCollectionAttribute: Hashable, Codable {
        
        var cases: Set<String>
        
        var values: Set<String>
        
        init(cases: Set<String>, values: Set<String>) {
            self.cases = cases
            self.values = values
        }
        
    }
    
}

extension BlockAttribute: XMIConvertible {
    
    public var xmiName: String? {
        switch self {
        case .code:
            return "CodeAttribute"
        case .text:
            return "TextAttribute"
        case .collection:
            return "CollectionAttribute"
        case .complex:
            return "ComplexAttribute"
        case .enumerableCollection:
            return "EnumerableAttribute"
        }
    }
    
}
