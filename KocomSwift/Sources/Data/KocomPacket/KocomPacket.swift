//
//  File.swift
//  KocomSwift
//
//  Created by 최광현 on 2/16/25.
//

import Foundation

struct KocomPacket {
    let signal: KocomPacketSignalType
    let monitor: KocomPacketMonitorType
    let dest: KocomPacketDestinationType
    let source: KocomPacketDestinationType
    let command: KocomPacketCommandType
    
    let value: Data
    
    
    /// 패킷으로부터 KocomPacket 생성
    /// - Parameter rawPacket: Data를 가지는 RawPacket
    /// - Warning: RawPacket의 데이터가 잘못된 경우 nil 반환
    init?(rawPacket: RawPacket) {
        guard let signal = KocomPacketSignalType(rawValue: .init(bigEndian: rawPacket.signal)) else {
            return nil
        }
        self.signal = signal
        
        guard let monitor = KocomPacketMonitorType(rawValue: .init(bigEndian: rawPacket.monitor)) else {
            return nil
        }
        self.monitor = monitor
        
        let dest = KocomPacketDestinationType(rawValue: .init(bigEndian: rawPacket.dest)) ?? .UNKNOWN
        self.dest = dest
        
        let source = KocomPacketDestinationType(rawValue: .init(bigEndian: rawPacket.src)) ?? .UNKNOWN
        self.source = source
        
        guard let command = KocomPacketCommandType(rawValue: .init(bigEndian: rawPacket.cmd)) else {
            return nil
        }
        self.command = command
        
        self.value = rawPacket.value
    }
}

