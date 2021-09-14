//
//  File.swift
//  File
//
//  Created by Morgan McColl on 15/9/21.
//

import Foundation

enum CXXSemantics {
    
    case clfsm
    case ucfsm
    case spartanfsm
    
    public init?(semantics: MetaMachine.Semantics) {
        switch semantics {
        case .clfsm:
            self = .clfsm
            return
        case .ucfsm:
            self = .ucfsm
            return
        case . spartanfsm:
            self = .spartanfsm
            return
        default:
            return nil
        }
    }
}
