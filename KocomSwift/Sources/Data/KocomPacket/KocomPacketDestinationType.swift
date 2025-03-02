//
//  KocomPacketDestinationType.swift
//  KocomSwift
//
//  Created by 최광현 on 3/3/25.
//

import Foundation

enum KocomPacketDestinationType: UInt16 {
    /// 0x01 0x00
    case WALLPAD = 256
    /// 0x0E 0x00
    case LIGHT = 18432
    /// 0x48 0x00
    case FAN = 13823
    /// 0x36 0x00
    case THERMO_FIRST = 13824
    /// 0x36 0x01
    case THERMO_SECOND = 13825
    /// 0x36 0x02
    case THERMO_THIRD = 13826
    /// 0x36 0x03
    case THERMO_FOURTH = 13827
    
    case UNKNOWN = 0
    
    var isThermo: Bool {
        return (self.rawValue & 0xFF00) == 0x3600
    }
    
    var isFan: Bool {
        return self == .FAN
    }
}
