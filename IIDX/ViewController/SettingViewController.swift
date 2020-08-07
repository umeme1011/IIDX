//
//  SettingViewController.swift
//  IIDX
//
//  Created by umeme on 2019/08/28.
//  Copyright © 2019 umeme. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var settingView: UIView!
    @IBOutlet weak var qproIV: UIImageView!
    
    
    override func viewDidLoad() {
        Log.debugStart(cls: String(describing: self), method: #function)
        super.viewDidLoad()
        
        // クプロ表示
        let image: UIImage = CommonMethod.loadImage(fileName: Const.Image.Qpro.FILE_NAME) ?? UIImage()
        qproIV.image = image
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    
    /// タッチイベント
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        Log.debugStart(cls: String(describing: self), method: #function)
        super.touchesEnded(touches, with: event)
        
        // メニューエリア以外タップ時、メニューを閉じる
        for touch in touches {
            if touch.view?.tag == 1 {
                closeVC()
            }
        }
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    
    /// 左にスワイプ
    @IBAction func swipeLeft(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        closeVC()
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    
    /// 閉じる
    private func closeVC() {
        Log.debugStart(cls: String(describing: self), method: #function)
        UIView.animate(
            withDuration: 0.1,
            delay: 0,
            options: .curveEaseIn,
            animations: {
                self.settingView.layer.position.x = -self.settingView.frame.width
        },
            completion: { bool in
                self.dismiss(animated: true, completion: nil)
        })
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
}
