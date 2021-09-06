//
//  LoginViewController.swift
//  IIDX
//
//  Created by umeme on 2019/08/28.
//  Copyright © 2019 umeme. All rights reserved.
//

import UIKit
import WebKit

class LoginViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    @IBOutlet weak var loginWV: WKWebView!
    @IBOutlet weak var baseView: UIView!
    
    var mainVC: MainViewController = MainViewController.init()
    
    
    override func viewDidLoad() {
        Log.debugStart(cls: String(describing: self), method: #function)
        super.viewDidLoad()
        
        loginWV.navigationDelegate = self
        loginWV.uiDelegate = self
        loginWV.allowsBackForwardNavigationGestures = true

        // ログイン画面表示
        let encodeUrl: String
            = String(Const.Url.LOGIN.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) ?? "")
        if let url: URL = URL(string: encodeUrl) {
            let req: NSURLRequest = NSURLRequest(url: url)
            loginWV.load(req as URLRequest)
        }

        Log.debugEnd(cls: String(describing: self), method: #function)
    }

    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Log.debugStart(cls: String(describing: self), method: #function)

        // ログイン画面にIDとパスワードをセット
        let myUD: MyUserDefaults = MyUserDefaults()
        let id = myUD.getCommonId()
        let password = myUD.getCommonPassword()
        webView.evaluateJavaScript("document.getElementById('id_userId').value=\"\(String(describing: id))\";"
            , completionHandler: nil)
        webView.evaluateJavaScript("document.getElementById('id_password').value=\"\(String(describing: password))\";"
            , completionHandler: nil)
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }


    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction
        , decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        Log.debugStart(cls: String(describing: self), method: #function)

        let url =  navigationAction.request.url
        
        // 20210906 公式サイト仕様変更対応
//        if url == URL(string:Const.Url.LOGIN_COMPLETE){
        if url == URL(string:Const.Url.LOGIN_MYPAGE){
            // ログイン後のcookieを取得
            webView.configuration.websiteDataStore.httpCookieStore.getAllCookies() { (cookies) in
                var cookieStr: String = ""
                for cookie in cookies {
                    // cookieパラメータ整形
                    cookieStr = cookieStr + "\(cookie.name)=\(cookie.value); "
                }
                CommonData.Import.cookieStr = cookieStr
                
                // スコアデータ取り込み処理
                let imp: Import = Import.init(mainVC: self.mainVC)
                imp.doImport()
                
                self.presentingViewController?.dismiss(animated: false, completion: nil)
            }
        }
        
        // 利用規約表示用
        switch navigationAction.navigationType {
        case .linkActivated:
            if navigationAction.targetFrame == nil
                || !navigationAction.targetFrame!.isMainFrame {
                // <a href="..." target="_blank"> が押されたとき
                webView.load(URLRequest(url: url!))
                decisionHandler(.cancel)
                return
            }
        case .backForward:
            break
        case .formResubmitted:
            break
        case .formSubmitted:
            break
        case .other:
            break
        case .reload:
            break
        }
        
        // これがないとエラーになる
        decisionHandler(.allow)
        Log.debugEnd(cls: String(describing: self), method: #function)
    }

    
    /// Closeボタンをタップ
    @IBAction func tapCloseBtn(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
        self.presentingViewController?.dismiss(animated: false, completion: nil)
    }
    
    
    // Cookieを削除
    static func removeCookie() {
        Log.debugStart(cls: String(describing: self), method: #function)
        
        WKWebsiteDataStore.default().removeData(ofTypes: [WKWebsiteDataTypeCookies]
            , modifiedSince: Date(timeIntervalSince1970: 0), completionHandler: {})
        
        Log.debugEnd(cls: String(describing: self), method: #function)
    }
    
    
    private func loadLocalHtml() {
        guard let path: String = Bundle.main.path(forResource: "login", ofType: "html") else { return }
        let localHTMLUrl = URL(fileURLWithPath: path, isDirectory: false)
        loginWV.loadFileURL(localHTMLUrl, allowingReadAccessTo: localHTMLUrl)
    }
}
