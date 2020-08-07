//
//  Calculate.swift
//  IIDX
//
//  Created by umeme on 2019/09/04.
//  Copyright © 2019 umeme. All rights reserved.
//

import UIKit
import RealmSwift

class Calculate {
    
    /// パーセンテージ計算
    static func doCalculate(total: Double, items: Results<Code>, numArray: [Double], view: UIView)
        -> (UIView, [[Int : [String]]]) {
        Log.debugStart(cls: String(describing: self), method: #function)
        var ratioDicArray: [[Int: [String]]] = [[Int: [String]]]()

        // 円グラフ描写
        var endPoint = 0.0
        var startPoint = 0.0
        for i in 0 ..< items.count {
            
            // 割合を求める
            let ratio = Double(numArray[i] / total)
            
            if i == 0 {
                startPoint = 0.0
                endPoint = ratio
            } else {
                startPoint = endPoint * 4
                endPoint += ratio
            }

            let layer = drawPiechart(x: view.frame.origin.x+147-40, y: view.frame.origin.y+180-20
                , startPoint: startPoint, endPoint: endPoint, item: items[i]) // 謎数値
            view.layer.addSublayer(layer)
            
            // TV表示用配列に格納
            ratioDicArray.append([items[i].code : [String(Int(numArray[i])), "\(String(format: "%.1f", ratio * 100))%"]])
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
        return (view, ratioDicArray)
    }
    
    
    /// 円グラフ描写
    static private func drawPiechart(x:CGFloat, y:CGFloat, startPoint:Double, endPoint:Double, item:Code) -> CAShapeLayer {
        Log.debugStart(cls: String(describing: self), method: #function)

        let pi = CGFloat(Double.pi)
        // start point
        let start:CGFloat = CGFloat(startPoint) * pi / 2.0 - (pi / 2.0)
        // end point
        let end:CGFloat = CGFloat(endPoint) * pi * 2.0 - (pi / 2.0)
        
        let path: UIBezierPath = UIBezierPath();
        path.move(to: CGPoint(x:x, y:y))
        // 円弧
        path.addArc(withCenter: CGPoint(x:x, y:y), radius: 100, startAngle: start, endAngle: end, clockwise: true)
        
        let layer = CAShapeLayer()
        
        if item.kindCode == Const.Value.kindCode.CLEAR_LUMP {
            switch item.code {
            case Const.Value.ClearLump.FCOMBO:
                layer.fillColor = UIColor(patternImage: UIImage(named: Const.Image.FCOMBO_PIE)!).cgColor
            case Const.Value.ClearLump.EXHCLEAR:
                layer.fillColor = Const.Color.ClearLump.EXHCLEAR.cgColor
            case Const.Value.ClearLump.HCLEAR:
                layer.fillColor = Const.Color.ClearLump.HCLEAR.cgColor
            case Const.Value.ClearLump.CLEAR:
                layer.fillColor = Const.Color.ClearLump.CLEAR.cgColor
            case Const.Value.ClearLump.ECLEAR:
                layer.fillColor = Const.Color.ClearLump.ECLEAR.cgColor
            case Const.Value.ClearLump.ACLEAR:
                layer.fillColor = Const.Color.ClearLump.ACLEAR.cgColor
            case Const.Value.ClearLump.FAILED:
                layer.fillColor = Const.Color.ClearLump.FAILED.cgColor
            case Const.Value.ClearLump.NOPLAY:
                layer.fillColor = Const.Color.ClearLump.NOPLAY.cgColor
            default:
                layer.fillColor = Const.Color.ClearLump.NOPLAY.cgColor
            }
        } else if item.kindCode == Const.Value.kindCode.DJ_LEVEL {
            switch item.code {
            case Const.Value.DjLevel.AAA:
                layer.fillColor = Const.Color.DjLevel.AAA.cgColor
            case Const.Value.DjLevel.AA:
                layer.fillColor = Const.Color.DjLevel.AA.cgColor
            case Const.Value.DjLevel.A:
                layer.fillColor = Const.Color.DjLevel.A.cgColor
            case Const.Value.DjLevel.B:
                layer.fillColor = Const.Color.DjLevel.B.cgColor
            case Const.Value.DjLevel.C:
                layer.fillColor = Const.Color.DjLevel.C.cgColor
            case Const.Value.DjLevel.D:
                layer.fillColor = Const.Color.DjLevel.D.cgColor
            case Const.Value.DjLevel.E:
                layer.fillColor = Const.Color.DjLevel.E.cgColor
            case Const.Value.DjLevel.F:
                layer.fillColor = Const.Color.DjLevel.F.cgColor
            default:
                layer.fillColor = Const.Color.DjLevel.F.cgColor
            }
        }
        layer.path = path.cgPath
        
        Log.debugEnd(cls: String(describing: self), method: #function)
        return layer
    }
}
