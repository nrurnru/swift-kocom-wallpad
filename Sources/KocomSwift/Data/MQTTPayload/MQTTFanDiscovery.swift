//
//  MQTTFanDiscovery.swift
//  KocomSwift
//
//  Created by 최광현 on 3/2/25.
//

import Foundation

/// [Docs](https://www.home-assistant.io/integrations/fan.mqtt/)
struct MQTTFanDiscovery: Encodable {
    let name: String = "Kocom Wallpad Fan"
    let command_topic: String = "\(Constants.MQTT_COMMON_TOP_TOPIK)/livingroom/fan/command"
    let state_topic: String = "\(Constants.MQTT_COMMON_TOP_TOPIK)/livingroom/fan/state"
    let state_value_template: String = "{{ value_json.state }}"
    let preset_mode_state_topic: String = "\(Constants.MQTT_COMMON_TOP_TOPIK)/livingroom/fan/state"
    let preset_mode_value_template: String = "{{ value_json.preset }}"
    let preset_mode_command_topic: String = "\(Constants.MQTT_COMMON_TOP_TOPIK)/livingroom/fan/set_preset_mode/command"
    let preset_mode_command_template: String = "{{ value }}"
    let preset_modes: [MQTTFanPayload.Preset] = MQTTFanPayload.Preset.allCases
    let payload_on: MQTTFanPayload.State = .On
    let payload_off: MQTTFanPayload.State = .Off
    let qos: Int = 0
    let unique_id: String = "kocom_swift_wallpad_fan"
    let device: MQTTPayloadDevice = .init()
    
    static func topic() -> String {
        "homeassistant/fan/kocom_swift_wallpad_fan/config"
    }
    
    static func fan() -> MQTTFanDiscovery {
        return .init()
    }
}


