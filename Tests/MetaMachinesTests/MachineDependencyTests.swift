// MachineDependencyTests.swift
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

/// Test class for ``MachineDependency``.
final class MachineDependencyTests: XCTestCase {

    /// The stored attributes.
    let attributes = [
        "data": Attribute.line("Hello World!")
    ]

    /// The stored fields.
    let fields = [Field(name: "data", type: .line)]

    /// The stored metadata.
    let metaData = [
        "foo": Attribute.line("bar")
    ]

    /// The dependency to test.
    lazy var dependency = MachineDependency(
        relativePath: "TestMachine.machine",
        fields: fields,
        attributes: attributes,
        metaData: metaData
    )

    /// Initialises the dependency before every test.
    override func setUp() {
        dependency = MachineDependency(
            relativePath: "TestMachine.machine",
            fields: fields,
            attributes: attributes,
            metaData: metaData
        )
    }

    /// Test init sets stored property correctly.
    func testInit() {
        XCTAssertEqual(dependency.relativePath, "TestMachine.machine")
        XCTAssertEqual(dependency.fields, fields)
        XCTAssertEqual(dependency.attributes, attributes)
        XCTAssertEqual(dependency.metaData, metaData)
    }

    /// Test the name computed property splits on .machine.
    func testName() {
        XCTAssertEqual(dependency.name, "TestMachine")
    }

    /// Test name works for relative paths.
    func testNameWithDottedRelativePath() {
        dependency.relativePath = "./TestMachine.machine"
        XCTAssertEqual(dependency.name, "TestMachine")
        dependency.relativePath = "../TestMachine.machine"
        XCTAssertEqual(dependency.name, "TestMachine")
        dependency.relativePath = "../../path/to/TestMachine.machine"
        XCTAssertEqual(dependency.name, "TestMachine")
        dependency.relativePath = "TestMachine.machine/"
        XCTAssertEqual(dependency.name, "TestMachine")
        dependency.relativePath = "./TestMachine.machine/"
        XCTAssertEqual(dependency.name, "TestMachine")
        dependency.relativePath = "../TestMachine.machine/"
        XCTAssertEqual(dependency.name, "TestMachine")
        dependency.relativePath = "./@T?e)stMachine.machine/"
        XCTAssertEqual(dependency.name, "TestMachine")
        dependency.relativePath = "machine.machine"
        XCTAssertEqual(dependency.name, "machine.machine")
    }

    /// Test complexAttributeType is correct.
    func testComplexAttributeType() {
        let expected = AttributeType.complex(
            layout: ["relative_path": .line, "attributes": .complex(layout: dependency.fields)]
        )
        XCTAssertEqual(dependency.complexAttributeType, expected)
    }

    /// Test the complexAttribute property gets the correct values.
    func testComplexAttributeGetter() {
        let expected = Attribute.complex(
            [
                "relative_path": .line(dependency.relativePath),
                "attributes": .complex(dependency.attributes, layout: dependency.fields)
            ],
            layout: [
                Field(name: "relative_path", type: .line),
                Field(name: "attributes", type: .complex(layout: dependency.fields))
            ]
        )
        XCTAssertEqual(expected, dependency.complexAttribute)
    }

    /// Verify that the stored properties are updated correctly.
    func testComplexAttributeSetter() {
        let attribute = Attribute.complex(
            [
                "relative_path": .line("path"),
                "attributes": .complex(
                    ["A": .line("B")],
                    layout: dependency.fields
                )
            ],
            layout: [
                Field(name: "relative_path", type: .line),
                Field(name: "attributes", type: .complex(layout: dependency.fields))
            ]
        )
        dependency.complexAttribute = attribute
        XCTAssertEqual(dependency.relativePath, "path")
        XCTAssertEqual(dependency.attributes, ["A": .line("B")])
    }

    /// Test file path creates path correctly.
    func testFilePath() {
        let path = URL(fileURLWithPath: "/tmp", isDirectory: true)
        let expected: URL
        if #available(OSX 10.11, *) {
            expected = URL(fileURLWithPath: dependency.relativePath, isDirectory: true, relativeTo: path)
        } else {
            expected = URL(fileURLWithPath: "/tmp/\(dependency.relativePath)", isDirectory: true)
        }
        let result = dependency.filePath(relativeTo: path)
        XCTAssertEqual(result, expected)
        XCTAssertEqual(result.absoluteString, expected.absoluteString)
        XCTAssertEqual(result.absoluteString, "file:///tmp/\(dependency.relativePath)/")
    }

}
