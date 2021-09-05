/*
 * Arrangement.swift
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

import Foundation
import Attributes
import SwiftMachines

public struct Arrangement: Identifiable, PathContainer, MutatorContainer, DependenciesContainer {
    
    public enum Semantics: String, Hashable, Codable, CaseIterable {
        case other
        case swiftfsm
    }
    
    /// The semantics that are fully supported by this module.
    ///
    /// This means that it is possible to create an arrangement using the
    /// helper functions such as `initialArrangement(forSemantics:)` or call
    /// the semantics initialiser.
    ///
    /// If you are implementing an editor, this could be used when creating a
    /// new machine to display a list of options to asking inquiring which
    /// semantics they would like to use.
    ///
    /// This array generally contains all semantics except for the `other` case.
    public static var supportedSemantics: [Arrangement.Semantics] {
        return Arrangement.Semantics.allCases.filter { $0 != .other }
    }
    
    public let mutator: ArrangementMutator
    
    public private(set) var errorBag: ErrorBag<Arrangement> = ErrorBag()
    
    public private(set) var id: UUID = UUID()
    
    
    public static var path: Path<Arrangement, Arrangement> {
        return Attributes.Path<Arrangement, Arrangement>(path: \.self, ancestors: [])
    }
    
    public var path: Path<Arrangement, Arrangement> {
        return Arrangement.path
    }
    
    /// The underlying semantics which this meta machine follows.
    public var semantics: Semantics
    
    /// The name of the arrangement.
    public var name: String
    
    /// The root machines of the arrangement.
    public var dependencies: [MachineDependency]
    
    public var dependencyAttributeType: AttributeType {
        return .complex(layout: [
            "name": .line,
            "filePath": .line,
            "attributes": .complex(layout: mutator.dependencyLayout)
        ])
    }
    
    public var dependencyAttributes: [Attribute] {
        get {
            self.dependencies.map(\.complexAttribute)
        } set {
            self.dependencies = zip(self.dependencies, newValue).map {
                var dep = $0
                dep.complexAttribute = $1
                return dep
            }
        }
    }
    
    public var attributes: [AttributeGroup]
    
    public var metaData: [AttributeGroup]
    
    public init(
        semantics: Semantics,
        name: String,
        dependencies: [MachineDependency] = [],
        attributes: [AttributeGroup],
        metaData: [AttributeGroup]
    ) {
        self.semantics = semantics
        self.name = name
        switch semantics {
        case .swiftfsm:
            self.mutator = SwiftfsmConverter()
        case .other:
            fatalError("Use the mutator constructor if you wish to use an undefined semantics")
        }
        self.dependencies = dependencies
        self.attributes = attributes
        self.metaData = metaData
    }
    
    public init(loadAtFilePath url: URL) throws {
        let parser = SwiftMachines.MachineArrangementParser()
        guard let arrangement = parser.parseArrangement(atDirectory: url) else {
            throw ConversionError(message: parser.errors.last ?? "Unable to parse arrangement at \(url.path)", path: MetaMachine.path)
        }
        self = SwiftfsmConverter().metaArrangement(of: arrangement, atDirectory: url)
    }
    
    public func allMachineNames(relativeTo arrangementDir: URL) -> Set<String> {
        var names: Set<String> = []
        var machines: [URL: MetaMachine] = [:]
        func process(_ url: URL, prefix: String, previous previousNames: [URL: String]) {
            guard let machine = machines[url] ?? (try? MetaMachine(filePath: url)) else {
                return
            }
            machines[url] = machine
            if nil != previousNames[url] {
                return
            }
            let name = prefix + (url.lastPathComponent.components(separatedBy: ".").first ?? "")
            names.insert(name)
            var newPreviousNames = previousNames
            newPreviousNames[url] = name
            machine.dependencies.forEach { process($0.filePath(relativeTo: url), prefix: name + ".", previous: newPreviousNames) }
        }
        self.dependencies.forEach {
            process($0.filePath(relativeTo: arrangementDir), prefix: "", previous: [:])
        }
        return names
    }
    
    /// Setup an initial machine for a specific semantics.
    ///
    /// - Parameter semantics: The semantics which the machine should follow.
    ///
    /// - Warning: The value of `semantics` should exist in the
    /// `supportedSemantics` array.
    public static func initialArrangement(forSemantics semantics: Arrangement.Semantics, filePath: URL = URL(fileURLWithPath: "/tmp/Untitled.arrangement", isDirectory: true)) -> Arrangement {
        switch semantics {
        case .swiftfsm:
            return SwiftfsmConverter().initialArrangement
        case .other:
            fatalError("You cannot create an initial machine for an unknown semantics")
        }
    }
    
    public func flattenedDependencies(relativeTo arrangementDir: URL) throws -> [FlattenedDependency] {
        let allMachines = try self.allMachines(relativeTo: arrangementDir)
        func process(_ dependency: MachineDependency, relativeTo parent: URL) throws -> FlattenedDependency {
            guard let machine = allMachines[dependency.filePath(relativeTo: parent)] else {
                throw ConversionError(message: "Unable to parse all dependent machines", path: MetaMachine.path.dependencies)
            }
            let dependencies = try machine.dependencies.map {
                try process($0, relativeTo: dependency.filePath(relativeTo: parent))
            }
            return FlattenedDependency(name: dependency.name, machine: machine, dependencies: dependencies)
        }
        return try dependencies.map {
            try process($0, relativeTo: arrangementDir)
        }
    }
    
    public func allMachines(relativeTo arrangementDir: URL) throws -> [URL: MetaMachine] {
        var dict: [URL: MetaMachine] = [:]
        dict.reserveCapacity(dependencies.count)
        func recurse(_ dependency: MachineDependency, relativeTo parent: URL) throws {
            if nil != dict[dependency.filePath(relativeTo: parent).resolvingSymlinksInPath().absoluteURL] {
                return
            }
            let machine = try MetaMachine(filePath: dependency.filePath(relativeTo: parent).resolvingSymlinksInPath().absoluteURL)
            dict[dependency.filePath(relativeTo: parent).resolvingSymlinksInPath().absoluteURL] = machine
            try machine.dependencies.forEach {
                try recurse($0, relativeTo: dependency.filePath(relativeTo: parent))
            }
        }
        try dependencies.forEach {
            try recurse($0, relativeTo: arrangementDir)
        }
        return dict
    }
    
    public func save(at directory: URL) throws {
        let swiftArrangement = try SwiftfsmConverter().convert(self)
        let generator = SwiftMachines.MachineArrangementGenerator()
        guard nil != generator.generateArrangement(swiftArrangement, atDirectory: directory) else {
            throw ConversionError(message: generator.errors.last ?? "Unable to save arrangement", path: MetaMachine.path)
        }
    }
    
}

extension Arrangement: Modifiable {
    
    /// Add a new item to a table attribute.
    public mutating func addItem<Path: PathProtocol, T>(_ item: T, to attribute: Path) -> Result<Bool, AttributeError<Arrangement>> where Path.Root == Arrangement, Path.Value == [T] {
        perform { [mutator] arrangement in
            mutator.addItem(item, to: attribute, in: &arrangement)
        }
    }
    
    public mutating func moveItems<Path: PathProtocol, T>(table attribute: Path, from source: IndexSet, to destination: Int) -> Result<Bool, AttributeError<Arrangement>> where Path.Root == Arrangement, Path.Value == [T]  {
        perform { [mutator] arrangement in
            mutator.moveItems(attribute: attribute, in: &arrangement, from: source, to: destination)
        }
    }
    
    /// Delete a specific item in a table attribute.
    public mutating func deleteItem<Path: PathProtocol, T>(table attribute: Path, atIndex index: Int) -> Result<Bool, AttributeError<Arrangement>> where Path.Root == Arrangement, Path.Value == [T] {
        perform { [mutator] arrangement in
            mutator.deleteItem(attribute: attribute, atIndex: index, in: &arrangement)
        }
    }
    
    public mutating func deleteItems<Path: PathProtocol, T>(table attribute: Path, items: IndexSet) -> Result<Bool, AttributeError<Arrangement>> where Path.Root == Arrangement, Path.Value == [T] {
        perform { [mutator] arrangement in
            mutator.deleteItems(table: attribute, items: items, in: &arrangement)
        }
    }
    
    /// Modify a specific attributes value.
    public mutating func modify<Path: PathProtocol>(attribute: Path, value: Path.Value) -> Result<Bool, AttributeError<Arrangement>> where Path.Root == Arrangement {
        perform { [mutator] arrangement in
            mutator.modify(attribute: attribute, value: value, in: &arrangement)
        }
    }
    
    /// Are there any errors with the machine?
    public func validate() throws {
        try perform { arrangement in
            try self.mutator.validate(arrangement: arrangement)
        }
    }
    
    private func perform(_ f: (Arrangement) throws -> Void) throws {
        do {
            try f(self)
        } catch let e as AttributeError<Arrangement> {
            throw e
        } catch let e {
            fatalError("Unsupported error: \(e)")
        }
    }
    
    private mutating func perform(_ f: (inout Arrangement) throws -> Void) throws {
        let backup = self
        do {
            try f(&self)
            self.errorBag.empty()
        } catch let e as AttributeError<Arrangement> {
            self = backup
            self.errorBag.remove(includingDescendantsForPath: e.path)
            self.errorBag.insert(e)
            throw e
        } catch let e {
            fatalError("Unsupported error: \(e)")
        }
    }
    
    private func perform(_ f: (Arrangement) -> Result<Bool, AttributeError<Arrangement>>) -> Result<Bool, AttributeError<Arrangement>> {
        return f(self)
    }
    
    private mutating func perform(_ f: (inout Arrangement) -> Result<Bool, AttributeError<Arrangement>>) -> Result<Bool, AttributeError<Arrangement>> {
        let backup = self
        let result = f(&self)
        switch result {
        case .failure(let e):
            self = backup
            self.errorBag.remove(includingDescendantsForPath: e.path)
            self.errorBag.insert(e)
            return result
        case .success:
            self.errorBag.empty()
            return result
        }
    }
    
}

extension Arrangement: Equatable {
    
    public static func == (lhs: Arrangement, rhs: Arrangement) -> Bool {
        return lhs.semantics == rhs.semantics
            && lhs.name == rhs.name
            && lhs.dependencies == rhs.dependencies
            && lhs.attributes == rhs.attributes
            && lhs.metaData == rhs.metaData
    }
    
}

extension Arrangement: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.semantics)
        hasher.combine(self.name)
        hasher.combine(self.dependencies)
        hasher.combine(self.attributes)
        hasher.combine(self.metaData)
    }
    
}

extension Arrangement: Codable {
    
    public enum CodingKeys: CodingKey {
        
        case semantics
        case name
        case dependencies
        case attributes
        case metaData
        
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let semantics = try container.decode(Semantics.self, forKey: .semantics)
        let name = try container.decode(String.self, forKey: .name)
        let dependencies = try container.decode([MachineDependency].self, forKey: .dependencies)
        let attributes = try container.decode([AttributeGroup].self, forKey: .attributes)
        let metaData = try container.decode([AttributeGroup].self, forKey: .metaData)
        self.init(
            semantics: semantics,
            name: name,
            dependencies: dependencies,
            attributes: attributes,
            metaData: metaData
        )
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.semantics, forKey: .semantics)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.dependencies, forKey: .dependencies)
        try container.encode(self.attributes, forKey: .attributes)
        try container.encode(self.metaData, forKey: .metaData)
    }
    
}
