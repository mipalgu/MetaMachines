// VHDLState+testState.swift
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
import VHDLMachines

extension State {

    private static let actionNames = Set(["OnEntry", "OnExit", "Internal", "OnResume", "OnSuspend"])

    static let testAttributes: [AttributeGroup] = [
        AttributeGroup(
            name: "variables",
            fields: [
                Field(name: "externals", type: .enumerableCollection(validValues: [])),
                Field(
                    name: "state_signals",
                    type: .table(
                        columns: [
                            ("type", .expression(language: .vhdl)),
                            ("name", .line),
                            ("value", .expression(language: .vhdl)),
                            ("comment", .line)
                        ]
                    )
                ),
                Field(
                    name: "state_variables",
                    type: .table(
                        columns: [
                            ("type", .expression(language: .vhdl)),
                            ("lower_range", .line),
                            ("upper_range", .line),
                            ("name", .line),
                            ("value", .expression(language: .vhdl)),
                            ("comment", .line)
                        ]
                    )
                )
            ],
            attributes: [
                "externals": .enumerableCollection([], validValues: []),
                "state_signals": .table(
                    [],
                    columns: [
                        ("type", .expression(language: .vhdl)),
                        ("name", .line),
                        ("value", .expression(language: .vhdl)),
                        ("comment", .line)
                    ]
                ),
                "state_variables": .table(
                    [],
                    columns: [
                        ("type", .expression(language: .vhdl)),
                        ("lower_range", .line),
                        ("upper_range", .line),
                        ("name", .line),
                        ("value", .expression(language: .vhdl)),
                        ("comment", .line)
                    ]
                )
            ],
            metaData: [:]
        ),
        AttributeGroup(
            name: "actions",
            fields: [
                Field(
                    name: "action_names", type: .table(columns: [("name", .line)])
                ),
                Field(
                    name: "action_order",
                    type: .table(
                        columns: [
                            ("timeslot", .integer),
                            ("action", .enumerated(validValues: actionNames))
                        ]
                    )
                )
            ],
            attributes: [
                "action_names": .table(
                    [
                        [.line("Internal")],
                        [.line("OnEntry")],
                        [.line("OnExit")],
                        [.line("OnResume")],
                        [.line("OnSuspend")]

                    ],
                    columns: [("name", .line)]
                ),
                "action_order": .table(
                    [
                        [.integer(0), .enumerated("OnResume", validValues: actionNames)],
                        [.integer(0), .enumerated("OnSuspend", validValues: actionNames)],
                        [.integer(1), .enumerated("OnEntry", validValues: actionNames)],
                        [.integer(2), .enumerated("OnExit", validValues: actionNames)],
                        [.integer(2), .enumerated("Internal", validValues: actionNames)]
                    ],
                    columns: [
                        ("timeslot", .integer),
                        ("action", .enumerated(validValues: actionNames))
                    ]
                )
            ],
            metaData: [:]
        )
    ]

}
