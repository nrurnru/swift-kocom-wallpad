//
//  MQTTPayloadDevice.swift
//  KocomSwift
//
//  Created by 최광현 on 3/2/25.
//

import Foundation

/// [Docs](https://developers.home-assistant.io/docs/device_registry_index/)
struct MQTTPayloadDevice: Encodable {
    let name = "Kocom Smart Wallpad Swift"
    let ids = "kocom_smart_wallpad_2"
    let mf = "KOCOM"
    let mdl = "스마트 월패드"
    let sw = "2000.01.01"
    
    static func device() -> MQTTPayloadDevice {
        .init()
    }
}

