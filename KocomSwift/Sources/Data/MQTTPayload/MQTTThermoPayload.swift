//
//  MQTTThermoPayload.swift
//  KocomSwift
//
//  Created by 최광현 on 3/4/25.
//

import Foundation

/// [Docs](https://www.home-assistant.io/integrations/climate.mqtt/)
struct MQTTThermoPayload: Encodable {
    enum State: String, Encodable {
        case off
        case heat
    }
        
    let heat_mode: State
    let away: Bool
    
    let set_temp: Int // TODO: Double 스펙 리버싱
    let cur_temp: Int // TODO: Double 스펙 리버싱
    
    init(kocomPacket: KocomPacket) {
        let heatMode: UInt8 = kocomPacket
            .value[Constants.PacketRange.VALUE_TEMP_HEATMODE]
            .unsafeBytes()
        
        let away: UInt8 = kocomPacket
            .value[Constants.PacketRange.VALUE_TEMP_AWAY]
            .unsafeBytes()
        
        let setTemp: UInt8 = kocomPacket
            .value[Constants.PacketRange.VALUE_TEMP_SET_TEMP]
            .unsafeBytes()
            
        let curTemp: UInt8 = kocomPacket
            .value[Constants.PacketRange.VALUE_TEMP_CURRENT_TEMP]
            .unsafeBytes()
        
        self.heat_mode = (heatMode == 0x11) ? .heat : .off
        self.away = (away == 0x01)
        self.set_temp = Int(setTemp)
        self.cur_temp = Int(curTemp)
    }
}

