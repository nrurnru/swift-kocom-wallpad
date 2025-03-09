//
//  Data+.swift
//  KocomSwift
//
//  Created by 최광현 on 2/15/25.
//

import Foundation

extension Data {
    /// Hex 코드에서 Data로 변환
    /// - Parameter hex: Hex 코드, ex) "FFFFFF"
    /// - Requires: 빅 엔디언 형식으로 입력
    init?(bigEndianHex hex: String) {
        guard !hex.isEmpty, hex.count.isMultiple(of: 2) else {
            return nil
        }
        
        let chars = hex.map { $0 }
        let bytes = stride(from: 0, to: chars.count, by: 2)
            .map { String(chars[$0]) + String(chars[$0 + 1]) }
            .compactMap { UInt8($0, radix: 16) }
        
        guard hex.count / bytes.count == 2 else { return nil }
        self.init(bytes)
    }

    /// Hex 코드로 변환 ex) "ffffff"
    var bigEndianHex: String {
        self.map { String(format: "%02hhx", $0) }.joined()
    }
}

extension Data {
    /// ByteArray로부터 데이터 읽어오기
    func unsafeBytes<T>() -> T {
        withUnsafeBytes { $0.load(as: T.self) }
    }
}
