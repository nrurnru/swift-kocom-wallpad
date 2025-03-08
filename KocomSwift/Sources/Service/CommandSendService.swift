//
//  CommandSendService.swift
//  KocomSwift
//
//  Created by 최광현 on 3/8/25.
//

import Foundation

protocol CommandSendService {
    func commandFanState(isOn: MQTTFanPayload.State)
    
    func commandFanPreset(preset: MQTTFanPayload.Preset)
    
    func commandThermoState(roomNumber: Int, isOn: MQTTThermoPayload.State)
                                            
    func commandThermoTemp(roomNumber: Int, temp: Int)
}
