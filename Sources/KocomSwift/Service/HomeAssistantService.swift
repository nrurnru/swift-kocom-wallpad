//
//  HomeAssistantService.swift
//  KocomSwift
//
//  Created by 최광현 on 2/15/25.
//

import Foundation

/**
 * 처음 Homeassistant에서 MQTT사용시 디바이스 등록
 * [Docs](https://www.home-assistant.io/integrations/mqtt)
 */
final class HomeAssistantService {
    private weak var mqttService: MQTTService?
    
    func setMQTTService(mqttService: MQTTService) {
        self.mqttService = mqttService
    }
    
    func publishDiscovery() {
        self.publishFanDiscovery()
        self.publishThermoDiscovery()
    }
    
    private func publishFanDiscovery() {
        let topic = MQTTFanDiscovery.topic()
        let fan = MQTTFanDiscovery.fan()
        
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
            let topic = MQTTThermoDiscovery.topic(roomNumber: room)
            let thermo = MQTTThermoDiscovery.thermo(roomNumber: room)
            
            do {
                try self.publish(topic: topic, device: thermo)
            } catch {
                Logging.shared.log(error.localizedDescription, level: .error)
            }
        }
    }
    
    private func publish(topic: String, device: Encodable) throws {
        let data = try CommonJSONEncoder().encode(device)
        guard let payload = String(data: data, encoding: .utf8) else {
            throw EncodingError.invalidValue(data, .init(codingPath: [], debugDescription: ""))
        }
        
        self.mqttService?.publish(topic: topic, payload: payload)
    }
    
    
    /// RS485 패킷 뿌리기
    /// - Parameter packet: KocomPacket
    func publishPacket(packet: KocomPacket) {
        do {
            if packet.dest.isFan {
                try self.publishFanStatus(packet: packet)
            } else if packet.dest.isThermo {
                try self.publishThermoStatus(packet: packet)
            } else {
                
            }
        } catch {
            Logging.shared.log(error.localizedDescription)
        }
    }
    
    private func publishFanStatus(packet: KocomPacket) throws {
        let fan = MQTTFanPayload(kocomPacket: packet)
        let data = try CommonJSONEncoder().encode(fan)
        let str = String(data: data, encoding: .utf8) ?? "{}"
        
        self.mqttService?.publish(
            topic: "\(Constants.MQTT_COMMON_TOP_TOPIK)/livingroom/fan/state",
            payload: str
        )
    }
    
    private func publishThermoStatus(packet: KocomPacket) throws {
        let thermo = MQTTThermoPayload(kocomPacket: packet)
        let data = try CommonJSONEncoder().encode(thermo)
        let str = String(data: data, encoding: .utf8) ?? "{}"
        
        self.mqttService?.publish(
            topic: "\(Constants.MQTT_COMMON_TOP_TOPIK)/room/thermo/\(packet.dest.roomNumber)/state",
            payload: str
        )
    }
}
