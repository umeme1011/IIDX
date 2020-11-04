//
//  AccountViewController.swift
//  IIDX
//
//  Created by umeme on 2019/08/28.
//  Copyright © 2019 umeme. All rights reserved.
//

import UIKit
import WebKit

class AccountViewController: UIViewController {

    @IBOutlet weak var idTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    let myUD: MyUserDefaults = MyUserDefaults()
    
    
    override func viewDidLoad() {
        Log.debugStart(cls: String(describing: self), method: #function)
        super.viewDidLoad()
        
        // パスワードを伏せ字にする
        passwordTF.isSecureTextEntry = true
        
        let id = myUD.getCommonId()
        let pass = myUD.getCommonPassword()
        
        if !id.isEmpty {
            idTF.text = id
        }
        if !pass.isEmpty {
            passwordTF.text = pass
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    /// 完了ボタン押下
    @IBAction func tapDoneBtn(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        // ID,PASSWORDを保持
        myUD.setCommonId(id: idTF.text ?? "")
        myUD.setCommonPassword(password: passwordTF.text ?? "")

        Log.debugEnd(cls: String(describing: self), method: #function)
        self.dismiss(animated: false, completion: nil)
    }
    
    
    /// ログアウトボタン押下
    @IBAction func tapLogoutBtn(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        // Cookie削除
        LoginViewController.removeCookie()
        // アラート表示
        CommonMethod.dispAlert(message: Const.Message.LOGOUT_COMPLETE, vc: self)
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    
    /// 戻るボタン押下
    @IBAction func tapBackBtn(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
        self.dismiss(animated: false, completion: nil)
    }
    
    
    /// 右にスワイプ
    @IBAction func swipeRight(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
        self.dismiss(animated: false, completion: nil)
    }
}
