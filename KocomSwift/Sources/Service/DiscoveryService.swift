//
//  DiscoveryService.swift
//  KocomSwift
//
//  Created by 최광현 on 2/15/25.
//

import Foundation

/// [Docs](https://www.home-assistant.io/integrations/mqtt)
class DiscoveryService {
    private let mqttService: MQTTService

    init(mqttService: MQTTService) {
        self.mqttService = mqttService
    }
}
