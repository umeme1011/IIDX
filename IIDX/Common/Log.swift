//
//  Log.swift
//  IIDX
//
//  Created by umeme on 2019/09/19.
//  Copyright © 2019 umeme. All rights reserved.
//

class Log {
    
    /// デバッグログ出力
    static func debug(cls: String, method: String, msg: String) {
        if Const.Mode.DEBUG_LOG {
            print("[DEBUG]\(cls).\(method) \(msg)")
        }
    }

    /// デバッグログ出力（スタートログ）
    static func debugStart(cls: String, method: String) {
        if Const.Mode.DEBUG_LOG {
            print("[DEBUG]\(cls).\(method) Start")
        }
    }

    /// デバッグログ出力（エンドログ）
    static func debugEnd(cls: String, method: String) {
        if Const.Mode.DEBUG_LOG {
            print("[DEBUG]\(cls).\(method) End")
        }
    }

    /// エラーログ出力
    static func error(cls: String, method: String, msg: String) {
        print("[ERROR]\(cls).\(method) \(msg)")
    }

    /// 情報ログ出力
    static func info(cls: String, method: String, msg: String) {
        print("[INFO]\(cls).\(method) \(msg)")
    }
}
