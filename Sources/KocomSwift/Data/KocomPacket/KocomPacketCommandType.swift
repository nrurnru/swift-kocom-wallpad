//
//  KocomPacketCommandType.swift
//  KocomSwift
//
//  Created by 최광현 on 3/3/25.
//

import Foundation

enum KocomPacketCommandType: UInt8 {
    /// 0x00
    case STATE = 0
    /// 0x01
    case ON = 1
    /// 0x02
    case OFF = 2
    /// 0x3A
    case COMMAND_QUERY = 58
}

