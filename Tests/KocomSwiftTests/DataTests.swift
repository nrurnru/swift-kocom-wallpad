//
//  DataTests.swift
//  Test
//
//  Created by 최광현 on 3/2/25.
//

import Foundation
import Testing
@testable import KocomSwift

struct DataTests {
    @Test
    func unsafe_bytes() async throws {
        let byteData = Data([0xFF])
        let byte: UInt8 = byteData.unsafeBytes()
        #expect(byte == 0xFF)
        
        let multibyte = Data([0xFF, 0x00]) // Swift는 리틀 엔디언, 255
        let value: UInt16 = multibyte.unsafeBytes()
        #expect(value == 0x00FF)
        
        let multibyte2 = Data([0x00, 0xFF])
        let value2: UInt16 = multibyte2.unsafeBytes()
        #expect(value2 == 0xFF00)
    }
    
    @Test
    func split_bytes() async throws {
        let data = Data([0xFF, 0x00])
        let value: UInt16 = data.unsafeBytes()
        
        let splitted = value.split
        #expect(splitted.lower == 0xFF)
        #expect(splitted.upper == 0x00)
    }
    
    @Test
    func hex() async throws {
        let data = try #require(Data(bigEndianHex: "ff"))
        #expect(data == Data([0xFF]))
        #expect(data.bigEndianHex == "ff")
        
        let multibyte = try #require(Data(bigEndianHex: "ff00"))
        #expect(multibyte == Data([0xFF, 0x00]))
        
        let multibyte2 = try #require(Data(bigEndianHex: "00ff"))
        #expect(multibyte2 == Data([0x00, 0xFF]))
    }
}
