//
//  KocomPacketPropertiesTests.swift
//  Test
//
//  Created by 최광현 on 3/3/25.
//

import Testing
@testable import KocomSwift

struct KocomPacketPropertiesTests {
    @Test
    func isThermo() async throws {
        #expect(KocomPacketDestinationType.FAN.isFan == true)
        #expect(KocomPacketDestinationType.FAN.isThermo == false)
        #expect(KocomPacketDestinationType.WALLPAD.isThermo == false)
        #expect(KocomPacketDestinationType.LIGHT.isThermo == false)
        
        #expect(KocomPacketDestinationType.THERMO_FIRST.isFan == false)
        #expect(KocomPacketDestinationType.THERMO_FIRST.isThermo == true)
        #expect(KocomPacketDestinationType.THERMO_SECOND.isThermo == true)
        #expect(KocomPacketDestinationType.THERMO_THIRD.isThermo == true)
        #expect(KocomPacketDestinationType.THERMO_FOURTH.isThermo == true)
    }
}
