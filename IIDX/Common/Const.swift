//
//  Const.swift
//  IIDX
//
//  Created by umeme on 2019/08/28.
//  Copyright © 2019 umeme. All rights reserved.
//

import UIKit

class Const {
    
    // テスト用
    // DEVELOP true:5thStyleまで同期 false:全バージョン同期（未使用）
    class Mode {
        static let DEVElOP = false
        static let DEBUG_LOG = true
    }
    
    // Version
    class Version {
        static let START_VERSION_NO = 27
        static let CURRENT_VERSION_NO = 28
    }
    
    // Wiki
    class Wiki {
        static let NEW_SONG_LAST_MODIFIED = ""
        static let OLD_SONG_LAST_MODIFIED = ""
        static let OLD_NOTES_LAST_MODIFIED = ""
    }
    
    // Realm
    class Realm {
        static let SCHEMA_VER = 4
        static let CURRENT_SEED_DB_VER = "28.1"
        static let CURRENT_SEED_FILE_NAME = "iidx_seed_\(CURRENT_SEED_DB_VER)"
        static let SCORE_FILE_NAME = "iidx_score"
        static let SYSTEM = "SYSTEM"
        
        let versionNo: Int = MyUserDefaults().getVersion()
        func getSeedDbVer() -> String {
            var ret = ""
            if versionNo == 27 {
                ret = "27.9"
            }
            if versionNo == Const.Version.CURRENT_VERSION_NO {
                ret = Const.Realm.CURRENT_SEED_DB_VER
            }
            return ret
        }
        func getSeedFileName() -> String {
            var ret = ""
            if versionNo == 27 {
                ret = "iidx_seed_\(getSeedDbVer())"
            }
            if versionNo == Const.Version.CURRENT_VERSION_NO {
                ret = Const.Realm.CURRENT_SEED_FILE_NAME
            }
            return ret
        }
    }
    
    // CSV
    class Csv {
        static let CORRECT_TITLE = "CorrectTitle"
        static let SEPARATER = "@@@"
        static let NO_NOTES_TITLE = "NoNotesTitle"
        static let CODE = "Code_20201031"
    }
    
    
    // Segue
    class Segue {
        static let TO_MENU = "toMenu"
        static let TO_LIST = "toList"
        static let TO_SETTING = "toSetting"
        static let TO_LOGIN = "toLogin"
        static let TO_INPUT = "toInput"
        static let TO_SORT = "toSort"
        static let TO_FILTER = "toFilter"
        static let TO_STATISTICS_CL = "toStatisticsCL"
        static let TO_STATISTICS_DL = "toStatisticsDL"
        static let TO_DETAIL = "toDetail"
        static let TO_EDIT_DETAIL = "toEditDetail"
        static let TO_EDIT_SELECT = "toEditSelect"
    }
    
    // URL
    class Url {
        let versionNo: Int = MyUserDefaults().getVersion()
        static let KONAMI = "https://p.eagate.573.jp"
        static let LOGIN = "\(KONAMI)/gate/p/login.html"
        static let LOGIN_COMPLETE = "\(KONAMI)/gate/p/login_complete.html"
        static let LOGIN_COMPLETE_HTTP = "http://p.eagate.573.jp/gate/p/login_complete.html"
        
        func getStatusUrl() -> String {
            let url: String = "\(Const.Url.KONAMI)/game/2dx/\(versionNo)/djdata/status.html"
            return url
        }

        func getRivalListUrl() -> String {
            let url: String = "\(Const.Url.KONAMI)/game/2dx/\(versionNo)/rival/rival_list.html"
            return url
        }

        func getSeriesUrl() -> String {
            let url: String = "\(Const.Url.KONAMI)/game/2dx/\(versionNo)/djdata/music/series.html"
            return url
        }

        func getSeriesRivalUrl() -> String {
            let url: String = "\(Const.Url.KONAMI)/game/2dx/\(versionNo)/djdata/music/series_rival.html"
            return url
        }

        func getDifficultyUrl() -> String {
            let url: String = "\(Const.Url.KONAMI)/game/2dx/\(versionNo)/djdata/music/difficulty.html"
            return url
        }
        
        func getDifficultyRivalUrl() -> String {
            let url: String = "\(Const.Url.KONAMI)/game/2dx/\(versionNo)/djdata/music/difficulty_rival.html"
            return url
        }
        func getCsvUrl() -> String {
            let url: String = "\(Const.Url.KONAMI)/game/2dx/\(versionNo)/djdata/score_download.html"
            return url
        }
        
        // Wiki Url バージョン毎に分岐
        func getWikiOldSongUrl() -> String {
            var ret: String = ""
            if versionNo == 27 {
                ret = "http://bemaniwiki.com/index.php?beatmania%20IIDX%2027%20HEROIC%20VERSE/%B5%EC%B6%CA%A5%EA%A5%B9%A5%C8"
            }
            if versionNo == 28 {
                ret = "http://bemaniwiki.com/index.php?beatmania%20IIDX%2028%20BISTROVER/%B5%EC%B6%CA%A5%EA%A5%B9%A5%C8"
            }

            return ret
        }
        func getWikiOldNotesListUrl() -> String {
            var ret: String = ""
            if versionNo == 27 {
                ret = "http://bemaniwiki.com/index.php?beatmania%20IIDX%2027%20HEROIC%20VERSE/%B5%EC%B6%CA%C1%ED%A5%CE%A1%BC%A5%C8%BF%F4%A5%EA%A5%B9%A5%C8"
            }
            if versionNo == 28 {
                ret = "http://bemaniwiki.com/index.php?beatmania%20IIDX%2028%20BISTROVER/%B5%EC%B6%CA%C1%ED%A5%CE%A1%BC%A5%C8%BF%F4%A5%EA%A5%B9%A5%C8"
            }
            return ret
        }
        func getWikiNewSongListUrl() -> String {
            var ret: String = ""
            if versionNo == 27 {
                ret = "http://bemaniwiki.com/index.php?beatmania%20IIDX%2027%20HEROIC%20VERSE/%BF%B7%B6%CA%A5%EA%A5%B9%A5%C8"
            }
            if versionNo == 28 {
                ret = "http://bemaniwiki.com/index.php?beatmania%20IIDX%2028%20BISTROVER/%BF%B7%B6%CA%A5%EA%A5%B9%A5%C8"
            }
            return ret
        }
    }
    
    // Value
    class Value {
        class PlayStyle {
            static let SINGLE = 0
            static let DOUBLE = 1
        }
        class kindCode {
            static let CLEAR_LUMP = 1
            static let DJ_LEVEL = 2
            static let INDEX = 3
            static let LEVEL = 4
            static let DIFFICULTY = 5
            static let VERSION = 6
            static let SORT = 7
            static let FILTER = 8
            static let NEW_RECORD = 9
            static let RIVAL_FILTER = 10
            static let RIVAL_SCORE_WIN = 11
            static let RIVAL_SCORE_LOSE = 12
            static let RIVAL_LUMP_WIN = 13
            static let RIVAL_LUMP_LOSE = 14
            static let MODE = 15
            static let TAG_FILTER = 16
        }
        class Difficulty {
            static let BEGINNER = 1
            static let NORMAL = 2
            static let HYPER = 3
            static let ANOTHER = 4
            static let LEGGENDARIA = 5
        }
        class ClearLump {
            static let NOPLAY = 1
            static let FAILED = 2
            static let ACLEAR = 3
            static let ECLEAR = 4
            static let CLEAR = 5
            static let HCLEAR = 6
            static let EXHCLEAR = 7
            static let FCOMBO = 8
        }
        class DjLevel {
            static let NOPLAY = 1
            static let F = 2
            static let E = 3
            static let D = 4
            static let C = 5
            static let B = 6
            static let A = 7
            static let AA = 8
            static let AAA = 9
        }
        class Sort {
            static let CLEAR_LUMP_ASK = 101
            static let CLEAR_LUMP_DESK = 201
            static let DJ_LEVEL_ASK = 102
            static let DJ_LEVEL_DESK = 202
            static let MISS_COUNT_ASK = 103
            static let MISS_COUNT_DESC = 203
            static let SCORE_RATE_ASK = 104
            static let SCORE_RATE_DESK = 204
            static let LEVEL_ASK = 105
            static let LEVEL_DESK = 205
            static let INDEX_ASK = 106
            static let INDEX_DESK = 206
            static let VERSION_ASK = 107
            static let VERSION_DESK = 207
        }
        class Filter {
            static let NEW_RECORD = 0
            static let LEVEL = 1
            static let DIFFICULTY = 2
            static let VERSION = 3
            static let CLEAR_LUMP = 4
            static let DJ_LEVEL = 5
            static let INDEX = 6
        }
        class RivalFilter {
            static let RIVAL_SCORE_WIN = 0
            static let RIVAL_SCORE_LOSE = 1
            static let RIVAL_LUMP_WIN = 2
            static let RIVAL_LUMP_LOSE = 3
        }
        class Mode {
            static let IMPORT_MODE = 1
            static let EDIT_MODE = 2
        }
        class TargetPage {
            static let LEVEL = 1
            static let VERSION = 2
            static let CSV = 3
        }
    }

    // Image
    class Image {
//        static let CHECK = "check"
        static let CHECK = "checkmark"
        static let FCOMBO = "fcombo"
        static let FCOMBO_PIE = "fcombo_pie"
        static let FCOMBO_DETAIL = "fcombo_detail"
        static let CHECK_ON = "check_on"
        static let CHECK_OFF = "check_off"
        
        class DjLevel {
            static let F = "F"
            static let E = "E"
            static let D = "D"
            static let C = "C"
            static let B = "B"
            static let A = "A"
            static let AA = "AA"
            static let AAA = "AAA"
        }
        class Operation {
            static let FILTER_OK = "filter_ok"
            static let FILTER_NG = "filter_ng"
            static let SORT_OK = "sort_ok"
            static let SORT_NG = "sort_ng"
            static let STATISTICS_OK = "statistics_ok"
            static let STATISTICS_NG = "statistics_ng"
            static let IMPORT = "import"
            static let IMPORT_CANCEL = "import_cancel"
            static let EDIT = "edit"
        }
        class Button {
            static let SETTING_OK = "setting_ok"
            static let SETTING_NG = "setting_ng"
        }
        class Qpro {
            static let FILE_NAME = "myQpro.png"
        }
    }
    
    // Coloer
    class Color {
        class ClearLump {
            static let NOPLAY = UIColor.gray
            static let FAILED = UIColor.red
            static let ACLEAR = UIColor.magenta
            static let ECLEAR = UIColor(hex: "00ff00")      // lime
            static let CLEAR = UIColor(hex: "00bfff", alpha: 1)     // deepskyblue
            static let HCLEAR = UIColor.white
            static let EXHCLEAR = UIColor.yellow
        }
        class DjLevel {
            static let AAA = UIColor(red: 252/255, green: 42/255, blue: 28/255, alpha: 1)
            static let AA = UIColor(red: 253/255, green: 147/255, blue: 38/255, alpha: 1)
            static let A = UIColor(red: 45/255, green: 252/255, blue: 254/255, alpha: 1)
            static let B = UIColor(red: 39/255, green: 247/255, blue: 45/255, alpha: 1)
            static let C = UIColor(red: 214/255, green: 214/255, blue: 214/255, alpha: 1)
            static let D = UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 1)
            static let E = UIColor(red: 121/255, green: 121/255, blue: 121/255, alpha: 1)
            static let F = UIColor(red: 95/255, green: 94/255, blue: 95/255, alpha: 1)
            static let NOPLAY = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1)
        }
    }

    // ラベル
    class Label {
        static let SP = "SP"
        static let DP = "DP"
        static let LOADING = "Loading..."
        static let SAVING = "Saving..."
        static let COMPLETE = "Complete!"
        static let CANCELED = "Canceled"
        static let FAILED = "Failed"
        static let OK = "OK"
        static let CANCEL = "Cancel"
        
        enum ClearLump: String {
            case NOPLAY
            case FAILED
            case AEASY
            case EASY
            case CLEAR
            case HARD
            case EXHARD
            case FCOMBO
        }
        class Title {
            static let SP_ALL = "SP ALL"
            static let DP_ALL = "DP ALL"
        }
        class Score {
            static let ZERO = "0(0/0)"
            static let OLD_SCORE = "(old)"
            static let NEW_SCORE = "(new)"
            static let GHOST_SCORE = "(ghost)"
            static let HYPHEN = "-"
        }
    }

    // メッセージ
    class Message {
        static let IMPORT_COMPLETE = "スコアデータ取込完了！"
        static let IMPORT_FAILED = "スコアデータの取込に失敗しました。\n公式サイトにデータが存在しない、またはメンテナンス中の可能性があります。"
        static let IMPORT_CANCEL = "スコアデータの取込をキャンセルしました。"
        static let NO_TARGET_ACCOUNT = "取込対象のアカウントを選択してください。"
        static let VERSION_CHANGE_COMFIRM = "バージョンを切り替えます。\nよろしいですか？"
        static let IMPORT_BALLOON = "インポートします。"
        static let IMPORT_CANCEL_BALLOON = "キャンセルします。"
        static let RESET_COMFIRM = "アプリを初期状態に戻します。\nよろしいですか？"
        static let LOGOUT_COMPLETE = "ログアウトしました。"
        static let RESET_COMPLETE = "リセットしました。"
        static let SEED_DB_IMPORT_COMPLETE = "初期データ取り込み完了！"
        static let SEED_DB_UPDATE_COMPLETE = "楽曲データを更新しました！"
        static let NO_TARGET_LEVEL_VERSION = "設定の「取込対象ページ」より取込対象の難易度またはシリーズを選択してください。"
    }
    
    // ログ
    class Log {
        static let INIT_001 = "既存のseedRealmファイルの削除に失敗しました。"
        
        static let COMMONMETHOD_001 = "POSTレスポンス取得エラー"
        static let COMMONMETHOD_002 = "GETレスポンス取得エラー"
        static let COMMONMETHOD_003 = "CSVファイル読み込み失敗"
        static let COMMONMETHOD_004 = "画像保存失敗"
        static let COMMONMETHOD_005 = "画像読込失敗"
        
        static let SCRAPING_001 = "HTML取得失敗 メンテナンス中？"
        static let SCRAPING_002 = "難易度解析エラー"
        static let SCRAPING_003 = "クリアランプ解析エラー"
        static let SCRAPING_004 = "DJレベル解析エラー"
    }
}
