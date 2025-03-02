//
//  MQTTPayloadThermo.swift
//  KocomSwift
//
//  Created by 최광현 on 3/2/25.
//

import Foundation

/// [Docs](https://www.home-assistant.io/integrations/climate.mqtt/)
struct MQTTPayloadThermo: Encodable {
    let name: String
    let state_topic: String
    let mode_state_topic: String
    let mode_command_topic: String
    let mode_state_template: String
    let temperature_state_topic: String
    let temperature_command_topic: String
    let temperature_state_template: String
    let current_temperature_topic: String
    let current_temperature_template: String
    let unique_id: String
    let modes: [String]
    let min_temp: Int
    let max_temp: Int
    let retain: Bool
    let qos: Int
    let device: MQTTPayloadDevice
    
    static func topic(roomNumber: Int) -> String {
        "homeassistant/sensor/swift_kocom_\(roomNumber)_thermo/config"
    }

    static func thermo(roomNumber: Int) -> MQTTPayloadThermo {
        self.init(
            name: "Swift Kocom Wallpad Thermostat 2 \(roomNumber)",
            state_topic: "kocom2/room/thermo/\(roomNumber)/state",
            mode_state_topic: "kocom2/room/thermo/\(roomNumber)/mode",
            mode_command_topic: "kocom2/room/thermo/\(roomNumber)/heat_mode/command",
            mode_state_template: "{{ value_json.heat_mode }}",
            temperature_state_topic: "kocom2/room/thermo/\(roomNumber)/state",
            temperature_command_topic: "kocom2/room/thermo/\(roomNumber)/set_temp/command",
            temperature_state_template: "{{ value_json.heat_mode }}",
            current_temperature_topic: "kocom2/room/thermo/\(roomNumber)/state",
            current_temperature_template: "{{ value_json.heat_mode }}",
            unique_id: "swift_kocom_wallpad_thermo_\(roomNumber)",
            modes: ["off", "heat"],
            min_temp: 20,
            max_temp: 25,
            retain: false,
            qos: 0,
            device: .init()
        )
    }
}
