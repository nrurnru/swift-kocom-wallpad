//
//  MQTTFanPayload.swift
//  KocomSwift
//
//  Created by 최광현 on 3/4/25.
//

import Foundation

/// [Docs](https://www.home-assistant.io/integrations/fan.mqtt/)
struct MQTTFanPayload: Codable {
    enum State: String, Codable,CaseIterable {
        case Off
        case On
    }
    
    enum Preset: String, Codable, CaseIterable {
        case Off
        case Low
        case Medium
        case High
        
        var value: UInt8 {
            switch self {
                case .Off: return 0x00
                case .Low: return 0x40
                case .Medium: return 0x80
                case .High: return 0xC0
            }
        }
        
        init?(value: UInt8) {
            let matched = Self.allCases.first { $0.value == value }
            if let matched {
                self = matched
            } else {
                return nil
            }
        }
    }
    
    let state: State
    let preset: Preset
    
    init(kocomPacket: KocomPacket) {
        let onOff: UInt16 = kocomPacket
            .value[Constants.PacketRange.VALUE_FAN_STATE_ONOFF]
            .unsafeBytes()
        
        let preset: UInt8 = kocomPacket
            .value[Constants.PacketRange.VALUE_FAN_PRESET]
            .unsafeBytes()
        
        if onOff == 0x0111 {
            self.state = .On
        } else if onOff == 0x0100 {
            self.state = .Off
        } else {
            self.state = .Off
        }
        
        self.preset = switch preset {
            case 0x00: .Off
            case 0x40: .Low
            case 0x80: .Medium
            case 0xC0: .High
            default: .Off
        }
    }
}

