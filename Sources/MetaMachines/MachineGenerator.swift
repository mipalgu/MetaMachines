/*
 * MachineGenerator.swift
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
import CXXBase
import VHDLMachines
#if os(Linux)
import IO
#endif

public final class MachineGenerator {
    
    public fileprivate(set) var errors: [String] = []
    
    fileprivate let swiftGenerator: SwiftMachines.MachineGenerator
    
    public var lastError: String? {
        return self.errors.last
    }
    
    public init(swiftGenerator: SwiftMachines.MachineGenerator = SwiftMachines.MachineGenerator()) {
        self.swiftGenerator = swiftGenerator
    }
    
    public func generate(_ machine: MetaMachine) -> FileWrapper? {
        self.errors = []
        switch machine.semantics {
        case .swiftfsm:
            let swiftMachine: SwiftMachines.Machine
            do {
                swiftMachine = try machine.swiftMachine()
            } catch let e as ConversionError<MetaMachine> {
                self.errors.append(e.message)
                return nil
            } catch let e {
                self.errors.append("\(e)")
                return nil
            }
            guard let results = self.swiftGenerator.generate(swiftMachine) else {
                self.errors = []
                return nil
            }
            return results
        case .clfsm, .ucfsm:
            let cxxMachine: CXXBase.Machine
            do {
                cxxMachine = try CXXBaseConverter().convert(machine: machine)
            } catch let e as ConversionError<MetaMachine> {
                self.errors.append(e.message)
                return nil
            } catch let e {
                self.errors.append("\(e)")
                return nil
            }
            guard let wrapper = CXXGenerator().generate(machine: cxxMachine) else {
                self.errors = []
                return nil
            }
            //return (cxxMachine.path, [])
            return wrapper
        case .vhdl:
            let vhdlMachine: VHDLMachines.Machine
            do {
                vhdlMachine = try VHDLMachinesConverter().convert(machine: machine)
            } catch let e as ConversionError<MetaMachine> {
                self.errors.append(e.message)
                return nil
            } catch let e {
                self.errors.append("\(e)")
                return nil
            }
            guard let wrapper = VHDLGenerator().generate(machine: vhdlMachine) else {
                self.errors = []
                return nil
            }
            //return (vhdlMachine.path, [])
            return wrapper
        default:
            self.errors.append("\(machine.semantics) Machines are currently not supported")
            return nil
        }
    }
    
}
