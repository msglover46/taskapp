//
//  NewCategoryViewController.swift
//  taskapp
//
//  Created by 三輪駿 on 2020/12/07.
//

import UIKit
import  RealmSwift

class NewCategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    
    var realm = try! Realm()
    var categoryArray = try! Realm().objects(Category.self)
    var categories = try! Realm().objects(Task.self).value(forKey: "category") as! [Category]
    
    // InputViewControllerからの遷移時に 選択ボタンの活性/非活性を制御するメソッドがセットされる。
    var closure: (() -> Void)?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        label.text = nil
        button.isEnabled = false
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
        cell.textLabel?.text = category.title
        
        return cell
    }
    
    // セルが削除可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // Deleteボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            // タスク一覧に使われていないカテゴリーの場合のみ、データベースから削除する。
            if !categories.contains(categoryArray[indexPath.row]) {
                let delCategory = self.categoryArray[indexPath.row].title
                try! realm.write {
                    self.realm.delete(self.categoryArray[indexPath.row])
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
                label.text = "\(delCategory) を削除しました。"
                closure?()

            } else {
                label.text = "タスクに使用しているカテゴリーは削除できません。"
            }
        }
    }
    
    // カテゴリーが入力された時に呼ばれるメソッド
    @IBAction func tapCategory(_ sender: Any) {
        if categoryTextField.text != "" {
            button.isEnabled = true
        } else {
            button.isEnabled = false
        }
    }
    
    @IBAction func editCategory(_ sender: Any) {
        if categoryTextField.text != "" {
            button.isEnabled = true
        } else {
            button.isEnabled = false
        }
    }
    
   // 登録ボタン押下時に呼ばれるメソッド
    @IBAction func tapButton(_ sender: Any) {
        let registedCategories = try! Realm().objects(Category.self).value(forKey: "title") as! [String]
        if !registedCategories.contains(categoryTextField.text!) {
            // 登録済みのカテゴリーに存在しない場合のみ登録する。
            try! realm.write {
                let allCategories = realm.objects(Category.self)
                let registingCategory = Category()
                if allCategories.count != 0 {
                    registingCategory.id = allCategories.max(ofProperty: "id")! + 1
                }
                registingCategory.title = categoryTextField.text!
                realm.add(registingCategory, update: .modified)
                label.text = "\(categoryTextField.text!) を登録しました。"
                closure?()
                tableView.reloadData()
            }
        } else {
            label.text = "\(categoryTextField.text!) はすでに登録されています。"
        }
        categoryTextField.text = nil
    }
}
