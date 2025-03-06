import Foundation
import CocoaMQTT

protocol MQTTClientProtocol {
    func connect() throws
    func subscribe(topic: String, qos: Int)
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
    private let discovery: HomeAssistantService
    private let mqtt: CocoaMQTT
    
    init(
        rs485Service: RS485Service,
        discovery: HomeAssistantService
    ) throws {
        guard let host: String = InfoPlistReader.value(for: .MQTT_HOST),
              let port: UInt16 = InfoPlistReader.value(for: .MQTT_PORT),
              let username: String = InfoPlistReader.value(for: .MQTT_USERNAME),
              let password: String = InfoPlistReader.value(for: .MQTT_PASSWORD) else {
            
            Logging.shared.log("Invalid MQTT Config", level: .error)
            throw MQTTError.invalidConfig
        }
        
        let clientID = UUID().uuidString
        let mqtt = CocoaMQTT(
            clientID: clientID,
            host: host,
            port: port
        )
        
        mqtt.username = username
        mqtt.password = password
        
        mqtt.allowUntrustCACertificate = true
        mqtt.enableSSL = false
        mqtt.autoReconnect = true
        
        self.rs485Service = rs485Service
        self.discovery = discovery
        self.mqtt = mqtt
        self.mqtt.delegate = self
    }
    
    func connect() throws {
        Logging.shared.log("Connecting to server...")
        
        if !self.mqtt.connect() {
            throw MQTTError.failedToConnect
        }
    }

    func subscribe(topic: String, qos: Int) {
        Logging.shared.log("Subscribing to topic: \(topic) with QoS: \(qos)")
        self.mqtt.subscribe(topic, qos: .qos0)
    }

    func publish(topic: String, payload: String) {
        Logging.shared.log("Publishing to \(topic): \(payload)", level: .debug)
        self.mqtt.publish(topic, withString: payload)
    }

    func handleMQTTMessage(message: CocoaMQTTMessage) {
        guard let payload = message.string else {
            Logging.shared.log("Payload is not a string", level: .error)
            return
        }
        
        let fanDiscovery = MQTTFanDiscovery.fan()
        switch message.topic {
            case fanDiscovery.command_topic:
                guard let state = MQTTFanPayload.State(rawValue: payload) else {
                    Logging.shared.log("Invalid Payload \(message)", level: .error)
                    return
                }
                switch state {
                    case .Off:
                        break
                    case .On:
                        break
                }
                
            case fanDiscovery.preset_mode_command_topic:
                guard let state = MQTTFanPayload.Preset(rawValue: payload) else {
                    Logging.shared.log("Invalid Payload \(message)", level: .error)
                    return
                }
                switch state {
                    case .High:
                        break
                    case .Medium:
                        break
                    case .Low:
                        break
                    case .Off:
                        break
                }
            default:
                let roomNumber: [Int] = [0, 1]
                for room in roomNumber {
                    let thermoDiscovery = MQTTThermoDiscovery.thermo(roomNumber: room)
                    switch message.topic {
                        case thermoDiscovery.temperature_command_topic:
                            guard let double = Double(payload) else {
                                Logging.shared.log("Invalid Payload \(message)", level: .error)
                                return
                            }
                            let temp = Int(double)
                            
                        case thermoDiscovery.mode_command_topic:
                            switch MQTTThermoPayload.State(rawValue: payload) {
                                case .heat:
                                    break
                                case .off:
                                    break
                                case nil:
                                    break
                            }
                        default:
                            break
                    }
                }
        }
    }
}

/// MARK: - CocoaMQTTDelegate
extension MQTTService: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        Logging.shared.log("Connected \(ack)")
        self.subscribe(topic: "kocom2/#", qos: 0)
        self.discovery.publishDiscovery()
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        self.handleMQTTMessage(message: message)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        failed.forEach {
            Logging.shared.log("Failed to subscribe \($0)", level: .error)
        }
        
        success.allValues.forEach {
            Logging.shared.log("Subscribed \($0)")
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        Logging.shared.log("MQTT -> Ping", level: .debug)
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        Logging.shared.log("MQTT <- Pong", level: .debug)
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: (any Error)?) {
        Logging.shared.log("Disconnected \(String(describing: err))", level: .error)
    }
}

extension MQTTService {
    enum MQTTError: Error {
        case invalidConfig
        case failedToConnect
    }
}
