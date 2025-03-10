//
//  KocomPacketTests.swift
//  Test
//
//  Created by 최광현 on 2/15/25.
//

import Foundation
import Testing

struct KocomPacketTests {
    @Test
    func init_data_hex() async throws {
        let hex = "aa5530bc0048000100001101800000000000c70d0d"
        let data = try #require(Data(bigEndianHex: hex))
        
        #expect(data.bigEndianHex.lowercased() == hex)
        #expect(Data(bigEndianHex: "") == nil)
        #expect(Data(bigEndianHex: "a") == nil)
    }
    
    @Test
    func checksum() async throws {
        let hex = "aa5530bc00360101003a00000000000000005e0d0d"
        let data = try #require(Data(bigEndianHex: hex))
        
        let checksumTargetData = data[Constants.PacketRange.CHECKSUM_TARGET]
        let checksum = KocomPacket.makeChecksum(data: checksumTargetData)
        #expect(checksum == 0x5E)
        
        let packet = try #require(RawPacket(rawData: data))
        #expect(packet.checksum == 0x5E)
    }
    
    @Test
    func init_raw_packet() async throws {
        let hex = "aa5530bc0048000100001101800000000000c70d0d"
        let data = try #require(Data(bigEndianHex: hex))
        let packet = try #require(RawPacket(rawData: data))
        
        #expect(data == packet.rawData)
        
        let checksumCorruptedHex = "aa5530bc0048000100001101800000000000cc0d0d"
        let checksumCorruptedData = try #require(Data(bigEndianHex: checksumCorruptedHex))
        let checksumCorruptedPacket = RawPacket(rawData: checksumCorruptedData)
        
        #expect(checksumCorruptedPacket == nil)
    }
    
    @Test
    func init_kocom_packet() async throws {
        let hex = "aa5530bc00360101003a00000000000000005e0d0d"
        let data = try #require(Data(bigEndianHex: hex))
        let packet = try #require(RawPacket(rawData: data))
        let kocomPacket = try #require(KocomPacket(rawPacket: packet))
        
        #expect(kocomPacket.signal == .SEND_FIRST)
        #expect(kocomPacket.monitor == .WALLPAD)
        #expect(kocomPacket.dest == .THERMO_SECOND)
        #expect(kocomPacket.source == .WALLPAD)
    }
}
