//
//  LoadCodeCsv.swift
//  IIDX
//
//  Created by umeme on 2020/10/31.
//  Copyright © 2020 umeme. All rights reserved.
//


extension UpdateMasterDB {
    
    /**
     CodeCSVファイル読み込み
     */
    func makeCodeArray() {
        // load csv file
        let codes: [String] = CommonMethod.loadCSVForCode(filename: Const.Csv.CODE)
        
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
    }
}
