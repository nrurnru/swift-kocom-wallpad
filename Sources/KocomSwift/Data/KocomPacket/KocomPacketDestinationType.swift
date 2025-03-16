//
//  KocomPacketDestinationType.swift
//  KocomSwift
//
//  Created by 최광현 on 3/3/25.
//

import Foundation

enum KocomPacketDestinationType: UInt16 {
    /// 0x01 0x00
    case WALLPAD = 0x0001
    /// 0x0E 0x00
    case LIGHT = 0x000E
    /// 0x48 0x00
    case FAN = 0x0048
    /// 0x36 0x00
    case THERMO_FIRST = 0x0036
    /// 0x36 0x01
    case THERMO_SECOND = 0x0136
    /// 0x36 0x02
    case THERMO_THIRD = 0x0236
    /// 0x36 0x03
    case THERMO_FOURTH = 0x0336
    
    case UNKNOWN = 0
    
    var isThermo: Bool {
        return (self.rawValue & 0xFF) == 0x36
    }
    
    var isFan: Bool {
        return self == .FAN
    }
    
    var roomNumber: Int {
        return Int((self.rawValue & 0xFF00) >> 8)
    }
    
    init(thermoRoomNumber: Int) {
        self = switch thermoRoomNumber {
            case 0: .THERMO_FIRST
            case 1: .THERMO_SECOND
            case 2: .THERMO_THIRD
            case 3: .THERMO_FOURTH
            default: .UNKNOWN
        }
    }
}
