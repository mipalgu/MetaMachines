// MockMetaMachineMutator+timesCalled.swift
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

/// Add times called functions.
extension MockMetaMachineMutator {

    /// The amount of times the dependencyLayout property was called.
    var dependencyLayoutTimesCalled: Int {
        self.functionsCalled.filter {
            guard case .dependencyLayout = $0 else { return false }
            return true
        }
        .count
    }

    /// The amount of times the didCreateDependency function was called.
    var didCreateDependencyTimesCalled: Int {
        self.didCreateDependencyParameters.count
    }

    /// The amount of times the didCreateNewState function was called.
    var didCreateNewStateTimesCalled: Int {
        self.didCreateNewStateParameters.count
    }

    /// The amount of times the didChangeStatesName function was called.
    var didChangeStatesNameTimesCalled: Int {
        self.didChangeStatesNameParameters.count
    }

    /// The amount of times the didCreateNewTransition function was called.
    var didCreateNewTransitionTimesCalled: Int {
        self.didCreateNewTransitionParameters.count
    }

    /// The amount of times the didDeleteDependency function was called.
    var didDeleteDependencyTimesCalled: Int {
        self.didDeleteDependencyParameters.count
    }

    /// The amount of times the didDeleteState function was called.
    var didDeleteStateTimesCalled: Int {
        self.didDeleteStateParameters.count
    }

    /// The amount of times the didDeleteTransition function was called.
    var didDeleteTransitionTimesCalled: Int {
        self.didDeleteTransitionParameters.count
    }

    /// The amount of times the didDeleteDependencies function was called.
    var didDeleteDependenciesTimesCalled: Int {
        self.didDeleteDependenciesParameters.count
    }

    /// The amount of times the didDeleteStates function was called.
    var didDeleteStatesTimesCalled: Int {
        self.didDeleteStatesParameters.count
    }

    /// The amount of times the didDeleteTransitions function was called.
    var didDeleteTransitionsTimesCalled: Int {
        self.didDeleteTransitionsParameters.count
    }

    /// The amount of times the update function was called.
    var updateTimesCalled: Int {
        self.updateParameters.count
    }

    /// The amount of times the didAddItem function was called.
    var didAddItemTimesCalled: Int {
        self.didAddItemParameters.count
    }

    /// The amount of times the didMoveItems function was called.
    var didMoveItemsTimesCalled: Int {
        self.didMoveItemsParameters.count
    }

    /// The amount of times the didDeleteItems function was called.
    var didDeleteItemsTimesCalled: Int {
        self.didDeleteItemsParameters.count
    }

    /// The amount of times the didDeleteItem function was called.
    var didDeleteItemTimesCalled: Int {
        self.didDeleteItemParameters.count
    }

    /// The amount of times the didModify function was called.
    var didModifyTimesCalled: Int {
        self.didModifyParameters.count
    }

    /// The amount of times the validate function was called.
    var validateTimesCalled: Int {
        self.validateParameters.count
    }

    /// The amount of times functions and properties were called in this mock.
    var timesCalled: Int {
        self.functionsCalled.count
    }

}
