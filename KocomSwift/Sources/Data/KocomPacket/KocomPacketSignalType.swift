//
//  KocomPacketSignalType.swift
//  KocomSwift
//
//  Created by 최광현 on 3/3/25.
//

import Foundation

enum KocomPacketSignalType: UInt8 {
    /// 0xBC
    case SEND_FIRST = 188
    /// 0xBD
    case SEND_SECOND = 189
    /// 0xDC
    case ACK_FIRST = 220
    /// 0xDD
    case ACK_SECOND = 221
    
    var isACK: Bool {
        self == .ACK_FIRST || self == .ACK_SECOND
    }
    
    var isSend: Bool {
        !self.isACK
    }
}
