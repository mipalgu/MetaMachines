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

import Foundation
import SwiftMachines
import CLFSMMachines
import UCFSMMachines
import CXXBase

public final class MachineParser {
    
    public fileprivate(set) var errors: [String] = []
    
    public var lastError: String? {
        return self.errors.last
    }
    
    fileprivate let swiftParser: SwiftMachines.MachineParser
    
    public init(swiftParser: SwiftMachines.MachineParser = SwiftMachines.MachineParser()) {
        self.swiftParser = swiftParser
    }
    
    public func parseMachine(fromWrapper wrapper: FileWrapper) -> MetaMachine? {
        self.errors = []
        if nil == wrapper.fileWrappers?["SwiftIncludePath"] {
            return parseCXXMachine(wrapper: wrapper)
        }
        guard let swiftMachine = self.swiftParser.parseMachine(wrapper) else {
            self.errors = self.swiftParser.errors
            return nil
        }
        return MetaMachine(from: swiftMachine)
    }
    
    public func parseMachine(atPath path: String) -> MetaMachine? {
        self.errors = []
        let machineDir = URL(fileURLWithPath: path, isDirectory: true)
        let name = machineDir.lastPathComponent.components(separatedBy: ".machine")[0]
        let swiftFile = machineDir.appendingPathComponent("SwiftIncludePath", isDirectory: false)
        let exists = (try? swiftFile.checkResourceIsReachable()) ?? false
        if false == exists {
//            let hFile = machineDir.appendingPathComponent(name + ".h", isDirectory: false)
//            let statesFile = machineDir.appendingPathComponent("States", isDirectory: false)
//            let cxxConverter = CXXBaseConverter()
//            guard
//                let _ = try? hFile.checkResourceIsReachable(),
//                let states = try? String(contentsOf: statesFile)
//            else {
//                self.errors.append("Machine at path \(path) is using an unsupported semantics.")
//                return nil
//            }
//            let initialStateName = states.components(separatedBy: .newlines)[0]
//            let initialOnSuspend = machineDir.appendingPathComponent("State_" + initialStateName + "_OnSuspend.mm", isDirectory: false)
//            let initialOnEntry = machineDir.appendingPathComponent("State_" + initialStateName + "_OnEntry.mm", isDirectory: false)
//            guard let _ = try? initialOnSuspend.checkResourceIsReachable() else {
//                guard
//                    let _ = try? initialOnEntry.checkResourceIsReachable(),
//                    let ucfsmMachine = UCFSMParser().parseMachine(location: machineDir)
//                else {
//                    return nil
//                }
//                return cxxConverter.toMachine(machine: ucfsmMachine, semantics: .ucfsm)
//            }
//            guard let clfsmMachine = CLFSMParser().parseMachine(location: machineDir) else {
//                return nil
//            }
//            return cxxConverter.toMachine(machine: clfsmMachine, semantics: .clfsm)
            fatalError("This machine is not supported using paths. Please use FileWrappers instead.")
        }
        guard let swiftMachine = self.swiftParser.parseMachine(atPath: path) else {
            self.errors = self.swiftParser.errors
            return nil
        }
        return MetaMachine(from: swiftMachine)
    }
    
    private func parseCXXMachine(wrapper: FileWrapper) -> MetaMachine? {
        guard
            let files = wrapper.fileWrappers,
            let nameComponents = wrapper.filename?.components(separatedBy: ".machine"),
            nameComponents.count > 0
        else {
            return nil
        }
        let name = nameComponents[0]
        guard
            let _ = files["\(name).h"],
            let statesFile = files["States"],
            let statesData = statesFile.regularFileContents,
            let statesContents = String(data: statesData, encoding: .utf8)
        else {
            self.errors.append("Machine \(name) is using an unsupported semantics.")
            return nil
        }
        let cxxConverter = CXXBaseConverter()
        let statesComponents = statesContents.components(separatedBy: .newlines)
        if statesComponents.count == 0 {
            return nil
        }
        let initialStateName = statesComponents[0]
        guard let _ = files["State_" + initialStateName + "_OnSuspend.mm"] else {
            guard
                let _ = files["State_" + initialStateName + "_OnEntry.mm"],
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
