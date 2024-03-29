/*
 * MachineDependency.swift
 * Machines
 *
 * Created by Callum McColl on 28/11/20.
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

/// Defines a dependency to another machine located on the file system. This struct represents the metadata
/// of the dependency and does not load the machine in.
public struct MachineDependency: Hashable, Codable {

    /// The name of the machine.
    public var name: String {
        let components = relativePath.components(separatedBy: CharacterSet([".", "/"]))
        let filter: (String) -> Bool
        if relativePath.contains(".machine") {
            filter = { $0 != "machine" && !$0.isEmpty }
        } else {
            filter = { !$0.isEmpty }
        }
        guard
            let name = components.lazy.map(\.fileRepresentation).reversed().first(where: filter)
        else {
            return relativePath.fileRepresentation
        }
        return name
    }

    /// The relative path to the dependent machine from the current machines folder.
    public var relativePath: String

    /// Fields for a view rendering this dependency.
    public var fields: [Field]

    /// Attributes for a view rendering this dependency.
    public var attributes: [Label: Attribute]

    /// Metadata for a view rendering this dependency.
    public var metaData: [Label: Attribute]

    /// The type of the attribute equivalent to this dependency.
    public var complexAttributeType: AttributeType {
        .complex(layout: [
            "relative_path": .line,
            "attributes": .complex(layout: fields)
        ])
    }

    /// The attribute that is equivalent to this dependency.
    public var complexAttribute: Attribute {
        get {
            .complex(
                [
                    "relative_path": .line(relativePath),
                    "attributes": .complex(attributes, layout: fields)
                ],
                layout: [
                    "relative_path": .line,
                    "attributes": .complex(layout: fields)
                ]
            )
        } set {
            switch newValue {
            case .block(.complex(let values, _)):
                self.relativePath = values["relative_path"]?.lineValue ?? self.relativePath
                self.attributes = values["attributes"]?.complexValue ?? self.attributes
            default:
                return
            }
        }
    }

    /// Initialise this dependency with the given parameters.
    /// - Parameters:
    ///   - relativePath: The relative path to the dependent machine from the current machines folder.
    ///   - fields: The fields for a view rendering this dependency.
    ///   - attributes: The attributes for a view rendering this dependency.
    ///   - metaData: The metadata for a view rendering this dependency.
    public init(
        relativePath: String,
        fields: [Field] = [],
        attributes: [Label: Attribute] = [:],
        metaData: [Label: Attribute] = [:]
    ) {
        self.relativePath = relativePath
        self.fields = fields
        self.attributes = attributes
        self.metaData = metaData
    }

    /// Creates a path relative to a parent folder.
    /// - Parameter parent: The parent folder to create the relative path from.
    /// - Returns: The path to this dependency relative to the parent folder.
    public func filePath(relativeTo parent: URL) -> URL {
        guard #available(OSX 10.11, *) else {
            return parent.appendingPathComponent(
                relativePath.trimmingCharacters(in: .whitespacesAndNewlines), isDirectory: true
            )
        }
        return URL(
            fileURLWithPath: relativePath.trimmingCharacters(in: .whitespaces),
            isDirectory: true,
            relativeTo: parent
        )
    }
}

/// Add fileRepresentation.
private extension String {

    /// A form of `self` that is safe to use in the file system.
    var fileRepresentation: String {
        let chars = CharacterSet.fileName
        return self.filter {
            guard let char = $0.asciiValue else {
                return false
            }
            return chars.contains(Unicode.Scalar(char))
        }
    }

}

/// Add fileName static property.
private extension CharacterSet {

    /// The characters allowed for resources in the file system.
    static let fileName = CharacterSet.alphanumerics.union(CharacterSet(["_", "-", "."]))

}
