//
//  Settings.swift
//  KocomSwift
//
//  Created by 최광현 on 2/15/25.
//

import Foundation

/// 메인 번들에서 Settings.plist를 읽어오는 클래스
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
    /// - throws: ``InfoPlistError``
    public static func loadEnvironmentValues() throws {
        let bundle: Bundle
        #if SWIFT_PACKAGE
        bundle = .module
        #else
        bundle = Bundle.main
        #endif
        guard
            let plistURL = bundle.url(forResource: "Settings", withExtension: "plist"),
            let data = try? Data(contentsOf: plistURL),
            let setting = try? PropertyListDecoder().decode(Setting.self, from: data)
        else {
            throw SettingError()
        }
        
        Self.value = setting
    }
        
    
    /// 값을 가져오는데 실패함
    public struct SettingError: Error {
        
    }
}
