// MockMetaMachineMutator+parameters.swift
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

/// Add parameter functions.
extension MockMetaMachineMutator {

    /// The parameters passed to the `didCreateDependency` function.
    var didCreateDependencyParameters: [FunctionCalled] {
        self.functionsCalled.filter {
            guard case .didCreateDependency = $0 else {
                return false
            }
            return true
        }
    }

    /// The parameters passed to the `didCreateNewState` function.
    var didCreateNewStateParameters: [FunctionCalled] {
        self.functionsCalled.filter {
            guard case .didCreateNewState = $0 else {
                return false
            }
            return true
        }
    }

    /// The parameters passed to the `didCreateNewTransition` function.
    var didCreateNewTransitionParameters: [FunctionCalled] {
        self.functionsCalled.filter {
            guard case .didCreateNewTransition = $0 else {
                return false
            }
            return true
        }
    }

    /// The parameters passed to the `didChangeStatesName` function.
    var didChangeStatesNameParameters: [FunctionCalled] {
        self.functionsCalled.filter {
            guard case .didChangeStatesName = $0 else {
                return false
            }
            return true
        }
    }

    /// The parameters passed to the `didDeleteDependency` function.
    var didDeleteDependencyParameters: [FunctionCalled] {
        self.functionsCalled.filter {
            guard case .didDeleteDependency = $0 else {
                return false
            }
            return true
        }
    }

    /// The parameters passed to the `didDeleteState` function.
    var didDeleteStateParameters: [FunctionCalled] {
        self.functionsCalled.filter {
            guard case .didDeleteState = $0 else {
                return false
            }
            return true
        }
    }

    /// The parameters passed to the `didDeleteTransition` function.
    var didDeleteTransitionParameters: [FunctionCalled] {
        self.functionsCalled.filter {
            guard case .didDeleteTransition = $0 else {
                return false
            }
            return true
        }
    }

    /// The parameters passed to the `didDeleteDependencies` function.
    var didDeleteDependenciesParameters: [FunctionCalled] {
        self.functionsCalled.filter {
            guard case .didDeleteDependencies = $0 else {
                return false
            }
            return true
        }
    }

    /// The parameters passed to the `didDeleteStates` function.
    var didDeleteStatesParameters: [FunctionCalled] {
        self.functionsCalled.filter {
            guard case .didDeleteStates = $0 else {
                return false
            }
            return true
        }
    }

    /// The parameters passed to the `didDeleteTransitions` function.
    var didDeleteTransitionsParameters: [FunctionCalled] {
        self.functionsCalled.filter {
            guard case .didDeleteTransitions = $0 else {
                return false
            }
            return true
        }
    }

    /// The parameters passed to the `update` function.
    var updateParameters: [FunctionCalled] {
        self.functionsCalled.filter {
            guard case .update = $0 else {
                return false
            }
            return true
        }
    }

    /// The parameters passed to the `didAddItem` function.
    var didAddItemParameters: [FunctionCalled] {
        self.functionsCalled.filter {
            guard case .didAddItem = $0 else {
                return false
            }
            return true
        }
    }

    /// The parameters passed to the `didDeleteItem` function.
    var didDeleteItemParameters: [FunctionCalled] {
        self.functionsCalled.filter {
            guard case .didDeleteItem = $0 else {
                return false
            }
            return true
        }
    }

    /// The parameters passed to the `didMoveItems` function.
    var didMoveItemsParameters: [FunctionCalled] {
        self.functionsCalled.filter {
            guard case .didMoveItems = $0 else {
                return false
            }
            return true
        }
    }

    /// The parameters passed to the `didDeleteItems` function.
    var didDeleteItemsParameters: [FunctionCalled] {
        self.functionsCalled.filter {
            guard case .didDeleteItems = $0 else {
                return false
            }
            return true
        }
    }

    /// The parameters passed to the `didModify` function.
    var didModifyParameters: [FunctionCalled] {
        self.functionsCalled.filter {
            guard case .didModify = $0 else {
                return false
            }
            return true
        }
    }

    /// The parameters passed to the `validate` function.
    var validateParameters: [FunctionCalled] {
        self.functionsCalled.filter {
            guard case .validate = $0 else {
                return false
            }
            return true
        }
    }

}
