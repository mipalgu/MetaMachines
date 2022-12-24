/*
 * MachineParser.swift
 * Machines
 *
 * Created by Callum McColl on 18/9/18.
 * Copyright © 2018 Callum McColl. All rights reserved.
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

import CLFSMMachines
import CXXBase
import Foundation
import IO
import SwiftMachines
import UCFSMMachines
import VHDLMachines

/// A class that can parse machines located on the file system. This parser will create a ``MetaMachine``
/// from a machine with a specific semantics.
public final class MachineParser {

    /// The errors found when the machine was parsed.
    public private(set) var errors: [String] = []

    /// The last error found when the machine was parsed.
    public var lastError: String? {
        self.errors.last
    }

    /// A swift parser.
    private let swiftParser: SwiftMachines.MachineParser

    /// A helper for IO operations.
    private let helper = FileHelpers()

    /// Creates a new ``MachineParser``.
    /// - Parameter swiftParser: The parser to use for swift machines.
    public init(swiftParser: SwiftMachines.MachineParser = SwiftMachines.MachineParser()) {
        self.swiftParser = swiftParser
    }

    /// Parses a machine from a file wrapper. The file wrapper should represent the machine folder.
    /// - Parameter wrapper: The file wrapper to parse.
    /// - Returns: A new ``MetaMachine`` that represents the data within the `FileWrapper`, or nil if the
    /// parsing was unsucessful.
    public func parseMachine(fromWrapper wrapper: FileWrapper) -> MetaMachine? {
        self.errors = []
        guard let files = wrapper.fileWrappers else {
            return nil
        }
        if files["machine.json"] != nil {
            guard let vhdlMachine = VHDLParser().parse(wrapper: wrapper) else {
                return nil
            }
            return MetaMachine(vhdl: vhdlMachine)
        }
        if wrapper.fileWrappers?["SwiftIncludePath"] == nil {
            return parseCXXMachine(wrapper: wrapper)
        }
        guard let swiftMachine = self.swiftParser.parseMachine(wrapper) else {
            self.errors = self.swiftParser.errors
            return nil
        }
        return MetaMachine(from: swiftMachine)
    }

    /// Parses a machine located at a file path. The file path should point to the machine folder with a
    /// *.machine* extension.
    /// - Parameter path: The path to the machine folder.
    /// - Returns: A new ``MetaMachine`` that represents the data within the machine folder, or nil if the
    /// parsing was unsucessful.
    public func parseMachine(atPath path: String) -> MetaMachine? {
        guard
            helper.directoryExists(path),
            let wrapper = try? FileWrapper(url: URL(fileURLWithPath: path, isDirectory: true))
        else {
            return nil
        }
        return self.parseMachine(fromWrapper: wrapper)
    }

    /// Parses a machine located at a file URL. The file URL should point to the machine folder with a
    /// *.machine* extension.
    /// - Parameter url: The URL to the machine folder.
    /// - Returns: A new ``MetaMachine`` that represents the data within the machine folder, or nil if the
    /// parsing was unsucessful.
    public func parseMachine(atURL url: URL) -> MetaMachine? {
        guard
            helper.directoryExists(url.path),
            let wrapper = try? FileWrapper(url: url)
        else {
            return nil
        }
        return self.parseMachine(fromWrapper: wrapper)
    }

    // public func parseMachine(atPath path: String) -> MetaMachine? {
    //     self.errors = []
    //     let machineDir = URL(fileURLWithPath: path, isDirectory: true)
    //     let name = machineDir.lastPathComponent.components(separatedBy: ".machine")[0]
    //     let swiftFile = machineDir.appendingPathComponent("SwiftIncludePath", isDirectory: false)
    //     let exists = (try? swiftFile.checkResourceIsReachable()) ?? false
    //     if false == exists {
    //         // let hFile = machineDir.appendingPathComponent(name + ".h", isDirectory: false)
    //         // let statesFile = machineDir.appendingPathComponent("States", isDirectory: false)
    //         // let cxxConverter = CXXBaseConverter()
    //         // guard
    //         //     let _ = try? hFile.checkResourceIsReachable(),
    //         //     let states = try? String(contentsOf: statesFile)
    //         // else {
    //         //     self.errors.append("Machine at path \(path) is using an unsupported semantics.")
    //         //     return nil
    //         // }
    //         // let initialStateName = states.components(separatedBy: .newlines)[0]
    //         // let initialOnSuspend = machineDir.appendingPathComponent(
    //         //     "State_" + initialStateName + "_OnSuspend.mm", isDirectory: false
    //         // )
    //         // let initialOnEntry = machineDir.appendingPathComponent(
    //         //     "State_" + initialStateName + "_OnEntry.mm", isDirectory: false
    //         // )
    //         // guard let _ = try? initialOnSuspend.checkResourceIsReachable() else {
    //         //     guard
    //         //         let _ = try? initialOnEntry.checkResourceIsReachable(),
    //         //         let ucfsmMachine = UCFSMParser().parseMachine(location: machineDir)
    //         //     else {
    //         //         return nil
    //         //     }
    //         //     return cxxConverter.toMachine(machine: ucfsmMachine, semantics: .ucfsm)
    //         // }
    //         // guard let clfsmMachine = CLFSMParser().parseMachine(location: machineDir) else {
    //         //     return nil
    //         // }
    //         // return cxxConverter.toMachine(machine: clfsmMachine, semantics: .clfsm)
    //         fatalError("This machine is not supported using paths. Please use FileWrappers instead.")
    //     }
    //     guard let swiftMachine = self.swiftParser.parseMachine(atPath: path) else {
    //         self.errors = self.swiftParser.errors
    //         return nil
    //     }
    //     return MetaMachine(from: swiftMachine)
    // }

    /// Parse a CXX machine represented by a `FileWrapper`.
    /// - Parameter wrapper: The wrapper that contains the machine.
    /// - Returns: A new ``MetaMachine`` that represents the data within the machine folder, or nil if the
    /// parsing was unsucessful.
    private func parseCXXMachine(wrapper: FileWrapper) -> MetaMachine? {
        guard
            let files = wrapper.fileWrappers,
            let nameComponents = wrapper.filename?.components(separatedBy: ".machine"),
            !nameComponents.isEmpty
        else {
            return nil
        }
        let name = nameComponents[0]
        guard
            files["\(name).h"] != nil,
            let statesFile = files["States"],
            let statesData = statesFile.regularFileContents,
            let statesContents = String(data: statesData, encoding: .utf8)
        else {
            self.errors.append("Machine \(name) is using an unsupported semantics.")
            return nil
        }
        let cxxConverter = CXXBaseConverter()
        let statesComponents = statesContents.components(separatedBy: .newlines)
        if statesComponents.isEmpty {
            return nil
        }
        let initialStateName = statesComponents[0]
        guard files["State_" + initialStateName + "_OnSuspend.mm"] != nil else {
            guard
                files["State_" + initialStateName + "_OnEntry.mm"] != nil,
                let ucfsmMachine = UCFSMParser().parseMachine(wrapper: wrapper)
            else {
                return nil
            }
            return cxxConverter.toMachine(machine: ucfsmMachine, semantics: .ucfsm)
        }
        guard let clfsmMachine = CLFSMParser().parseMachine(wrapper: wrapper) else {
            return nil
        }
        return cxxConverter.toMachine(machine: clfsmMachine, semantics: .clfsm)
    }

}
