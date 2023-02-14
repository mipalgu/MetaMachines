// TransitionTests.swift
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
import XCTest

/// Test class for ``Transition``.
final class TransitionTests: XCTestCase {

    /// The attribute group that exists in the attributes array.
    let attribute = AttributeGroup(name: "A", fields: [], attributes: [:], metaData: [:])

    /// The attribute group that exists in the metaData array.
    let metaData = AttributeGroup(name: "B", fields: [], attributes: [:], metaData: [:])

    // swiftlint:disable implicitly_unwrapped_optional

    /// The transition under test.
    var transition: Transition!

    // swiftlint:enable implicitly_unwrapped_optional

    // /// The initial state.
    // var state: State {
    //     State(name: "S0", actions: [], transitions: [transition])
    // }

    // /// A test machine.
    // var machine: MetaMachine {
    //     MetaMachine(
    //         semantics: .swiftfsm,
    //         name: "M0",
    //         initialState: "S0",
    //         states: [state],
    //         dependencies: [],
    //         attributes: [],
    //         metaData: []
    //     )
    // }

    override func setUp() {
        transition = Transition(
            condition: "true", target: "S0", attributes: [attribute], metaData: [metaData]
        )
    }

    /// Test init sets properties correctly.
    func testInit() {
        XCTAssertEqual(transition.condition, "true")
        XCTAssertEqual(transition.target, "S0")
        XCTAssertEqual(transition.attributes, [attribute])
        XCTAssertEqual(transition.metaData, [metaData])
    }

    /// Test getters and setters work correctly.
    func testGetterSetter() {
        transition.condition = "false"
        transition.target = "S1"
        transition.attributes = [metaData]
        transition.metaData = [attribute]
        XCTAssertEqual(transition.condition, "false")
        XCTAssertEqual(transition.target, "S1")
        XCTAssertEqual(transition.attributes, [metaData])
        XCTAssertEqual(transition.metaData, [attribute])
    }

    // /// Test targetState function returns correct state.
    // func testTarget() {
    //     let m = machine
    //     let result = transition.targetState(in: m)
    //     XCTAssertEqual(result, state)
    // }

}
