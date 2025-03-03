//
//  MQTTFanDiscovery.swift
//  KocomSwift
//
//  Created by 최광현 on 3/2/25.
//

import Foundation

/// [Docs](https://www.home-assistant.io/integrations/fan.mqtt/)
struct MQTTFanDiscovery: Encodable {
    let name: String = "Kocom Wallpad Fan 2"
    let command_topic: String = "kocom2/livingroom/fan/command"
    let state_topic: String = "kocom2/livingroom/fan/state"
    let state_value_template: String = "{{ value_json.state }}"
    let preset_mode_state_topic: String = "kocom2/livingroom/fan/state"
    let preset_mode_value_template: String = "{{ value_json.state }}"
    let preset_mode_command_topic: String = "kocom2/livingroom/fan/set_preset_mode/command"
    let preset_mode_command_template: String = "{{ value }}"
    let preset_modes: [String] = ["Off", "Low", "Medium", "High"]
    let payload_on: String = "On"
    let payload_off: String = "Off"
    let qos: Int = 0
    let unique_id: String = "swift_kocom_wallpad_fan"
    let device: MQTTPayloadDevice = .init()
    
    static func topic() -> String {
        "homeassistant/fan/swift_kocom_wallpad_fan/config"
    }
    
    static func fan() -> MQTTFanDiscovery {
        return .init()
    }
}


