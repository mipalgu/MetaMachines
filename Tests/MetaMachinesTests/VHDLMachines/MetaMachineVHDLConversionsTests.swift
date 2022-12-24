// MetaMachineVHDLConversionsTests.swift
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
@testable import MetaMachines
import VHDLMachines
import XCTest

/// Test class for ``MetaMachine`` VHDL conversions.
final class MetaMachineVHDLConversionsTests: XCTestCase {

    /// A Test machine.
    let testMachine = VHDLMachines.Machine.testMachine(
        path: URL(fileURLWithPath: "Machine.machine", isDirectory: true)
    )

    /// The machine under test.
    lazy var machine = MetaMachine(vhdl: testMachine)

    /// Initialise the test machine.
    override func setUp() {
        machine = MetaMachine(vhdl: testMachine)
    }

    /// Test the conversion init sets properties correctly.
    func testConversionInit() {
        let expected = MetaMachine(
            semantics: .vhdl,
            name: "Machine",
            initialState: "Initial",
            states: testMachine.states.map { MetaMachines.State(vhdl: $0, in: testMachine) },
            dependencies: [
                MachineDependency(relativePath: "Machine2.machine"),
                MachineDependency(relativePath: "Machine3.machine")
            ],
            attributes: VHDLMachines.Machine.testAttributes,
            metaData: []
        )
        XCTAssertEqual(machine, expected)
    }

    /// Test initial machine delegates correctly.
    func testInitialMachine() {
        let path = URL(fileURLWithPath: "NewMachine.machine", isDirectory: true)
        let expected = MetaMachine(vhdl: VHDLMachines.Machine.initial(path: path))
        let result = MetaMachine.initialVHDLMachine(filePath: path)
        XCTAssertEqual(result, expected)
    }

    /// Test computed properties work correctly.
    func testMachineComputedProperties() {
        XCTAssertFalse(machine.dependencies.isEmpty)
        XCTAssertEqual(machine.vhdlArchitectureBody, testMachine.architectureBody)
        XCTAssertEqual(machine.vhdlArchitectureHead, testMachine.architectureHead)
        XCTAssertEqual(machine.vhdlClocks, testMachine.clocks)
        XCTAssertEqual(machine.vhdlDrivingClock, testMachine.drivingClock)
        XCTAssertEqual(machine.vhdlDependentMachines, testMachine.dependentMachines)
        XCTAssertEqual(machine.vhdlExternalSignals, testMachine.externalSignals)
        XCTAssertEqual(machine.vhdlGenerics, testMachine.generics)
        XCTAssertEqual(machine.vhdlIncludes, testMachine.includes)
        XCTAssertEqual(machine.vhdlIsParameterised, testMachine.isParameterised)
        XCTAssertEqual(machine.vhdlMachineSignals, testMachine.machineSignals)
        XCTAssertEqual(machine.vhdlMachineVariables, testMachine.machineVariables)
        XCTAssertEqual(machine.vhdlParameterSignals, testMachine.parameterSignals)
        XCTAssertEqual(machine.vhdlReturnableSignals, testMachine.returnableSignals)
        XCTAssertEqual(machine.vhdlTransitions, testMachine.transitions)
    }

}
