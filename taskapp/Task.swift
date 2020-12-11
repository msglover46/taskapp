//
//  Task.swift
//  taskapp
//
//  Created by 三輪駿 on 2020/11/30.
//

import RealmSwift

class Task: Object {
    // 管理用ID。プライマリーキー
    @objc dynamic var id = 0
    
    // タイトル
    @objc dynamic var title = ""
    
    // カテゴリー
    @objc dynamic var category: Category?
    
    // 内容
    @objc dynamic var contents = ""
    
    //日時
    @objc dynamic var date = Date()
    
    // idをプライマリーキーに設定
    override static func primaryKey() -> String? {
        return "id"
    }
}
