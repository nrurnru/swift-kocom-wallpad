//
//  CommandSendService.swift
//  KocomSwift
//
//  Created by 최광현 on 3/8/25.
//

import Foundation

protocol CommandSendService {
    func commandFanState(state: MQTTFanPayload.State)
    
    func commandFanPreset(preset: MQTTFanPayload.Preset)
    
    func commandThermoState(roomNumber: Int, isOn: MQTTThermoPayload.State)
                                            
    func commandThermoTemp(roomNumber: Int, temp: Int)
}

final class DefaultCommandSendService: CommandSendService {
    private let rs485Service: RS485Service
    
    init(rs485Service: RS485Service) {
        self.rs485Service = rs485Service
    }
    
    func commandFanState(state: MQTTFanPayload.State) {
        let onOff: UInt16 = switch state {
            case .On: 0x1101
            case .Off: 0x0000
        }
        
        let header = Data([
            Constants.PacketValue.HEADER.split.upper,
            Constants.PacketValue.HEADER.split.lower,
        ])
        
        var value = Data([
            Constants.PacketValue.TYPE_UNKNOWN,
            KocomPacketSignalType.SEND_FIRST.rawValue,
            KocomPacketMonitorType.WALLPAD.rawValue,
            KocomPacketDestinationType.FAN.rawValue.split.upper,
            KocomPacketDestinationType.FAN.rawValue.split.lower,
            KocomPacketDestinationType.WALLPAD.rawValue.split.upper,
            KocomPacketDestinationType.WALLPAD.rawValue.split.lower,
            KocomPacketCommandType.STATE.rawValue,
            onOff.split.upper,
            onOff.split.lower,
            MQTTFanPayload.Preset.Medium.value
        ])
        
        self.addPadding(data: &value, until: Constants.PACKET_VALUE_LENGTH)
        let checksum = Data([RawPacket.makeChecksum(data: value)])
        
        let trailer = Data([
            Constants.PacketValue.TRAILER.split.lower,
            Constants.PacketValue.TRAILER.split.upper,
        ])
        
        let packet = header + value + checksum + trailer
        self.rs485Service.writeData(data: packet)
    }
    
    func commandFanPreset(preset: MQTTFanPayload.Preset) {
        // TODO
    }
    
    func commandThermoState(roomNumber: Int, isOn: MQTTThermoPayload.State) {
        // TODO
    }
    
    func commandThermoTemp(roomNumber: Int, temp: Int) {
        // TODO
    }
    
    /// data의 길이가 until이 될 때까지 0x00을 추가합니다.
    private func addPadding(data: inout Data, until: Int) {
        while data.count < until {
            data.append(0x00)
        }
    }
}
