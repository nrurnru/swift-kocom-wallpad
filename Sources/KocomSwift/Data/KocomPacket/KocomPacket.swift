//
//  File.swift
//  KocomSwift
//
//  Created by 최광현 on 2/16/25.
//

import Foundation

struct KocomPacket {
    let header: UInt16
    let unknown: UInt8 = Constants.PacketValue.TYPE_UNKNOWN
    let signal: KocomPacketSignalType
    let monitor: KocomPacketMonitorType
    let dest: KocomPacketDestinationType
    let source: KocomPacketDestinationType
    let command: KocomPacketCommandType
    
    let value: Data
    let trailer: UInt16
    
    var rawData: Data {
        let data =
        self.unknown.data +
        self.signal.rawValue.data +
        self.monitor.rawValue.data +
        self.dest.rawValue.data +
        self.source.rawValue.data +
        self.command.rawValue.data +
        self.value
        
        let checksum = Self.makeChecksum(data: data)
        
        return self.header.data + data + checksum.data + self.trailer.data
    }
    
    /// 체크섬 검사
    private static func check(rawData: Data, checksum: UInt8) -> Bool {
        let checksumTarget = rawData[Constants.PacketRange.CHECKSUM_TARGET]
        let calculatedChecksum = Self.makeChecksum(data: checksumTarget)
        
        return calculatedChecksum == checksum
    }
    
    /// KOCOM 패킷 체크섬 값 계산
    /// - Parameter data: 코콤 패킷 데이터
    /// - Returns: 2바이트 Checksum
    /// - Requires: data는 Header, Trailing을 제외한 영역
    /// - Note: 바이트 배열의 합을 256으로 나눈 나머지입니다.
    static func makeChecksum(data: Data) -> UInt8 {
        let sum = data.reduce(0, { UInt16($0) + UInt16($1) })
        return UInt8(sum % (UInt16(UInt8.max) + 1))
    }
}

extension KocomPacket {
    /// 패킷으로부터 KocomPacket 생성
    /// - Parameter rawPacket: Data를 가지는 RawPacket
    /// - Warning: RawPacket의 데이터가 잘못된 경우 nil 반환
    init?(rawData: Data) {
        let headerValue: UInt16 = Data(rawData[Constants.PacketRange.HEADER]).unsafeBytes()
        let signalValue: UInt8 = Data(rawData[Constants.PacketRange.SIGNAL]).unsafeBytes()
        let monitorValue: UInt8 = Data(rawData[Constants.PacketRange.MONITOR]).unsafeBytes()
        let destValue: UInt16 = Data(rawData[Constants.PacketRange.DEST]).unsafeBytes()
        let srcValue: UInt16 = Data(rawData[Constants.PacketRange.SRC]).unsafeBytes()
        let cmdValue: UInt8 = Data(rawData[Constants.PacketRange.CMD]).unsafeBytes()
        
        let valueValue: Data = Data(rawData[Constants.PacketRange.VALUE])
        let checksumValue: UInt8 = Data(rawData[Constants.PacketRange.CHECKSUM]).unsafeBytes()
        let trailerValue: UInt16 = Data(rawData[Constants.PacketRange.TRAILER]).unsafeBytes()
        
        guard KocomPacket.check(rawData: rawData, checksum: checksumValue) else {
            return nil
        }
        
        guard let signal = KocomPacketSignalType(rawValue: signalValue) else {
            return nil
        }
        self.signal = signal
        
        guard let monitor = KocomPacketMonitorType(rawValue: monitorValue) else {
            return nil
        }
        self.monitor = monitor
        
        let dest = KocomPacketDestinationType(rawValue: destValue) ?? .UNKNOWN
        self.dest = dest
        
        let source = KocomPacketDestinationType(rawValue: srcValue) ?? .UNKNOWN
        self.source = source
        
        guard let command = KocomPacketCommandType(rawValue: cmdValue) else {
            return nil
        }
        self.command = command
        
        self.value = valueValue
        self.header = headerValue
        self.trailer = trailerValue
    }
}
