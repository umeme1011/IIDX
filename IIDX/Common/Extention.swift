//
//  Extention.swift
//  IIDX
//
//  Created by umeme on 2019/08/28.
//  Copyright © 2019 umeme. All rights reserved.
//

import UIKit

/// エンコード追加
extension String.Encoding {
    static let windows31j = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.dosJapanese.rawValue)))
}


/// 値を指定して配列から削除
extension Array where Element: Equatable {
    mutating func remove(value: Element) {
        if let i = self.firstIndex(of: value) {
            self.remove(at: i)
        }
    }
}


/// UIColorでHexを使う
extension UIColor {
    convenience init(hex: String, alpha: CGFloat) {
        let v = Int("000000" + hex, radix: 16) ?? 0
        let r = CGFloat(v / Int(powf(256, 2)) % 256) / 255
        let g = CGFloat(v / Int(powf(256, 1)) % 256) / 255
        let b = CGFloat(v / Int(powf(256, 0)) % 256) / 255
        self.init(red: r, green: g, blue: b, alpha: min(max(alpha, 0), 1))
    }
    
    convenience init(hex: String) {
        self.init(hex: hex, alpha: 1.0)
    }
}


/// URL画像を指定する
extension UIImage {
    public convenience init(url: String) {
        let url = URL(string: url)
        do {
            let data = try Data(contentsOf: url!)
            self.init(data: data)!
            return
        } catch let err {
            Log.error(cls: "UIImage", method: #function, msg: err.localizedDescription)
        }
        self.init()
    }
}


