//
//  TagViewController.swift
//  IIDX
//
//  Created by umeme on 2019/10/18.
//  Copyright © 2019 umeme. All rights reserved.
//

import UIKit
import RealmSwift

class TagViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tagTV: UITableView!
    
    var scoreRealm: MyRealm!
    var tagArray: [Tag] = [Tag]()
    var tagDeleteArray: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tagTV.delegate = self
        tagTV.dataSource = self
        
        scoreRealm = MyRealm.init(path: CommonMethod.getScoreRealmPath())
        
        // タグ一覧取得
        let tags: Results<Tag> = scoreRealm.readAll(Tag.self)
        print(tags)
        for tag in tags {
            tagArray.append(tag)
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tagArray.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:  "cell", for:indexPath as IndexPath)
        
        cell.textLabel?.textColor = UIColor.darkGray
        cell.textLabel?.text = tagArray[indexPath.row].tag

        return cell
    }
    
    // セルの編集許可
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // スワイプしたセルを削除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            tagDeleteArray.append(tagArray[indexPath.row].tag ?? "")
            tagArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableView.RowAnimation.automatic)
        }
    }

    
    @IBAction func tapAddBtn(_ sender: Any) {
        
        var tf: UITextField = UITextField()
        
        let alert = UIAlertController(title: "New tag", message: "", preferredStyle: .alert)

        let okBtn = UIAlertAction(title: Const.Label.OK, style: .default) { (action) in
            let tag: Tag = Tag()
            tag.tag = tf.text
            if tag.tag != "" {
                self.tagArray.append(tag)
                self.tagTV.reloadData()
            }
        }
        let cancelBtn = UIAlertAction(title: Const.Label.CANCEL, style: .cancel, handler: nil)

        alert.addTextField { (alertTextField) in
//            alertTextField.placeholder = ""
            tf = alertTextField
        }
        alert.addAction(okBtn)
        alert.addAction(cancelBtn)
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func tapDoneBtn(_ sender: Any) {

        // realm的にNGだったので一度新しいArrayに詰め替え・・
        var tagNewArray: [Tag] = [Tag]()
        var id: Int = 1
        for t in tagArray {
            let tag: Tag = Tag()
            tag.id = id
            tag.tag = t.tag
            tagNewArray.append(tag)
//            scoreRealm.create(data: [tag])
            id += 1
        }
        
        // 紐付いているタグを削除
        if !tagDeleteArray.isEmpty {
            let scores: Results<MyScore> = scoreRealm.readContainsForTag(array: tagDeleteArray)
            print(scores)
            for score in scores {
                var tag: String = score.tag ?? ""
                for t in tagDeleteArray {
                    tag.replaceSubrange(tag.range(of: "[" + t + "]")!, with: "")
                }
                if tag.hasPrefix(",") {
                    tag = String(tag.dropFirst())
                }
                if tag.hasSuffix(",") {
                    tag = String(tag.dropLast())
                }
                if let range = tag.range(of: ",,") {
                    tag.replaceSubrange(range, with: ",")
                }
                scoreRealm.updateForTag(score: score, tag: tag)
            }
        }
        
        scoreRealm.deleteAll(Tag.self)
        for tag in tagNewArray {
            scoreRealm.create(data: [tag])
        }
        
        self.dismiss(animated: false, completion: nil)
    }
    
    
    @IBAction func tapBackBtn(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
}
