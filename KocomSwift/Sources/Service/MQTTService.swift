import Foundation
import CocoaMQTT

protocol MQTTClientProtocol {
    func connect() throws
    func subscribe(topic: String, qos: Int)
    func publish(topic: String, payload: String)
}

final class MQTTService: MQTTClientProtocol {
    private let mqtt: CocoaMQTT
                              
    init() throws {
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
        // TODO
    }
    
    func publishFanDiscovery() {
        let topic = MQTTPayloadFan.topic()
        let fan = MQTTPayloadFan.fan()
        
        do {
            try self.publish(topic: topic, device: fan)
            
        } catch {
            Logging.shared.log(error.localizedDescription, level: .error)
        }
    }
    
    func publishThermoDiscovery() {
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
    
    func publish(topic: String, device: Encodable) throws {
        let data = try JSONEncoder().encode(device)
        guard let str = String(data: data, encoding: .utf8) else {
            throw EncodingError.invalidValue(data, .init(codingPath: [], debugDescription: ""))
        }
        
        self.publish(topic: topic, payload: str)
    }
    
    func publishDiscovery() {
        self.publishFanDiscovery()
        self.publishThermoDiscovery()
    }
}

/// MARK: - CocoaMQTTDelegate
extension MQTTService: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        Logging.shared.log("Connected \(ack)")
        self.subscribe(topic: "kocom2/#", qos: 0)
        self.publishDiscovery()
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
