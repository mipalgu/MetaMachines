//
//  File.swift
//  File
//
//  Created by Morgan McColl on 15/9/21.
//

import Foundation
import Attributes

public struct CXXIncludes: GroupProtocol {
    
    public typealias Root = MetaMachine
    
    public let path = MetaMachine.path.attributes[2]
    
    @TextProperty(
        label: "include_paths",
        validation: { paths in
            paths.maxLength(4096)
        }
    )
    var includePaths
    
    @CodeProperty
    var includes: SchemaAttribute
    
    init(semantics: CXXSemantics) {
        self._includes = CodeProperty(
            label: "includes",
            language: semantics.language,
            validation: { includes in
                includes.maxLength(4096)
            }
        )
    }
    
}
