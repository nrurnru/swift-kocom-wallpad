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
        let onOff: UInt16 = switch preset {
            case .Low, .Medium, .High: 0x1101
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
            preset.value
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
    
    /// MARK: Thermo
    func commandThermoState(roomNumber: Int, isOn state: MQTTThermoPayload.State) {
        let heatMode: UInt16 = switch state {
            case .heat: 0x1100
            case .off: 0x0100
        }
        
        let header = Data([
            Constants.PacketValue.HEADER.split.upper,
            Constants.PacketValue.HEADER.split.lower,
        ])
        
        let destination: KocomPacketDestinationType = switch roomNumber {
            case 0: .THERMO_FIRST
            case 1: .THERMO_SECOND
            case 2: .THERMO_THIRD
            case 3: .THERMO_FOURTH
            default: .UNKNOWN
        }
        
        let initialTemp: UInt8 = 0x14 // 20
        
        var value = Data([
            Constants.PacketValue.TYPE_UNKNOWN,
            KocomPacketSignalType.SEND_FIRST.rawValue,
            KocomPacketMonitorType.WALLPAD.rawValue,
            destination.rawValue.split.upper,
            destination.rawValue.split.lower,
            KocomPacketDestinationType.WALLPAD.rawValue.split.upper,
            KocomPacketDestinationType.WALLPAD.rawValue.split.lower,
            KocomPacketCommandType.STATE.rawValue,
            heatMode.split.upper,
            heatMode.split.lower,
            initialTemp
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
    
    func commandThermoTemp(roomNumber: Int, temp: Int) {
        let heatMode: UInt16 = 0x1100
        
        let header = Data([
            Constants.PacketValue.HEADER.split.upper,
            Constants.PacketValue.HEADER.split.lower,
        ])
        
        let destination: KocomPacketDestinationType = switch roomNumber {
            case 0: .THERMO_FIRST
            case 1: .THERMO_SECOND
            case 2: .THERMO_THIRD
            case 3: .THERMO_FOURTH
            default: .UNKNOWN
        }
        
        let temperature = UInt8(temp)
        
        var value = Data([
            Constants.PacketValue.TYPE_UNKNOWN,
            KocomPacketSignalType.SEND_FIRST.rawValue,
            KocomPacketMonitorType.WALLPAD.rawValue,
            destination.rawValue.split.upper,
            destination.rawValue.split.lower,
            KocomPacketDestinationType.WALLPAD.rawValue.split.upper,
            KocomPacketDestinationType.WALLPAD.rawValue.split.lower,
            KocomPacketCommandType.STATE.rawValue,
            heatMode.split.upper,
            heatMode.split.lower,
            temperature
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
    
    /// data의 길이가 until이 될 때까지 0x00을 추가합니다.
    private func addPadding(data: inout Data, until: Int) {
        while data.count < until {
            data.append(0x00)
        }
    }
}
