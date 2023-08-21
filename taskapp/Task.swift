//
//  Task.swift
//  taskapp
//
//  Created by mawincommon on 2023/08/21.
//

import RealmSwift

class Task: Object {
    // 管理用 ID。プライマリーキー
    @Persisted(primaryKey: true) var id: ObjectId

    // カテゴリーを追加
    @Persisted var category = ""
    
    // タイトル
    @Persisted var title = ""

    // 内容
    @Persisted var contents = ""

    // 日時
    @Persisted var date = Date()

}
