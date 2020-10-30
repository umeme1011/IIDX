//
//  Common.swift
//  IIDX
//
//  Created by umeme on 2019/08/28.
//  Copyright © 2019 umeme. All rights reserved.
//

import UIKit
import RealmSwift

class CommonMethod {
    
    /*
     Realm作成
     */
    static func createRealm(path: String) -> Realm {
        let realm: Realm = try! Realm(fileURL: URL(fileURLWithPath: path))
        return realm
    }
    
    /*
     Seed Realm 作成
     */
    static func createSeedRealm() -> Realm {
        return createRealm(path: getSeedRealmPath())
    }

    /*
     Score Realm 作成
     */
    static func createScoreRealm() -> Realm {
        return createRealm(path: getScoreRealmPath())
    }
    
    /// シードRealmファイルのパスを取得
    static func getSeedRealmPath() -> String {
        let documentDir: NSString
            = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let path = documentDir.appendingPathComponent("\(Const.Realm.SEED_FILE_NAME).realm")
        return path
    }
    
    
    /// スコアRealmファイルのパスを取得
    static func getScoreRealmPath() -> String {
        let version: Int = MyUserDefaults().getVersion()
        
        let documentDir: NSString
            = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let path = documentDir.appendingPathComponent("\(Const.Realm.SCORE_FILE_NAME)_\(version).realm")
        return path
    }

    
    /// POSTリクエエスト
    static func postRequest(dataUrl: String, postStr: String, cookieStr: String) -> NSData {
        let req = NSMutableURLRequest(url: URL(string: dataUrl)!)
        let postData = postStr.data(using: String.Encoding.utf8)
        req.setValue(cookieStr, forHTTPHeaderField: "Cookie")
        req.httpMethod = "POST"
        req.httpBody = postData
        let myHttpSession = HttpClientImpl()
        let (data, _, _) = myHttpSession.execute(request: req as URLRequest)
        
        if data == nil {
            Log.error(cls: String(describing: self), method: #function, msg: Const.Log.COMMONMETHOD_001)
        }
        
        return data ?? NSData()
    }
    
    
    /// GETリクエエスト
    static func getRequest(dataUrl: String, cookieStr: String) -> NSData {
        let req = NSMutableURLRequest(url: URL(string: dataUrl)!)
        req.setValue(cookieStr, forHTTPHeaderField: "Cookie")
        let myHttpSession = HttpClientImpl()
        let (data, _, _) = myHttpSession.execute(request: req as URLRequest)
        
        if data == nil {
            Log.error(cls: String(describing: self), method: #function, msg: Const.Log.COMMONMETHOD_002)
        }
        
        return data ?? NSData()
    }

    /// GETリクエエスト（cookieなし）
    static func getRequest(dataUrl: String) -> NSData {
        let req = NSMutableURLRequest(url: URL(string: dataUrl)!)
        let myHttpSession = HttpClientImpl()
        let (data, _, _) = myHttpSession.execute(request: req as URLRequest)
        
        if data == nil {
            Log.error(cls: String(describing: self), method: #function, msg: Const.Log.COMMONMETHOD_002)
        }
        
        return data ?? NSData()
    }

    
    /// アラート表示（OKのみ）
    static func dispAlert(message: String, vc: UIViewController) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertController.Style.alert)
        let okBtn = UIAlertAction(title: Const.Label.OK, style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okBtn)
        vc.present(alert, animated: false, completion: nil)
    }

    
    /// 現在表示されているVCを取得
    static func getTopViewController() -> UIViewController? {
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            var topViewControlelr: UIViewController = rootViewController
            
            while let presentedViewController = topViewControlelr.presentedViewController {
                topViewControlelr = presentedViewController
            }
            
            return topViewControlelr
        } else {
            return nil
        }
    }

    
    /// CSVファイル読み込み
    static func loadCSV(filename: String) -> [String] {
        var csvArray:[String] = []
        //CSVファイル読み込み
        let csvBundle = Bundle.main.path(forResource: filename, ofType: "csv")
        do {
            //csvBundleのパスを読み込み、UTF8に文字コード変換して、NSStringに格納
            let csvData = try String(contentsOfFile: csvBundle!,
                                     encoding: String.Encoding.utf8)
            //改行コードが"\r"で行なわれている場合は"\n"に変更する
            let lineChange = csvData.replacingOccurrences(of: "\r", with: "\n")
            //"\n"の改行コードで区切って、配列csvArrayに格納する
            csvArray = lineChange.components(separatedBy: "\n")
        } catch {
            Log.error(cls: String(describing: self), method: #function
                , msg: error.localizedDescription)
        }
        return csvArray
    }
    
    
    /// ファイル名を指定してDocument配下に画像を保存
    static func saveImage (image: UIImage, fileName: String ) {
        let pngImageData: Data = image.pngData() ?? Data()
        let path: String = fileInDocumentsDirectory(filename: fileName)
        do {
            try pngImageData.write(to: URL(fileURLWithPath: path), options: .atomic)
        } catch {
            Log.error(cls: String(describing: self), method: #function
                , msg: error.localizedDescription)
        }
    }
    
    /// ファイル名を指定して画像を取得
    static func loadImage(fileName: String) -> UIImage? {
        let path: String = fileInDocumentsDirectory(filename: fileName)
        let image = UIImage(contentsOfFile: path)
        if image == nil {
            Log.error(cls: String(describing: self), method: #function, msg: Const.Log.COMMONMETHOD_004)
        }
        return image
    }
    
    /// ディレクトリのパスにファイル名をつなげてファイルのフルパスを作る
    static func fileInDocumentsDirectory(filename: String) -> String {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
        let fileURL = documentsURL.appendingPathComponent(filename)
        return fileURL!.path
    }
    
    
    /// 文字列を改行する
    static func newLineString(str: String, separater: String) -> String {
        Log.debugStart(cls: String(describing: self), method: #function)
        var sStr: String = str
        if !str.isEmpty && str.contains(separater) {
            
            // 改行除外タイトル
            if str == "(This Is Not) The Angels"
                || (separater == "～" && str == "CaptivAte～裁き～(SUBLIME TECHNO MIX)")
                || (separater == "～" && str == "†渚の小悪魔ラヴリィ～レイディオ†(IIDX EDIT)")
                || str == "超!!遠距離らぶ♡メ～ル"
                || str == "Won(*3*)Chu KissMe!"
            {
                return sStr
            }
            
            let sArray: [String] = str.components(separatedBy: separater)
            sStr = sArray[0] + "\n" + separater + sArray[1]
            if separater == "～" {
                sStr += "～"
            }
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
        return sStr
    }

    
    /// スコアレート計算
    static func calcurateScoreRate(score: String, totalNotes: Int) -> Double {
        Log.debugStart(cls: String(describing: self), method: #function)
        var ret = 0.0
        
        if score.isEmpty {
            return ret
        }
        if totalNotes == 0 {
            return ret
        }
        
        let scoreDouble: Double = Double(score.components(separatedBy: "(")[0]) ?? 0.0
        let theoreticalValue: Double = Double(totalNotes * 2)
        if theoreticalValue != 0 {
            ret = (scoreDouble / theoreticalValue) * 100.0
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
        return ret
    }
    
    /**
     プラス・マイナス計算
     MAXスコアの
     AAA  8/9以上
     AA  7/9以上
     A   6/9以上
     B   5/9以上
     C   4/9以上
     D   3/9以上
     E   2/9以上
     F   2/9未満
     各スコア間の差 / 2 以上はマイナス、以下はプラス
     */
    static func calcuratePlusMinus(score: String, totalNotes: Int) -> String {
        Log.debugStart(cls: String(describing: self), method: #function)
        var ret = ""
        
        var djLevelInt = 0
        let scoreDouble: Double = Double(score.components(separatedBy: "(")[0]) ?? 0.0
        if scoreDouble == 0 {
            return ret
        }
        let maxScore = totalNotes * 2
        let dev = Double(maxScore) / 9
        var plusMinus = ""
        
        // MAX
        if scoreDouble == Double(maxScore) {
            plusMinus = "+0"
            djLevelInt = 10

        } else {
            for i in 2..<10 {
                if dev * Double(i) > scoreDouble {
                    if i == 2 {
                        let up = dev * Double(i)
                        plusMinus = "-" + String(Int(ceil(up) - scoreDouble))
                        djLevelInt = i
                        break
                    }
                    let up = dev * Double(i)
                    let down = dev * Double(i - 1)
                    let border = ((up - down) / 2) + down
                    if scoreDouble >= border {
                        plusMinus = "-" + String(Int(ceil(up) - scoreDouble))
                        djLevelInt = i + 1
                    } else {
                        plusMinus = "+" + String(Int(scoreDouble - ceil(down)))
                        djLevelInt = i
                    }
                    break
                }
            }
        }
        
        var djLevelStr = ""
        switch djLevelInt {
        case 10:
            djLevelStr = "MAX"
        case Const.Value.DjLevel.AAA:
            djLevelStr = "AAA"
        case Const.Value.DjLevel.AA:
            djLevelStr = "AA"
        case Const.Value.DjLevel.A:
            djLevelStr = "A"
        case Const.Value.DjLevel.B:
            djLevelStr = "B"
        case Const.Value.DjLevel.C:
            djLevelStr = "C"
        case Const.Value.DjLevel.D:
            djLevelStr = "D"
        case Const.Value.DjLevel.E:
            djLevelStr = "E"
        case Const.Value.DjLevel.F:
            djLevelStr = "F"
        default:
            print("処理なし")
        }
        
        ret = djLevelStr + plusMinus
        
        Log.debugEnd(cls: String(describing: self), method: #function)
        return ret
    }
}
