//
//  selectCategoryViewController.swift
//  taskapp
//
//  Created by 三輪駿 on 2020/12/06.
//

import UIKit
import RealmSwift

class SelectCategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let realm = try! Realm()
    var categoryArray = try! Realm().objects(Category.self)
    var closure: ((String) -> Void)?
    var categories = try! Realm().objects(Task.self).value(forKey: "category") as! [String]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.preferredContentSize = CGSize(width: 300, height: 300)
    }

    // データの数（セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能なcellを得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Cellに値を設定する。
        let category = categoryArray[indexPath.row]
        cell.textLabel?.text = category.category
        
        return cell
    }
    
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        closure?(categoryArray[indexPath.row].category)
        dismiss(animated: true, completion: nil)
    }
    
    // セルが削除可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // Deleteボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            // タスク一覧に使われていないカテゴリーの場合のみ、データベースから削除する。
            if !categories.contains(categoryArray[indexPath.row].category) {
                try! realm.write {
                    self.realm.delete(self.categoryArray[indexPath.row])
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
    }
}
