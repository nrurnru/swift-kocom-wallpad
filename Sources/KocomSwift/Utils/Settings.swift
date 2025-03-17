//
//  Settings.swift
//  KocomSwift
//
//  Created by 최광현 on 2/15/25.
//

import Foundation

/// 필요한 설정을 가져오는 클래스
public final class SettingValueReader {
    
    /// Settings.plist에 명시된 프로퍼티
    public struct Setting: Decodable {
        let RS485_HOST: String
        let RS485_PORT: UInt16
        let MQTT_HOST: String
        let MQTT_PORT: UInt16
        let MQTT_USERNAME: String
        let MQTT_PASSWORD: String
    }
    
    /// 설정 객체
    public static var value: Setting!
    
    /// 설정값 로드
    /// - throws: ``SettingError``
    public static func loadEnvironmentValues() throws {
        let environments = ProcessInfo.processInfo.environment
        
        guard let RS485_HOST = environments["RS485_HOST"],
              let RS485_PORT_STR = environments["RS485_PORT"],
              let RS485_PORT = UInt16(RS485_PORT_STR),
              let MQTT_HOST = environments["MQTT_HOST"],
              let MQTT_PORT_STR = environments["MQTT_PORT"],
              let MQTT_PORT = UInt16(MQTT_PORT_STR),
              let MQTT_USERNAME = environments["MQTT_USERNAME"],
              let MQTT_PASSWORD = environments["MQTT_PASSWORD"]
        else {
            throw SettingError()
        }
        
        Self.value = .init(
            RS485_HOST: RS485_HOST,
            RS485_PORT: RS485_PORT,
            MQTT_HOST: MQTT_HOST,
            MQTT_PORT: MQTT_PORT,
            MQTT_USERNAME: MQTT_USERNAME,
            MQTT_PASSWORD: MQTT_PASSWORD
        )
    }
        
    
    /// 값을 가져오는데 실패함
    public struct SettingError: Error {
        
    }
}
