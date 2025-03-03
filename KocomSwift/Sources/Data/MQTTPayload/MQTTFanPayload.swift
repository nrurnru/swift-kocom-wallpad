//
//  MQTTFanPayload.swift
//  KocomSwift
//
//  Created by 최광현 on 3/4/25.
//

import Foundation

/// [Docs](https://www.home-assistant.io/integrations/fan.mqtt/)
struct MQTTFanPayload: Encodable {
    enum State: String, Encodable {
        case Off
        case On
    }
    
    enum Preset: String, Encodable {
        case Off
        case Low
        case Medium
        case High
    }
    
    let state: State
    let preset: Preset
    
    init(kocomPacket: KocomPacket) {
        let onOff: UInt8 = kocomPacket
            .value[Constants.PacketRange.VALUE_FAN_STATE_ONOFF]
            .unsafeBytes()
        
        let preset: UInt8 = kocomPacket
            .value[Constants.PacketRange.VALUE_FAN_PRESET]
            .unsafeBytes()
        
        self.state = (onOff == 0x10) ? .On : .Off
        self.preset = switch preset {
            case 0x00: .Off
            case 0x40: .Low
            case 0x80: .Medium
            case 0xC0: .High
            default: .Off
        }
    }
}

