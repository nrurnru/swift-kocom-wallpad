//
//  RS485Service.swift
//  KocomSwift
//
//  Created by 최광현 on 2/15/25.
//

import Foundation
import CocoaAsyncSocket

/**
 *
 * RS485 담당 객체
 * 1. KOCOM 월패드에서 전송된 RS485 시리얼 데이터를 읽어와 MQTT로 전송
 * 2. MQTT에서 받은 데이터를 RS485 시리얼 데이터로 변환하여 KOCOM 월패드로 전송
 * 3. EW11 사용 가정, 소켓통신 사용
 *
 */
public final class RS485Service: NSObject {
    private weak var mqttService: MQTTService?
    private var socket: GCDAsyncSocket
    
    private let host: String
    private let port: UInt16
    
    static func initialize() throws -> RS485Service {
        guard let host: String = InfoPlistReader.value(for: .RS485_HOST),
              let port: UInt16 = InfoPlistReader.value(for: .RS485_PORT)
        else {
            throw RS485Error.invalidConfig
        }
        
        let socket = GCDAsyncSocket(delegate: nil, delegateQueue: .global())
        
        return self.init(
            socket: socket,
            host: host,
            port: port
        )
    }
    
    private init(socket: GCDAsyncSocket, host: String, port: UInt16) {
        self.socket = socket
        self.host = host
        self.port = port
        
        super.init()
        self.socket.delegate = self
    }
    
    /// MQTT서비스를 약한 참조로 할당합니다.
    func setMQTTService(_ service: MQTTService) {
        self.mqttService = service
    }
    
    /// AsyncSocket에서 데이터를 읽어옵니다.
    /// - Note: Trailer가 나올 때까지 패킷 길이만큼 읽어옵니다.
    private func readData() {
        let trailing = Constants.PacketValue.TRAILER.split
        
        self.socket.readData(
            to: Data([trailing.upper, trailing.lower]),
            withTimeout: -1,
            maxLength: Constants.PACKET_LENGTH,
            tag: 0
        )
    }
    
    private func reconnect() {
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
    
    /// 연결 시도
    /// - Throws: RS485Error.failedToConnect
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
    
    private func convertPacket(data: Data) -> KocomPacket? {
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
        
    private func handlePacket(data: Data) {
        guard let kocomPacket = self.convertPacket(data: data) else {
            return
        }
        
        switch kocomPacket.command {
            case .COMMAND_QUERY:
                break // TODO
            case .ON, .OFF, .STATE:
                if kocomPacket.signal.isACK {
                    Logging.shared.log("ACK Packet received: \(kocomPacket)", level: .debug)
                    self.mqttService?.publishPacket(packet: kocomPacket)
                } else {
                    // DO NOTHING - Send Packet 무시해도 되는 것으로 판단
                }
        }
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
