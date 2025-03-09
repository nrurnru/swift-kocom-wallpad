//
//  UInt16+.swift
//  KocomSwift
//
//  Created by 최광현 on 3/2/25.
//

extension UInt16 {
    /// 2바이트 UInt16 값을 2개의 1바이트 UInt8로 분리
    /// - Returns: (lower: 하위 1바이트, upper: 상위 1바이트)
    /// - Note: 0xFF00 -> lower: 0xFF, upper: 0x00으로 분리됩니다.
    var split: (lower: UInt8, upper: UInt8) {
        let lower = UInt8(self & 0xFF)
        let upper = UInt8(self >> 8)
        return (lower, upper)
    }
}
