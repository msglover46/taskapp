//
//  InputViewController.swift
//  taskapp
//
//  Created by 三輪駿 on 2020/11/30.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var button: UIButton!
    
    var task: Task!
    let realm = try! Realm()
    var viewTitle = ""
 

    override func viewDidLoad() {
        super.viewDidLoad()

        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        titleTextField.text = task.title
        categoryTextField.text = task.category
        contentsTextView.text = task.contents
        datePicker.date = task.date
        
        checkButton()
    }
    
    @objc func dismissKeyboard() {
        // キーボードを閉じる
        view.endEditing(true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        // タイトルとカテゴリーの両方を入力しないとタスクとして登録しないようにする。
        if titleTextField.text != "" && categoryTextField.text != "" {
            try! realm.write {
                self.task.title = self.titleTextField.text!
                self.task.category = self.categoryTextField.text!
                self.task.contents = self.contentsTextView.text
                self.task.date = self.datePicker.date
                self.realm.add(self.task, update: .modified)
            }
            setNotification(task: task)
            
            // 入力されたカテゴリーが未登録の場合、登録する。
            if realm.objects(Category.self).filter("category == %@", categoryTextField.text).count == 0 {
                try! realm.write {
                    let allCategories = realm.objects(Category.self)
                    let registingCategory = Category()
                    if allCategories.count != 0 {
                        registingCategory.id = allCategories.max(ofProperty: "id")! + 1
                    }
                    registingCategory.category = categoryTextField.text!
                    realm.add(registingCategory, update: .modified)
                }
            }
        }
        super.viewWillDisappear(animated)
    }

    // タスクのローカル通知を登録する
    func setNotification(task: Task) {
        let content = UNMutableNotificationContent()
        content.title = task.title
        content.body = task.contents
        content.sound = UNNotificationSound.default
        
        // ローカル通知が発動するtrigger（日付マッチ）を作成
        let calender = Calendar.current // ユーザ端末のカレンダー情報を取得する。
        let dateComponents = calender.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)
        
        // ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) {(error) in
            print(error ?? "ローカル通知登録 OK")
        }
        
        // 未通知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/---------------------")
                print(request)
                print("---------------------/")
            }
        }
    }

    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "categoryPickerSegue" {
            // 選択ボタンを押下してカテゴリーピッカーのポップアップに遷移
            let categoryPickerViewController: CategoryPickerViewController = segue.destination as! CategoryPickerViewController
            categoryPickerViewController.inputCategory = self.categoryTextField.text
            categoryPickerViewController.closure = {(str:String) -> Void in self.categoryTextField.text = str
            }
            segue.destination.popoverPresentationController?.delegate = self
        } else {
            // ＋ボタンを押下してカテゴリー作成画面へ遷移
            let newCategoryViewController: NewCategoryViewController = segue.destination as! NewCategoryViewController
            newCategoryViewController.closure = {self.checkButton()}
        }
    }
    
    // 選択ボタンの活性、非活性を制御するメソッド
    func checkButton () {
        let registedCategorycount = try! Realm().objects(Category.self).count
        if registedCategorycount > 0 {
            button.isEnabled = true
        } else {
            button.isEnabled = false
        }
    }
}
