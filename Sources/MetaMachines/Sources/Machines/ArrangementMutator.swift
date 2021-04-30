/*
 * ArrangementMutator.swift
 * Machines
 *
 * Created by Callum McColl on 27/4/21.
 * Copyright © 2021 Callum McColl. All rights reserved.
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

import Attributes
import Foundation

public protocol ArrangementMutator: DependencyLayoutContainer {
    
    func addItem<Path, T>(_ item: T, to attribute: Path, in: inout Arrangement) -> Result<Bool, AttributeError<Path.Root>> where Path : PathProtocol, Path.Root == Arrangement, Path.Value == [T]
    
    func moveItems<Path: PathProtocol, T>(attribute: Path, in: inout Arrangement, from source: IndexSet, to destination: Int) -> Result<Bool, AttributeError<Path.Root>> where Path.Root == Arrangement, Path.Value == [T]
    
    func deleteItems<Path: PathProtocol, T>(table attribute: Path, items: IndexSet, in: inout Arrangement) -> Result<Bool, AttributeError<Path.Root>> where Path.Root == Arrangement, Path.Value == [T]
    
    func deleteItem<Path: PathProtocol, T>(attribute: Path, atIndex: Int, in: inout Arrangement) -> Result<Bool, AttributeError<Path.Root>> where Path.Root == Arrangement, Path.Value == [T]
    
    func modify<Path: PathProtocol>(attribute: Path, value: Path.Value, in: inout Arrangement) -> Result<Bool, AttributeError<Path.Root>> where Path.Root == Arrangement
    
    func validate(arrangement: Arrangement) throws
    
}

extension ArrangementMutator {
    
    public func deleteItems<Path: PathProtocol, T>(table attribute: Path, items: IndexSet, in arrangement: inout Arrangement) -> Result<Bool, AttributeError<Arrangement>> where Path.Root == Arrangement, Path.Value == [T] {
        var triggers: Bool = false
        for index in items.sorted(by: >) {
            switch self.deleteItem(attribute: attribute, atIndex: index, in: &arrangement) {
            case .failure(let error):
                return .failure(error)
            case .success(let triggersActivated):
                triggers = triggers || triggersActivated
            }
        }
        return .success(triggers)
    }
    
}
