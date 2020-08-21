//
//  Operation.swift
//  IIDX
//
//  Created by umeme on 2019/09/02.
//  Copyright © 2019 umeme. All rights reserved.
//

import RealmSwift

class Operation {
    
    var mainVC: MainViewController!
    let myUD: MyUserDefaults = MyUserDefaults()
    
    
    init(mainVC: MainViewController) {
        self.mainVC = mainVC
    }
    
    func doOperation() -> Results<MyScore> {
        Log.debugStart(cls: String(describing: self), method: #function)
        var result: Results<MyScore>!
        
        // タイトルセット
        setTitle()
        // フィルター処理
        result = doFilter()
        // フィルター処理（ライバル）
        result = doRivalFilter(result: result)
        // フィルター処理（タグ）
        result = doTagFilter(result: result)
        // ソート処理
        result = doSort(result: result)
        
        // 結果が0件の場合統計ボタン無効化
        if result.isEmpty {
            mainVC.statisticsBtn.isEnabled = false
            mainVC.statisticsBtn.setImage(UIImage(named: Const.Image.Operation.STATISTICS_NG), for: .normal)
        } else {
            mainVC.statisticsBtn.isEnabled = true
            mainVC.statisticsBtn.setImage(UIImage(named: Const.Image.Operation.STATISTICS_OK), for: .normal)
        }
        
        Log.debugEnd(cls: String(describing: self), method: #function)
        return result
    }
    
    
    /// タイトルをセット
    private func setTitle() {
        Log.debugStart(cls: String(describing: self), method: #function)
        var titleArray: [String] = myUD.getTitleArray()
        var str: String = ""
        
        if titleArray.isEmpty {
            let playStyle: Int = myUD.getPlayStyle()
            if playStyle == Const.Value.PlayStyle.DOUBLE {
                str = Const.Label.Title.DP_ALL
            } else {
                str = Const.Label.Title.SP_ALL
            }
        } else {
            titleArray.remove(value: Const.Label.Title.SP_ALL)
            titleArray.remove(value: Const.Label.Title.DP_ALL)
            for t in titleArray {
                str = str + t + ","
            }
            str = String(str.dropLast())
        }
        mainVC.titleLbl.text = str
        Log.debugEnd(cls: String(describing: self), method: #function)
    }

    
    /// フィルター処理
    private func doFilter() -> Results<MyScore> {
        Log.debugStart(cls: String(describing: self), method: #function)
        // UserDefaultsより設定値取得
        let data: Data = myUD.getCheckDic()
        let checkDic = NSKeyedUnarchiver.unarchiveObject(with: data)
            as? Dictionary<String, [Int]> ?? Dictionary<String, [Int]>()
        let word: String = myUD.getSearchWord()
        
        // 絞り込み
        let realm: MyRealm = MyRealm.init(path: CommonMethod.getScoreRealmPath())
        let keys: [String] = [String](checkDic.keys)
        let values: [[Int]] = [[Int]](checkDic.values)
        var result: Results<MyScore> = realm.readInAnd(MyScore.self, ofTypes: keys, forQuery: values as [[AnyObject]])
        
        // 曲名検索
        if !word.isEmpty {
            result = result.filter("\(MyScore.Types.title.rawValue) CONTAINS[c] %@", word)
        }
        
        Log.debugEnd(cls: String(describing: self), method: #function)
        return result
    }
    
    
    /// フィルター処理（ライバル）
    private func doRivalFilter(result: Results<MyScore>) -> Results<MyScore> {
        Log.debugStart(cls: String(describing: self), method: #function)
        // UserDefaultsより設定値取得
        let data: Data = myUD.getRivalCheckDic()
        let rivalCheckDic = NSKeyedUnarchiver.unarchiveObject(with: data)
            as? Dictionary<Int, [String]> ?? Dictionary<Int, [String]>()
        
        var ret: Results<MyScore>!
        let realm: MyRealm = MyRealm.init(path: CommonMethod.getScoreRealmPath())
        
        if rivalCheckDic.isEmpty {
            // チェックなしの場合は何もしない
            ret = result
        }
        
        // 絞り込み
        for (k, v) in rivalCheckDic {
            ret = result
            
            for iidxId in v {
                var rivalScoreArray: [RivalScore] = [RivalScore]()
                for score in ret {
                    let rivalScore: RivalScore = realm.readEqualAndByPlayStyle(RivalScore.self
                        , ofTypes: [RivalScore.Types.iidxId.rawValue, RivalScore.Types.title.rawValue
                            , RivalScore.Types.difficultyId.rawValue, RivalScore.Types.level.rawValue]
                        , forQuery: [[iidxId] as AnyObject, [score.title] as AnyObject
                            , [score.difficultyId] as AnyObject, [score.level] as AnyObject])
                        .first ?? RivalScore()
                    let mScore: Int = Int(score.score.components(separatedBy: "(")[0] ) ?? 0
                    let rScore: Int = Int(rivalScore.score?.components(separatedBy: "(")[0] ?? "0") ?? 0
                    let mLump: Int = score.clearLump
                    let rLump: Int = rivalScore.clearLump
                    
                    switch k {
                    case Const.Value.RivalFilter.RIVAL_SCORE_WIN:
                        if (rScore > 0) && (mScore > 0) && (mScore > rScore) {
                            rivalScoreArray.append(rivalScore)
                        }
                    case Const.Value.RivalFilter.RIVAL_SCORE_LOSE:
                        if (rScore > 0) && (mScore > 0) && (mScore < rScore) {
                            rivalScoreArray.append(rivalScore)
                        }
                    case Const.Value.RivalFilter.RIVAL_LUMP_WIN:
                        if (mLump != Const.Value.ClearLump.FAILED) && (rLump != Const.Value.ClearLump.NOPLAY)
                            && (mLump > rLump) {
                            rivalScoreArray.append(rivalScore)
                        }
                    case Const.Value.RivalFilter.RIVAL_LUMP_LOSE:
                        if (mLump != Const.Value.ClearLump.NOPLAY) && (rLump != Const.Value.ClearLump.FAILED)
                            && (mLump < rLump) {
                            rivalScoreArray.append(rivalScore)
                        }
                    default:
                        ret = result
                    }
                }
                
                var predicates: [NSPredicate] = [NSPredicate]()
                for r in rivalScoreArray {
                    let predicate
                        = NSPredicate(format:
                            "\(MyScore.Types.title.rawValue) = %@ and \(MyScore.Types.difficultyId.rawValue) = %@ and \(MyScore.Types.level.rawValue) = %@ "
                            , argumentArray: [r.title ?? "", r.difficultyId, r.level])
                    predicates.append(predicate)
                }
                ret = result.filter(NSCompoundPredicate(orPredicateWithSubpredicates: predicates))
            }
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
        return ret
    }
    
    
    /// フィルター処理（タグ）
    private func doTagFilter(result: Results<MyScore>) -> Results<MyScore> {
        Log.debugStart(cls: String(describing: self), method: #function)
        var ret: Results<MyScore>!
        // UserDefaultsより設定値取得
        var tagArray: [String] = myUD.getTagCheckArray()
        
        if tagArray.isEmpty {
            ret = result
        } else {
            // 整形
            for i in 0..<tagArray.count {
                tagArray[i] = "[" + tagArray[i] + "]"
            }
            // 絞り込み
            var predicates: [NSPredicate] = [NSPredicate]()
            for i in 0..<tagArray.count {
                let predicate = NSPredicate(format: "\(MyScore.Types.tag.rawValue) contains %@", argumentArray: [tagArray[i]])
                predicates.append(predicate)
            }
            print(predicates.description)
            ret = result.filter("playStyle = %@", myUD.getPlayStyle())
            ret = ret.filter(NSCompoundPredicate(andPredicateWithSubpredicates: predicates))

            
            let realm: MyRealm = MyRealm.init(path: CommonMethod.getScoreRealmPath())
            ret = realm.readLikeAnd(MyScore.self, ofTypes: MyScore.Types.tag.rawValue
                , forQuery: tagArray as [AnyObject])
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
        return ret
    }
    
    
    /// ソート処理
    private func doSort(result: Results<MyScore>) -> Results<MyScore> {
        Log.debugStart(cls: String(describing: self), method: #function)
        // UserDefaultsより設定値取得
        let code: Int = myUD.getSort()
        var ret: Results<MyScore>!
        var sorts: [SortDescriptor] = [SortDescriptor]()
        
        switch code {
        case Const.Value.Sort.CLEAR_LUMP_ASK:
            sorts.append(SortDescriptor(keyPath:MyScore.Types.clearLump.rawValue, ascending: true))
        case Const.Value.Sort.CLEAR_LUMP_DESK:
            sorts.append(SortDescriptor(keyPath:MyScore.Types.clearLump.rawValue, ascending: false))
        case Const.Value.Sort.DJ_LEVEL_ASK:
            sorts.append(SortDescriptor(keyPath:MyScore.Types.djLevel.rawValue, ascending: true))
        case Const.Value.Sort.DJ_LEVEL_DESK:
            sorts.append(SortDescriptor(keyPath:MyScore.Types.djLevel.rawValue, ascending: false))
        case Const.Value.Sort.LEVEL_ASK:
            sorts.append(SortDescriptor(keyPath:MyScore.Types.level.rawValue, ascending: true))
        case Const.Value.Sort.LEVEL_DESK:
            sorts.append(SortDescriptor(keyPath:MyScore.Types.level.rawValue, ascending: false))
        case Const.Value.Sort.INDEX_ASK:
            sorts.append(SortDescriptor(keyPath:MyScore.Types.title.rawValue, ascending: true))
        case Const.Value.Sort.INDEX_DESK:
            sorts.append(SortDescriptor(keyPath:MyScore.Types.title.rawValue, ascending: false))
        case Const.Value.Sort.SCORE_RATE_ASK:
            sorts.append(SortDescriptor(keyPath:MyScore.Types.scoreRate.rawValue, ascending: true))
        case Const.Value.Sort.SCORE_RATE_DESK:
            sorts.append(SortDescriptor(keyPath:MyScore.Types.scoreRate.rawValue, ascending: false))
        case Const.Value.Sort.VERSION_ASK:
            sorts.append(SortDescriptor(keyPath:MyScore.Types.versionId.rawValue, ascending: true))
        case Const.Value.Sort.VERSION_DESK:
            sorts.append(SortDescriptor(keyPath:MyScore.Types.versionId.rawValue, ascending: false))
        default:
            sorts.append(SortDescriptor(keyPath:MyScore.Types.title.rawValue, ascending: true))
        }
        
        // 第二ソート
        sorts.append(SortDescriptor(keyPath:MyScore.Types.title.rawValue, ascending: true))

        // ソート
        ret = result.sorted(by: sorts)
        
        Log.debugEnd(cls: String(describing: self), method: #function)
        return ret
    }
}
