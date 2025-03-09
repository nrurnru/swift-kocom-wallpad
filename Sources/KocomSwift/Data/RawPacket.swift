//
//  RawPacket.swift
//  KocomSwift
//
//  Created by 최광현 on 2/16/25.
//

import Foundation

public struct RawPacket {
    let header: UInt16
    let unknown: UInt8 = Constants.PacketValue.TYPE_UNKNOWN
    let signal: UInt8
    let monitor: UInt8
    let dest: UInt16
    let src: UInt16
    let cmd: UInt8
    let value: Data
    let checksum: UInt8
    let trailer: Data
    let rawData: Data
    
    /// RawData로부터 패킷 생성
    /// - Parameter rawData: 네트워크를 통해 들어온 RawData
    /// - Warning: Checksum이 맞지 않을 시 Fail
    public init?(rawData: Data) {
        self.rawData = rawData
        
        self.header = Data(rawData[Constants.PacketRange.HEADER]).unsafeBytes()
        self.signal = Data(rawData[Constants.PacketRange.SIGNAL]).unsafeBytes()
        self.monitor = Data(rawData[Constants.PacketRange.MONITOR]).unsafeBytes()
        self.dest = Data(rawData[Constants.PacketRange.DEST]).unsafeBytes()
        self.src = Data(rawData[Constants.PacketRange.SRC]).unsafeBytes()
        self.cmd = Data(rawData[Constants.PacketRange.CMD]).unsafeBytes()
        
        self.value = Data(rawData[Constants.PacketRange.VALUE])
        self.checksum = Data(rawData[Constants.PacketRange.CHECKSUM]).unsafeBytes()
        self.trailer = Data(rawData[Constants.PacketRange.TRAILER])
        
        guard self.check(rawData: rawData, checksum: self.checksum) else {
            return nil
        }
    }
    
    /// 체크섬 검사
    private func check(rawData: Data, checksum: UInt8) -> Bool {
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

