//
//  File.swift
//  KocomSwift
//
//  Created by nrurnru on 3/10/25.
//

import Foundation

extension FixedWidthInteger {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<Self>.size)
    }
}
