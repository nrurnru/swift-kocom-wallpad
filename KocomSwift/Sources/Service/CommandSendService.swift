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
        // TODO
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
}
