//
//  ViewController.swift
//  taskapp
//
//  Created by 三輪駿 on 2020/11/29.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // Realmインスタンスを取得する。
    let realm = try! Realm()
    
    // DB内のタスクが格納されるリスト。
    // 日付の近い順でソート：昇順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    
    // 検索バーに文字が入力された時に呼ばれるメソッド
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // 0.1秒後に遅延実行
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if searchBar.text != "" {
                self.taskArray = try! Realm().objects(Task.self)
                    .filter("category.title contains %@", self.searchBar.text!)
                    .sorted(byKeyPath: "date", ascending: true)
            } else {
                self.taskArray = try! Realm().objects(Task.self)
                    .sorted(byKeyPath: "date", ascending: true)
            }
            self.tableView.reloadData()
        }
        return true
    }
      
    // 検索バーのキャンセルボタンを押下した時に呼ばれるメソッド
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.endEditing(true)
        taskArray = try! Realm().objects(Task.self)
        .sorted(byKeyPath: "date", ascending: true)
        tableView.reloadData()
    }
    
    // 検索バーのブックマークボタンを押下した時に呼ばれるメソッド
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        let categorycount = try! Realm().objects(Category.self).count
        if categorycount > 0 {
            performSegue(withIdentifier: "selectCategorySegue", sender: nil)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
    }

    // データの数（セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能なcellを得る。
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Cellに値を設定する。
        let task = taskArray[indexPath.row]
        
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date) + " / " + task.category!.title
        cell.detailTextLabel?.text = dateString
        return cell
    }
    
    // 各セルを選択した時に実行されるメソッド
    func  tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.endEditing(true)
        performSegue(withIdentifier: "editTaskSegue", sender: nil)
    }
    
    // セルが削除可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // Deleteボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            // データベースから削除する。
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }

    // segue で画面遷移する時に呼ばれるメソッド
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        searchBar.endEditing(true)
        switch segue.identifier {
        case "editTaskSegue": // セルをタップしてタスク編集画面へ遷移
            let inputViewController:InputViewController = segue.destination as! InputViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
            inputViewController.title = "タスク編集"
        
        case "newTaskSegue": // ＋ボタンをタップしてタスク作成画面へ遷移
            let inputViewController:InputViewController = segue.destination as! InputViewController
            let task = Task()
            
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            inputViewController.task = task
            inputViewController.title = "タスク作成"
        
        default: // 検索バーのブックマークボタンをタップしてカテゴリー選択のポップアップを表示
            let selectCategoryViewController:SelectCategoryViewController = segue.destination as! SelectCategoryViewController
           selectCategoryViewController.closure = {(str: String) -> Void in   self.searchBar.text = str
               self.taskArray = try! Realm().objects(Task.self)
                   .filter("category.title contains %@", str)
                   .sorted(byKeyPath: "date", ascending: true)
               self.tableView.reloadData()
           }
            segue.destination.popoverPresentationController?.delegate = self
        }
    }
    
    // 入力画面から戻ってきた時に Table View を更新させる。
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
