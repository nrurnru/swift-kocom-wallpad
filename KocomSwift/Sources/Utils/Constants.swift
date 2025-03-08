//
//  Constants.swift
//  KocomSwift
//
//  Created by 최광현 on 2/15/25.
//

import Foundation

struct Constants {
    /// KOCOM 패킷 길이
    static let PACKET_LENGTH: UInt = 21
    static let PACKET_VALUE_LENGTH: Int = 16
    
    struct PacketValue {
        /// 0xAA 0x55
        static let HEADER: UInt16 = 43605
        
        /// 0x0D 0x0D
        static let TRAILER: UInt16 = 3341
        
        /// 0x30, 고정값
        static let TYPE_UNKNOWN: UInt8 = 48
        
        /// 0x3E
        static let COMMAND_QUERY: UInt8 = 62
    }
    
    /** KOCOM 패킷 바이트 범위
     
     H    U  S  M  D    S    C  V                C  T
     aa55 30 bc 00 4800 0100 00 1100800000000000 c6 0d0d
     
     */
    struct PacketRange {
        static let HEADER = 0..<2
        static let SIGNAL = 3..<4
        static let MONITOR = 4..<5
        static let DEST = 5..<7
        static let SRC = 7..<9
        static let CMD = 9..<10
        static let VALUE = 10..<18
        static let CHECKSUM = 18..<19
        static let TRAILER = 19..<21
        static let DATA = 2..<18
        static let PAYLOAD = 9..<18
        static let CHECKSUM_TARGET = 2..<18
        
        static let VALUE_FAN_STATE_ONOFF = 0..<2
        static let VALUE_FAN_PRESET = 2..<3
        
        static let VALUE_TEMP_HEATMODE = 0..<1
        static let VALUE_TEMP_AWAY = 1..<2
        static let VALUE_TEMP_SET_TEMP = 2..<3
        static let VALUE_TEMP_CURRENT_TEMP = 4..<5
    }
}

