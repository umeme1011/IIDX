//
//  LoadCodeCsv.swift
//  IIDX
//
//  Created by umeme on 2020/10/31.
//  Copyright © 2020 umeme. All rights reserved.
//

import RealmSwift

class LoadCodeCsv {
    
    init() {
    }
    
    func doLoadCodeCsv() {
        makeCodeArray()
    }
    
    /**
     CodeCSVファイル読み込み
     */
    private func makeCodeArray() {
        var codeArray: [Code] = [Code]()
        let seedRealm: Realm = CommonMethod.createSeedRealm()
        
//        // 新作対応時SeedDB作成用
//        let seedRealm: Realm = CommonMethod.createCurrentSeedRealm()
        
        // load csv file
        let codes: [String] = loadCSVForCode(filename: Const.Csv.CODE)
        
        for c in codes {
            let code: Code = Code()
            let array: [String] = c.components(separatedBy: ",")
            
            if array[0] == "id" { continue }
        
            code.id = Int(array[0]) ?? 0
            code.kindCode = Int(array[1]) ?? 0
            code.kindName = array[2]
            code.code = Int(array[3]) ?? 0
            code.name = array[4]
            code.sort = Int(array[5]) ?? 0
            
            codeArray.append(code)
        }
        
        // 登録
        try! seedRealm.write {
            let code: Results<Code> = seedRealm.objects(Code.self)
            seedRealm.delete(code)
            // Code TBL
            for code in codeArray {
                seedRealm.add(code)
            }
        }
    }
    
    
    /// Code用CSVファイル読み込み
    private func loadCSVForCode(filename: String) -> [String] {
        var csvArray:[String] = []
        //CSVファイル読み込み
        let csvBundle = Bundle.main.path(forResource: filename, ofType: "csv")
        do {
            //csvBundleのパスを読み込み、UTF8に文字コード変換して、NSStringに格納
            let csvData = try String(contentsOfFile: csvBundle!,
                                     encoding: String.Encoding.utf8)
            var lineChange = csvData
            while true {
                if let range = lineChange.range(of: "\r\n") {
                lineChange.replaceSubrange(range, with: "\n")
                } else {
                    break
                }
            }
            while true {
                if let range = lineChange.range(of: "\r") {
                    lineChange.replaceSubrange(range, with: "\n")
                } else {
                    break
                }
            }
            //"\n"の改行コードで区切って、配列csvArrayに格納する
            csvArray = lineChange.components(separatedBy: "\n")
        } catch {
            print(error.localizedDescription)
        }
        return csvArray
    }
}
