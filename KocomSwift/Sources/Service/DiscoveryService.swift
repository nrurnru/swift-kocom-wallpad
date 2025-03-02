//
//  DiscoveryService.swift
//  KocomSwift
//
//  Created by 최광현 on 2/15/25.
//

import Foundation

/**
 - 처음 Homeassistant에서 MQTT사용시 디바이스 등록
 - [Docs](https://www.home-assistant.io/integrations/mqtt)
 */
final class DiscoveryService {
    private weak var mqttService: MQTTService?
    
    func setMQTTService(mqttService: MQTTService) {
        self.mqttService = mqttService
    }
    
    private func publishFanDiscovery() {
        let topic = MQTTPayloadFan.topic()
        let fan = MQTTPayloadFan.fan()
        
        do {
            try self.publish(topic: topic, device: fan)
        } catch {
            Logging.shared.log(error.localizedDescription, level: .error)
        }
    }
    
    private func publishThermoDiscovery() {
        // TODO: Make this dynamic
        let roomNumber = [0, 1]
        for room in roomNumber {
            let topic = MQTTPayloadThermo.topic(roomNumber: room)
            let thermo = MQTTPayloadThermo.thermo(roomNumber: room)
            
            do {
                try self.publish(topic: topic, device: thermo)
            } catch {
                Logging.shared.log(error.localizedDescription, level: .error)
            }
        }
    }
    
    private func publish(topic: String, device: Encodable) throws {
        let data = try JSONEncoder().encode(device)
        guard let payload = String(data: data, encoding: .utf8) else {
            throw EncodingError.invalidValue(data, .init(codingPath: [], debugDescription: ""))
        }
        
        self.mqttService?.publish(topic: topic, payload: payload)
    }
    
    func publishDiscovery() {
        self.publishFanDiscovery()
        self.publishThermoDiscovery()
    }
}
