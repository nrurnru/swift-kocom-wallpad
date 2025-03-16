//
//  RS485Service.swift
//  KocomSwift
//
//  Created by 최광현 on 2/15/25.
//

import Foundation
import NIO
import NIOFoundationCompat

/**
 *
 * RS485 담당 객체
 * 1. KOCOM 월패드에서 전송된 RS485 시리얼 데이터를 읽어와 MQTT로 전송
 * 2. MQTT에서 받은 데이터를 RS485 시리얼 데이터로 변환하여 KOCOM 월패드로 전송
 * 3. EW11 사용 가정, 소켓통신 사용
 *
 */
public final class RS485Service: ChannelInboundHandler {
    public typealias InboundIn = ByteBuffer
    
    private weak var homeassistantService: HomeAssistantService?
    private let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    private var channel: Channel?
    
    private let host: String
    private let port: UInt16
    

    init() throws {
        guard let host: String = SettingValueReader.value?.RS485_HOST,
              let port: UInt16 = SettingValueReader.value?.RS485_PORT
        else {
            throw RS485Error.invalidConfig
        }
        
        self.host = host
        self.port = port
    }
    
    /// Homeassistant 서비스를 약한 참조로 할당합니다.
    func setHomeassistantService(_ service: HomeAssistantService) {
        self.homeassistantService = service
    }
    
    /// 연결 시도
    func connect() {
        Logging.shared.log("TCP try Socket Connect")
        
        ClientBootstrap(group: self.group)
            .channelInitializer { channel in
                channel.pipeline.addHandler(self)
            }
            .channelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
            .connect(host: self.host, port: Int(port))
            .whenComplete { result in
                switch result {
                    case .success(let channel):
                        Logging.shared.log("Connected to \(self.host):\(self.port)")
                        self.channel = channel
                    case .failure(let error):
                        Logging.shared.log("Failed to connect: \(error.localizedDescription)", level: .error)
                        self.reconnect()
                }
            }
    }
    
    
    private func reconnect() {
        Logging.shared.log("TCP Socket try Reconnect after 5 seconds...")
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
            self.connect()
        }
    }
    
    /// Raw Data에서 KocomPacket으로 변환
    /// - Parameter data: Raw Data
    /// - Returns: KocomPacket, 실패시 nil
    private func convertPacket(data: Data) -> KocomPacket? {
        guard data.count >= Constants.PACKET_LENGTH else {
            Logging.shared.log("RawPacket data too Short: \(data.bigEndianHex)", level: .error)
            return nil
        }
        
        guard let kocomPacket = KocomPacket(rawData: data) else {
            Logging.shared.log("KocomPacket Init Failed: \(data.bigEndianHex)", level: .error)
            return nil
        }
        
        return kocomPacket
    }
    
    /// RS485 시리얼 데이터를 읽어와 MQTT로 전송합니다.
    /// - Parameter data: 읽어온 RS485 시리얼 데이터
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
                    
                    self.homeassistantService?.publishPacket(packet: kocomPacket)
                } else {
                    // DO NOTHING - Send Packet 무시해도 되는 것으로 판단
                }
        }
    }
    
    func writeData(data: Data) {
        guard let channel = self.channel else {
            Logging.shared.log("Channel not connected", level: .error)
            return
        }
        
        guard data.count == Constants.PACKET_LENGTH else {
            Logging.shared.log("Data Length Invalid: \(data.bigEndianHex)", level: .error)
            return
        }
        
        var buffer: ByteBuffer = channel.allocator.buffer(capacity: data.count)
        buffer.writeBytes(data)
        channel.writeAndFlush(buffer)
            .whenComplete { result in
                switch result {
                    case .success:
                        Logging.shared.log("Data Sent: \(data.bigEndianHex)", level: .debug)
                    case .failure(let error):
                        Logging.shared.log("Data send failed: \(error)", level: .error)
                }
            }
    }
    
    func writeData(packet: KocomPacket) {
        self.writeData(data: packet.rawData)
    }
    
    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let buffer = unwrapInboundIn(data)
        let receivedData = buffer.getData(at: 0, length: buffer.readableBytes) ?? Data()
        
        Logging.shared.log("Data Received: \(receivedData.bigEndianHex)", level: .debug)
        
        guard receivedData.count >= Constants.PACKET_LENGTH else {
            Logging.shared.log("Data too short: \(receivedData.bigEndianHex)", level: .error)
            return
        }
            
        let header: UInt16 = receivedData[Constants.PacketRange.HEADER].unsafeBytes()
        guard header == Constants.PacketValue.HEADER else {
            Logging.shared.log("Header not aligned: \(receivedData.bigEndianHex)", level: .debug)
            return
        }
        
        Array(receivedData).chunked(into: Int(Constants.PACKET_LENGTH)).forEach { [weak self] packetData in
            guard let self else { return }
            guard packetData.count == Constants.PACKET_LENGTH else {
                Logging.shared.log("Packet Data Chunk remained: \(Data(packetData).bigEndianHex)", level: .error)
                return
            }
            self.handlePacket(data: Data(packetData))
        }
    }

    public func errorCaught(context: ChannelHandlerContext, error: Error) {
        Logging.shared.log("TCP Socket Error: \(error)", level: .error)
        context.close(promise: nil)
        try? self.channel?.close().wait()
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
