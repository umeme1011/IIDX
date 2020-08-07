//
//  ModeViewController.swift
//  IIDX
//
//  Created by umeme on 2019/10/06.
//  Copyright © 2019 umeme. All rights reserved.
//

import UIKit
import RealmSwift

class ModeViewController: UIViewController {

    @IBOutlet weak var importCheckIV: UIImageView!
    @IBOutlet weak var editCheckIV: UIImageView!
    
    let myUD: MyUserDefaults = MyUserDefaults()
    var mode: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mode = myUD.getMode()
        if mode == Const.Value.Mode.EDIT_MODE {
            importCheckIV.image = nil
            editCheckIV.image = UIImage(named: Const.Image.CHECK)
        } else {
            importCheckIV.image = UIImage(named: Const.Image.CHECK)
            editCheckIV.image = nil
        }
    }
    
    @IBAction func tapImporModeBtn(_ sender: Any) {
        mode = Const.Value.Mode.IMPORT_MODE
        importCheckIV.image = UIImage(named: Const.Image.CHECK)
        editCheckIV.image = nil
    }
    
    @IBAction func tapEditModeBtn(_ sender: Any) {
        mode = Const.Value.Mode.EDIT_MODE
        importCheckIV.image = nil
        editCheckIV.image = UIImage(named: Const.Image.CHECK)
    }
    
    @IBAction func tapDoneBtn(_ sender: Any) {
        myUD.setMode(mode: mode)
        
        // データ取得処理
        let vc: MainViewController
            = self.presentingViewController?.presentingViewController as! MainViewController
        let operation: Operation = Operation.init(mainVC: vc)
        let score: Results<MyScore> = operation.doOperation()
        // メイン画面のUI処理
        vc.mainUI()
        // リスト画面リロード
        let listVC: ListViewController
            = self.presentingViewController?.presentingViewController?.children[0] as! ListViewController
        listVC.scores = score
        listVC.listTV.reloadData()

        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func tapBackBtn(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func swipeRight(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
}
