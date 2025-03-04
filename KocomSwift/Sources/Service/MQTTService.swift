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
    private let discovery: DiscoveryService
    private let mqtt: CocoaMQTT
                              
    init(
        rs485Service: RS485Service,
        discovery: DiscoveryService
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

    func publishPacket(packet: KocomPacket) {
        do {
            if packet.dest.isFan {
                try self.publishFanStatus(packet: packet)
            } else if packet.dest.isThermo {
                try self.publishThermoStatus(packet: packet)
            } else {
                
            }
            try self.publishFanStatus(packet: packet)
        } catch {
            Logging.shared.log(error.localizedDescription)
        }
    }
    
    private func publishFanStatus(packet: KocomPacket) throws {
        let fan = MQTTFanPayload(kocomPacket: packet)
        let data = try CommonJSONEncoder().encode(fan)
        let str = String(data: data, encoding: .utf8) ?? "{}"
        
        self.mqtt.publish(
            "kocom2/livingroom/fan/state",
            withString: str
        )
    }
    
    private func publishThermoStatus(packet: KocomPacket) throws {
        let thermo = MQTTThermoPayload(kocomPacket: packet)
        let data = try CommonJSONEncoder().encode(thermo)
        let str = String(data: data, encoding: .utf8) ?? "{}"
        
        self.mqtt.publish(
            "kocom2/room/thermo/\(packet.dest.roomNumber)/state",
            withString: str
        )
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
