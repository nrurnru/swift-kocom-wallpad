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
    
    enum Preset: String, CaseIterable {
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

        /// HA fan의 percentage_command_topic/percentage_state_topic에서 쓰는 원시 speed 단계(1~3)
        /// - Note: speed_range_min/max를 1/3으로 잡아, HA가 이 정수 그대로 percentage_command_topic에 보냄
        var speedStep: Int {
            switch self {
                case .Off: return 0
                case .Low: return 1
                case .Medium: return 2
                case .High: return 3
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

        init?(speedStep: Int) {
            switch speedStep {
                case 1: self = .Low
                case 2: self = .Medium
                case 3: self = .High
                default: return nil
            }
        }
    }

    let state: State
    let percentage: Int

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

        self.percentage = Preset(value: preset)?.speedStep ?? 0
    }
}

