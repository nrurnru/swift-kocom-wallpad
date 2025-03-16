import Foundation
import MQTTNIO
import NIO

protocol MQTTClientProtocol {
    func connect() throws
    func publish(topic: String, payload: String)
}

/**
 *
 * MQTT 클라이언트 담당 객체
 * 1. 현재 기기 상태를 MQTT 브로커에 전파해 상태 동기화
 * 2. HomeAssistant에서 조작되어 발생한 이벤트를 전달
 * 3. 가용 디바이스에 대한 Discovery 전달
 *
 */
final class MQTTService: MQTTClientProtocol {
    private let rs485Service: RS485Service
    private let homeAssistantService: HomeAssistantService
    private let commandSendService: CommandSendService
    private let mqtt: MQTTClient
    
    init(
        rs485Service: RS485Service,
        homeAssistantService: HomeAssistantService,
        commandSendService: CommandSendService
    ) throws {
        guard let host: String = SettingValueReader.value?.MQTT_HOST,
              let port: UInt16 = SettingValueReader.value?.MQTT_PORT,
              let username: String = SettingValueReader.value?.MQTT_USERNAME,
              let password: String = SettingValueReader.value?.MQTT_PASSWORD else {
            
            Logging.shared.log("Invalid MQTT Config", level: .error)
            throw MQTTError.invalidConfig
        }
        
        let clientID = UUID().uuidString
        
        let mqtt = MQTTClient(
            host: host,
            port: Int(port),
            identifier: clientID,
            eventLoopGroupProvider: .shared(MultiThreadedEventLoopGroup.singleton),
            configuration: .init(
                userName: username,
                password: password
            )
        )
        
        self.rs485Service = rs485Service
        self.homeAssistantService = homeAssistantService
        self.commandSendService = commandSendService
        self.mqtt = mqtt
    }
    
    func connect() throws {
        Logging.shared.log("Connecting to server...")
        
        Task { @MainActor in
            do {
                try await self.mqtt.connect()
                
                self.homeAssistantService.publishDiscovery()
                try await self.subscribe()
                
                self.mqtt.addShutdownListener(named: "") { result in
                    Logging.shared.log("disconnected \(result)", level: .error)
                }
            } catch {
                throw MQTTError.failedToConnect
            }
        }
    }

    func subscribe() async throws {
        let topic = "kocom2/#"
        Logging.shared.log("Subscribing to topic: \(topic)")
        
        try await self.mqtt.subscribe(to: [.init(topicFilter: topic, qos: .atMostOnce)])
        
        self.mqtt.addPublishListener(named: topic) { result in
            switch result {
                case .success(let info):
                    self.handleMQTTMessage(topic: info.topicName, payload: info.payload)
                case .failure(let error):
                    Logging.shared.log("Failed to subscribe \(error)", level: .error)
            }
        }
    }

    func publish(topic: String, payload: String) {
        Logging.shared.log("Publishing to \(topic): \(payload)", level: .debug)
        _ = self.mqtt.publish(to: topic, payload: .init(string: payload), qos: .atLeastOnce)
    }

    func handleMQTTMessage(topic: String, payload: ByteBuffer) {
        guard let bytes = payload.getBytes(at: 0, length: payload.readableBytes),
              let payload = String(data: Data(bytes), encoding: .utf8) else {
            Logging.shared.log("Payload is not a string", level: .error)
            return
        }

        Logging.shared.log("Received message: \(topic) \(payload)", level: .debug)

        let fanDiscovery = MQTTFanDiscovery.fan()
        switch topic {
            case fanDiscovery.command_topic:
                guard let state = MQTTFanPayload.State(rawValue: payload) else {
                    Logging.shared.log("Invalid Payload \(payload)", level: .error)
                    return
                }

                self.commandSendService.commandFanState(state: state)

            case fanDiscovery.preset_mode_command_topic:
                guard let state = MQTTFanPayload.Preset(rawValue: payload) else {
                    Logging.shared.log("Invalid Payload \(payload)", level: .error)
                    return
                }

                self.commandSendService.commandFanPreset(preset: state)

            default:
                let roomNumber: [Int] = [0, 1]
                for room in roomNumber {
                    let thermoDiscovery = MQTTThermoDiscovery.thermo(roomNumber: room)
                    switch topic {
                        case thermoDiscovery.mode_command_topic:
                            guard let state = MQTTThermoPayload.State(rawValue: payload) else {
                                Logging.shared.log("Invalid Payload \(payload)", level: .error)
                                return
                            }

                            self.commandSendService.commandThermoState(roomNumber: room, isOn: state)

                        case thermoDiscovery.temperature_command_topic:
                            guard let double = Double(payload) else {
                                Logging.shared.log("Invalid Payload \(payload)", level: .error)
                                return
                            }

                            self.commandSendService.commandThermoTemp(roomNumber: room, temp: Int(double))

                        default:
                            break
                    }
                }
        }
    }
}

extension MQTTService {
    enum MQTTError: Error {
        case invalidConfig
        case failedToConnect
    }
}
