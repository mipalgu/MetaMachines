// MetaMachineTests.swift
// MetaMachines
// 
// Created by Morgan McColl.
// Copyright © 2022 Morgan McColl. All rights reserved.
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
import IO
@testable import MetaMachines
import VHDLMachines
import XCTest

/// Test class for ``MetaMachine``.
final class MetaMachineTests: XCTestCase {

    /// The machine under test.
    lazy var machine = MetaMachine(
        semantics: .swiftfsm,
        mutator: mutator,
        name: "Machine",
        initialState: "Initial",
        states: states,
        dependencies: dependencies,
        attributes: attributes,
        metaData: metaData
    )

    /// A mock mutator.
    var mutator = MockMetaMachineMutator()

    /// The default actions for the states.
    let defaultActions = [
        Action.onEntry(language: .swift),
        Action.onExit(language: .swift),
        Action.internal(language: .swift)
    ]

    /// The default states in a machine.
    var states: [MetaMachines.State] {
        [
            State(name: "Initial", actions: defaultActions, transitions: []),
            State(name: "Suspended", actions: defaultActions, transitions: [])
        ]
    }

    /// A fake dependency.
    let dependencies = [MachineDependency(relativePath: "Other.machine")]

    /// Fake attributes.
    let attributes = [AttributeGroup(name: "Group 1")]

    /// Fake meta data.
    let metaData = [AttributeGroup(name: "Group 2")]

    /// A File helper.
    let helper = FileHelpers()

    /// The path to the package root.
    let packageRootPath = URL(fileURLWithPath: #file)
        .pathComponents.prefix { $0 != "Tests" }.joined(separator: "/").dropFirst()

    /// A path to the machines folder.
    var machineFolder: URL {
        URL(fileURLWithPath: "\(packageRootPath)/Tests/MetaMachinesTests/machines", isDirectory: true)
    }

    /// Initialise MetaMachine.
    override func setUp() {
        self.mutator = MockMetaMachineMutator()
        self.machine = MetaMachine(
            semantics: .swiftfsm,
            mutator: mutator,
            name: "Machine",
            initialState: "Initial",
            states: states,
            dependencies: dependencies,
            attributes: attributes,
            metaData: metaData
        )
    }

    /// Test supported semantics include everything except `other`.
    func testSupportedSemantics() {
        XCTAssertEqual(
            MetaMachine.supportedSemantics.sorted(),
            [
                .clfsm,
                .spartanfsm,
                .swiftfsm,
                .ucfsm,
                .vhdl
            ]
        )
    }

    /// Test initialMachine static function.
    func testInitialMachines() {
        let path = URL(fileURLWithPath: "/tmp/Untitled.machine", isDirectory: true)
        XCTAssertEqual(
            MetaMachine.initialMachine(forSemantics: .clfsm),
            CLFSMConverter().initialCLFSMMachine(filePath: path)
        )
        XCTAssertEqual(
            MetaMachine.initialMachine(forSemantics: .spartanfsm),
            SpartanFSMConverter().intialSpartanFSMMachine(filePath: path)
        )
        XCTAssertEqual(
            MetaMachine.initialMachine(forSemantics: .swiftfsm),
            SwiftfsmConverter().initialMachine
        )
        XCTAssertEqual(
            MetaMachine.initialMachine(forSemantics: .ucfsm),
            UCFSMConverter().initialUCFSMMachine(filePath: path)
        )
        XCTAssertEqual(
            MetaMachine.initialMachine(forSemantics: .vhdl),
            MetaMachine(vhdl: VHDLMachines.Machine.initial(path: path))
        )
    }

    /// Test init sets stored properties correctly.
    func testStoredInit() {
        XCTAssertEqual(machine.semantics, .swiftfsm)
        XCTAssertIdentical(machine.mutator as? MockMetaMachineMutator, mutator)
        XCTAssertEqual(machine.name, "Machine")
        XCTAssertEqual(machine.initialState, "Initial")
        XCTAssertEqual(machine.states, states)
        XCTAssertEqual(machine.dependencies, dependencies)
        XCTAssertEqual(machine.attributes, attributes)
        XCTAssertEqual(machine.metaData, metaData)
        XCTAssertTrue(machine.errorBag.allErrors.isEmpty)
        XCTAssertEqual(machine.acceptingStates, states)
        XCTAssertEqual(
            machine.dependencyAttributeType,
            .complex(layout: ["name": .line, "filePath": .line, "attributes": .complex(layout: [])])
        )
        XCTAssertEqual(mutator.dependencyLayoutTimesCalled, 1)
    }

    /// Test other init sets stored properties correctly.
    func testSemanticsInit() {
        let swiftfsmMachine = MetaMachine.initialSwiftMachine
        let machine = MetaMachine(
            semantics: .swiftfsm,
            name: "Machine",
            initialState: "Initial",
            states: states,
            dependencies: dependencies,
            attributes: swiftfsmMachine.attributes,
            metaData: swiftfsmMachine.metaData
        )
        XCTAssertEqual(machine.semantics, .swiftfsm)
        XCTAssertNotNil(machine.mutator as? SchemaMutator<SwiftfsmSchema>)
        XCTAssertEqual(machine.name, "Machine")
        XCTAssertEqual(machine.initialState, "Initial")
        XCTAssertEqual(machine.states, states)
        XCTAssertEqual(machine.dependencies, dependencies)
        XCTAssertEqual(machine.attributes, swiftfsmMachine.attributes)
        XCTAssertEqual(machine.metaData, swiftfsmMachine.metaData)
    }

    /// Test getter and setter work correctly.
    func testDependencyAttributesGetterAndSetter() {
        guard var newDependency = dependencies.first else {
            XCTFail("failed to get dependency")
            return
        }
        let attribute = newDependency.complexAttribute
        XCTAssertEqual(machine.dependencyAttributes, [attribute])
        var val = attribute.complexValue
        val["relative_path"] = .line("bar")
        let newAttribute = Attribute.complex(val, layout: attribute.complexFields)
        machine.dependencyAttributes = [newAttribute]
        XCTAssertEqual(machine.dependencyAttributes, [newAttribute])
        newDependency.relativePath = "bar"
        XCTAssertEqual(machine.dependencies, [newDependency])
    }

    /// Test path points to MetaMachine.
    func testPath() {
        let path = Path(MetaMachine.self)
        XCTAssertEqual(machine.path, path)
        XCTAssertEqual(MetaMachine.path, path)
    }

    /// Test can decode and encode machine with correct attributes.
    func testCodableConformance() throws {
        let machine = MetaMachine.initialSwiftMachine
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let data = try encoder.encode(machine)
        let decodedMachine = try decoder.decode(MetaMachine.self, from: data)
        XCTAssertEqual(decodedMachine, machine)
    }

    /// Test fileWrapper function creates correct file wrapper.
    func testFileWrapper() throws {
        let machine = MetaMachine.initialMachine(forSemantics: .vhdl)
        let wrapper = try machine.fileWrapper()
        XCTAssertEqual(wrapper.preferredFilename, "Untitled.machine")
        XCTAssertTrue(wrapper.isDirectory)
        XCTAssertFalse(wrapper.isRegularFile)
        #if os(Linux)
        XCTAssertNil(wrapper.regularFileContents)
        #endif
        guard let subWrappers = wrapper.fileWrappers, let subWrapper = subWrappers["machine.json"] else {
            XCTFail("failed to get subwrappers")
            return
        }
        XCTAssertEqual(subWrappers.count, 1)
        XCTAssertEqual(subWrapper.preferredFilename, "machine.json")
        XCTAssertFalse(subWrapper.isDirectory)
        guard subWrapper.isRegularFile, let contents = subWrapper.regularFileContents else {
            XCTFail("failed to get contents")
            return
        }
        let decoder = JSONDecoder()
        XCTAssertNoThrow(try decoder.decode(VHDLMachines.Machine.self, from: contents))
    }

    /// Test MetaMachine doesn't corrupt data when using FileWrapper initialiser.
    func testFileWrapperInit() throws {
        let machine = MetaMachine.initialMachine(forSemantics: .vhdl)
        let wrapper = try machine.fileWrapper()
        let decodedMachine = try MetaMachine(from: wrapper)
        XCTAssertEqual(decodedMachine, machine)
    }

    /// Test URL initialiser doesn't corrupt data.
    func testURLInit() throws {
        XCTAssertTrue(helper.createDirectory(atPath: machineFolder))
        defer {  _ = helper.deleteItem(atPath: machineFolder) }
        let machineURL = machineFolder.appendingPathComponent("Untitled.machine", isDirectory: true)
        let machine = MetaMachine.initialMachine(forSemantics: .vhdl, filePath: machineURL)
        let wrapper = try machine.fileWrapper()
        try wrapper.write(to: machineFolder, options: .atomic, originalContentsURL: nil)
        let decodedMachine = try MetaMachine(filePath: machineURL)
        XCTAssertEqual(decodedMachine, machine)
    }

}
