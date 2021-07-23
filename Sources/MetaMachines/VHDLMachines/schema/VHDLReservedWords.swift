//
//  File.swift
//  
//
//  Created by Morgan McColl on 23/7/21.
//

import Foundation

struct VHDLReservedWords {
    
    static let signalTypes: Set<String> = [
        "std_logic",
        "std_ulogic",
        "signed",
        "unsigned",
        "std_logic_vector",
        "std_ulogic_vector",
        "bit",
        "bit_vector",
    ]
    
    static let variableTypes: Set<String> = [
        "boolean",
        "integer",
        "natural",
        "positive",
        "real"
    ]
    
    static let reservedWords: Set<String> = [
        "abs", "access", "after", "alias", "all", "and", "architecture", "array",
        "assert", "attribute", "begin", "block", "body", "buffer", "bus", "case",
        "component", "configuration", "constant", "disconnect", "downto", "else",
        "elsif", "end", "entity", "exit", "file", "for", "function", "generate",
        "generic", "group", "guarded", "if", "impure", "in", "inertial", "inout",
        "is", "label", "library", "linkage", "literal", "loop", "map", "mod", "nand",
        "new", "next", "nor", "not", "null", "of", "on", "open", "or", "others",
        "out", "package", "port", "postponed", "procedure", "process", "pure",
        "range", "record", "register", "reject", "return", "rol", "ror", "select",
        "severity", "signal", "shared", "sla", "sli", "sra", "srl", "subtype",
        "then", "to", "transport", "type", "unaffected", "units", "until", "use",
        "variable", "wait", "when", "while", "with", "xnor", "xor"
    ]
    
    static var allReservedWords: Set<String> {
        signalTypes.union(variableTypes).union(reservedWords)
    }
    
}
