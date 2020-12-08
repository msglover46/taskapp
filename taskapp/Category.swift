//
//  Category.swift
//  taskapp
//
//  Created by 三輪駿 on 2020/12/06.
//

import RealmSwift

class Category: Object {
    // 管理用ID。プライマリーキー
    @objc dynamic var id = 0
        
    // カテゴリー
    @objc dynamic var category = ""
    
    // idをプライマリーキーに設定
    override static func primaryKey() -> String? {
        return "id"
    }
}
