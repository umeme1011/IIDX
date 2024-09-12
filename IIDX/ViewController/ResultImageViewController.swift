//
//  ResultImageViewController.swift
//  IIDX
//
//  Created by umeme on 2020/10/08.
//  Copyright © 2020 umeme. All rights reserved.
//

import UIKit
import WebKit

class ResultImageViewController: UIViewController {
    
    
    @IBAction func tapBackBtn(_ sender: Any) {
        Log.debugStart(cls: String(describing: self), method: #function)
        Log.debugEnd(cls: String(describing: self), method: #function)
        self.dismiss(animated: false, completion: nil)
    }
}
