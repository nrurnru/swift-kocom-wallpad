//
//  MQTTThermoDiscovery.swift
//  KocomSwift
//
//  Created by 최광현 on 3/2/25.
//

import Foundation

/// [Docs](https://www.home-assistant.io/integrations/climate.mqtt/)
struct MQTTThermoDiscovery: Encodable {
    let name: String
    let mode_state_topic: String
    let mode_command_topic: String
    let mode_state_template: String
    let temperature_state_topic: String
    let temperature_command_topic: String
    let temperature_state_template: String
    let current_temperature_topic: String
    let current_temperature_template: String
    let unique_id: String
    let modes: [MQTTThermoPayload.State]
    let min_temp: Int
    let max_temp: Int
    let retain: Bool
    let qos: Int
    let device: MQTTPayloadDevice
    
    static func topic(roomNumber: Int) -> String {
        "homeassistant/climate/kocom_swift_thermo_\(roomNumber)/config"
    }
    
    static func thermo(roomNumber: Int) -> MQTTThermoDiscovery {
        self.init(
            name: "Kocom Wallpad Thermostat #\(roomNumber + 1)",
            mode_state_topic: "\(Constants.MQTT_COMMON_TOP_TOPIK)/room/thermo/\(roomNumber)/state",
            mode_command_topic: "\(Constants.MQTT_COMMON_TOP_TOPIK)/room/thermo/\(roomNumber)/heat_mode/command",
            mode_state_template: "{{ value_json.heat_mode }}",
            temperature_state_topic: "\(Constants.MQTT_COMMON_TOP_TOPIK)/room/thermo/\(roomNumber)/state",
            temperature_command_topic: "\(Constants.MQTT_COMMON_TOP_TOPIK)/room/thermo/\(roomNumber)/set_temp/command",
            temperature_state_template: "{{ value_json.set_temp }}",
            current_temperature_topic: "\(Constants.MQTT_COMMON_TOP_TOPIK)/room/thermo/\(roomNumber)/state",
            current_temperature_template: "{{ value_json.cur_temp }}",
            unique_id: "kocom_swift_wallpad_fan_\(roomNumber)",
            modes: MQTTThermoPayload.State.allCases,
            min_temp: 20,
            max_temp: 30,
            retain: false,
            qos: 0,
            device: .init()
        )
    }
}
