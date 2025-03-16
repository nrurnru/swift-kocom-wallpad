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
    
    /// MARK: Fan
    func commandFanState(state: MQTTFanPayload.State) {
        let onOff: UInt16 = switch state {
            case .On: 0x0111
            case .Off: 0x0000
        }
        
        var value = onOff.data + MQTTFanPayload.Preset.Medium.value.data
        self.addPadding(data: &value, until: Constants.PACKET_VALUE_LENGTH)
        
        let packet = KocomPacket(
            header: Constants.PacketValue.HEADER,
            signal: .SEND_FIRST,
            monitor: .WALLPAD,
            dest: .FAN,
            source: .WALLPAD,
            command: .STATE,
            value: value,
            trailer: Constants.PacketValue.TRAILER
        )
        
        self.rs485Service.writeData(packet: packet)
    }
    
    func commandFanPreset(preset: MQTTFanPayload.Preset) {
        let onOff: UInt16 = switch preset {
            case .Low, .Medium, .High: 0x0111
            case .Off: 0x0000
        }
        
        var value = onOff.data + preset.value.data
        self.addPadding(data: &value, until: Constants.PACKET_VALUE_LENGTH)
        
        let packet = KocomPacket(
            header: Constants.PacketValue.HEADER,
            signal: .SEND_FIRST,
            monitor: .WALLPAD,
            dest: .FAN,
            source: .WALLPAD,
            command: .STATE,
            value: value,
            trailer: Constants.PacketValue.TRAILER
        )
        
        self.rs485Service.writeData(packet: packet)
    }
    
    /// MARK: Thermo
    func commandThermoState(roomNumber: Int, isOn state: MQTTThermoPayload.State) {
        let heatMode: UInt16 = switch state {
            case .heat: 0x0011
            case .off: 0x0001
        }
        
        let destination = KocomPacketDestinationType(thermoRoomNumber: roomNumber)
        let initialTemp: UInt8 = 0x14 // 20
        
        var value = heatMode.data + initialTemp.data
        self.addPadding(data: &value, until: Constants.PACKET_VALUE_LENGTH)
        
        let packet = KocomPacket(
            header: Constants.PacketValue.HEADER,
            signal: .SEND_FIRST,
            monitor: .WALLPAD,
            dest: destination,
            source: .WALLPAD,
            command: .STATE,
            value: value,
            trailer: Constants.PacketValue.TRAILER
        )
            
        self.rs485Service.writeData(packet: packet)
    }
    
    func commandThermoTemp(roomNumber: Int, temp: Int) {
        let heatMode: UInt16 = 0x0011
        let destination = KocomPacketDestinationType(thermoRoomNumber: roomNumber)
        let temperature = UInt8(temp)
        var value = heatMode.data + temperature.data
        self.addPadding(data: &value, until: Constants.PACKET_VALUE_LENGTH)
        
        let packet = KocomPacket(
            header: Constants.PacketValue.HEADER,
            signal: .SEND_FIRST,
            monitor: .WALLPAD,
            dest: destination,
            source: .WALLPAD,
            command: .STATE,
            value: value,
            trailer: Constants.PacketValue.TRAILER
        )
        
        self.rs485Service.writeData(packet: packet)
    }
    
    /// data의 길이가 until이 될 때까지 0x00을 추가합니다.
    private func addPadding(data: inout Data, until: Int) {
        while data.count < until {
            data.append(0x00)
        }
    }
}
