// MachineParserTests.swift
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

import IO
@testable import MetaMachines
import VHDLMachines
import XCTest

/// Test class for ``MachineParser``.
final class MachineParserTests: XCTestCase {

    /// The parser under test.
    var parser = MachineParser()

    /// A helper with IO.
    let helper = FileHelpers()

    /// A vhdl machine.
    let machine = MetaMachine.initialMachine(forSemantics: .vhdl)

    /// The path to the package root.
    let packageRootPath = URL(fileURLWithPath: #file)
        .pathComponents.prefix { $0 != "Tests" }.joined(separator: "/").dropFirst()

    /// A path to the machines folder.
    var machineFolder: URL {
        URL(fileURLWithPath: "\(packageRootPath)/Tests/MetaMachinesTests/machines", isDirectory: true)
    }

    /// The file name of the machine.
    var fileName: String {
        "\(machine.name).machine"
    }

    /// Initialises the parser under test.
    override func setUp() {
        self.parser = MachineParser()
    }

    /// Test there are no errors when the parser is initialised.
    func testInitProperties() {
        XCTAssertTrue(parser.errors.isEmpty)
        XCTAssertNil(parser.lastError)
    }

    func testParseWrapper() throws {
        _ = helper.createDirectory(atPath: machineFolder)
        defer { _ = helper.deleteItem(atPath: machineFolder) }
        let machine = MetaMachine.initialMachine(
            forSemantics: .vhdl,
            filePath: machineFolder.appendingPathComponent("Untitled.machine", isDirectory: true)
        )
        let vhdlMachine = try VHDLMachinesConverter().convert(machine: machine)
        guard let wrapper = VHDLMachines.VHDLGenerator().generate(machine: vhdlMachine) else {
            XCTFail("Failed to generate wrapper.")
            return
        }
        try wrapper.write(to: machineFolder, options: .atomic, originalContentsURL: nil)
        guard let result = parser.parseMachine(fromWrapper: wrapper) else {
            XCTFail("Failed to parse machine.")
            return
        }
        // XCTAssertEqual(result.acceptingStates, machine.acceptingStates)
        // XCTAssertEqual(result.attributes, machine.attributes)
        XCTAssertEqual(result.dependencies, machine.dependencies)
        XCTAssertEqual(result.dependencyAttributes, machine.dependencyAttributes)
        XCTAssertEqual(result.dependencyAttributeType, machine.dependencyAttributeType)
        XCTAssertEqual(result.initialState, machine.initialState)
        XCTAssertEqual(result.metaData, machine.metaData)
        XCTAssertEqual(result.name, machine.name)
        XCTAssertEqual(result.path, machine.path)
        XCTAssertEqual(result.semantics, machine.semantics)
        guard result.states.count == machine.states.count else {
            XCTFail("Failed to parse states.")
            return
        }
        zip(result.states, machine.states).forEach{ lhs, rhs in
            XCTAssertEqual(lhs.name, rhs.name)
            XCTAssertEqual(lhs.transitions, rhs.transitions)
            print(lhs.actions.map(\.name))
            print(rhs.actions.map(\.name))
            guard lhs.actions.count == rhs.actions.count else {
                XCTFail("Failed to parse actions.")
                return
            }
            zip(lhs.actions, rhs.actions).forEach{ lhs, rhs in
                XCTAssertEqual(lhs.name, rhs.name)
                XCTAssertEqual(lhs.implementation, rhs.implementation)
                XCTAssertEqual(lhs.language, rhs.language)
            }
            XCTAssertEqual(lhs.attributes, rhs.attributes)
            XCTAssertEqual(lhs.metaData, rhs.metaData)
        }
    }

}
