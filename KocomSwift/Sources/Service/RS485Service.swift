//
//  RS485Service.swift
//  KocomSwift
//
//  Created by 최광현 on 2/15/25.
//

import Foundation
import CocoaAsyncSocket

public final class RS485Service: NSObject {
    private let mqttService: MQTTService
    private var socket: GCDAsyncSocket
    
    private let host: String
    private let port: UInt16
    
    init(mqttService: MQTTService) throws {
        guard let host: String = InfoPlistReader.value(for: .RS485_HOST),
              let port: UInt16 = InfoPlistReader.value(for: .RS485_PORT)
        else {
            throw RS485Error.invalidConfig
        }
        
        self.host = host
        self.port = port
        self.mqttService = mqttService
        self.socket = GCDAsyncSocket(delegate: nil, delegateQueue: .global())
        
        super.init()
        
        self.socket.delegate = self
    }
    
    func readData() {
        Logging.shared.log("ReadData Ping", level: .debug)
        
        let trailing = Constants.PacketValue.TRAILER.split
        
        self.socket.readData(
            to: Data([trailing.upper, trailing.lower]),
            withTimeout: -1,
            maxLength: Constants.PACKET_LENGTH,
            tag: 0
        )
    }
    
    func reconnect() {
        Logging.shared.log("TCP Socket try Reconnect after 5 seconds...")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            do {
                try self.connect()
            } catch {
                Logging.shared.log("Reconnect Failed: \(error)", level: .error)
                /// TODO: Reconnect 실패 경우 처리
            }
        }
    }
    
    func connect() throws {
        Logging.shared.log("TCP try Socket Connect")
        
        do {
            try self.socket.connect(
                toHost: self.host,
                onPort: self.port
            )
        } catch {
            throw RS485Error.failedToConnect(description: error.localizedDescription)
        }
    }
    
    func convertPacketToData(data: Data) -> KocomPacket? {
        guard data.count >= Constants.PACKET_LENGTH else {
            Logging.shared.log("RawPacket data too Short: \(data.bigEndianHex)", level: .error)
            return nil
        }
        
        guard let packet = RawPacket(rawData: data) else {
            Logging.shared.log("RawPacket Init Failed: \(data)", level: .error)
            return nil
        }
        
        guard let kocomPacket = KocomPacket(rawPacket: packet) else {
            Logging.shared.log("KocomPacket Init Failed: \(packet)", level: .error)
            return nil
        }
        
        return kocomPacket
    }
        
    func handlePacket(data: Data) {
        guard let kocomPacket = self.convertPacketToData(data: data) else {
            return
        }
        
        if kocomPacket.signal.isACK {
            Logging.shared.log("ACK Packet received: \(kocomPacket)", level: .debug)
        } else {
            Logging.shared.log("Send Packet received: \(kocomPacket)", level: .debug)
        }
        
        self.mqttService.publishPacket(packet: kocomPacket)
    }
}

/// MARK: - GCDAsyncSocketDelegate
extension RS485Service: GCDAsyncSocketDelegate {
    public func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        Logging.shared.log("Connected to \(host):\(port)")
        
        self.readData()
    }
    
    public func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        Logging.shared.log("Data Received: \(data.bigEndianHex)", level: .debug)
        
        self.handlePacket(data: data)
        self.readData()
    }
    
    public func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: (any Error)?) {
        Logging.shared.log("TCP Socket Disconnected \(String(describing: err))", level: .error)
        
        self.reconnect()
    }
}
    

extension RS485Service {
    enum RS485Error: LocalizedError {
        case invalidConfig
        case failedToConnect(description: String)
        
        var errorDescription: String? {
            switch self {
                case .invalidConfig:
                    return "Invalid RS485 Config"
                case .failedToConnect(let description):
                    return "Failed to Connect: \(description)"
            }
        }
    }
}
