//
//  CategoryPickerViewController.swift
//  taskapp
//
//  Created by 三輪駿 on 2020/12/07.
//

import UIKit
import RealmSwift

class CategoryPickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var pickerView: UIPickerView!
    var closure: ((String) -> Void)?
    var realm = try! Realm()
    var categoryArray = try! Realm().objects(Category.self).sorted(byKeyPath: "id", ascending: true)
    var categories = try! Realm().objects(Category.self).value(forKey: "category") as! [String]
    var inputCategory: String!
    var pickerArray = ["カテゴリを選択してください。"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.dataSource = self
        pickerView.delegate = self
        
        self.preferredContentSize = CGSize(width: 400, height: 200)
        
        pickerArray += categories
        // ピッカーの初期状態を指定する。
        if inputCategory == nil || !categories.contains(inputCategory) {
            pickerView.selectRow(0, inComponent: 0, animated: false)
        } else {
            let row = try! Realm().objects(Category.self).filter("category == %@", inputCategory).first?.value(forKey: "id") as! Int
            pickerView.selectRow(row + 1, inComponent: 0, animated: false)
        }
    }

    // ピッカーの列数を指定するメソッド
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // コンポーネント単位のデータ数を指定するメソッド
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerArray.count
    }
    
    // ピッカーを選択された時のメソッド
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row > 0 {
            closure?(categoryArray[row - 1].category)
        }
    }
    
    // ピッカーに表示する内容を指定するメソッド
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerArray[row]
    }
    
}
