//
//  InputViewController.swift
//  taskapp
//
//  Created by mawincommon on 2023/08/21.
//

import UIKit
import RealmSwift    // 追加する


class InputViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    //カテゴリーを追加
    @IBOutlet weak var categoryTextField: UITextField!
    
    let realm = try! Realm()    // 追加する
    var task: Task!   // 追加する
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 内容の枠線のカラー
        contentsTextView.layer.borderColor = UIColor.black.cgColor
        // 内容の枠線の幅
        contentsTextView.layer.borderWidth = 1.0
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
        
        //カテゴリーを追加
        categoryTextField.text = task.category
        
    }
    
    // 追加する
    override func viewWillDisappear(_ animated: Bool) {
        
        /*
         InputViewControllerに遷移し、何も入力しないで「back」で戻ると遷移時間がReaimに登録されるため、カテゴリ、タイトル、内容がないときは
         Realmにはaddしないようにする
         */
        
        //カテゴリが空白がどうか確認する
        if self.categoryTextField.text! != "" {
            
            //タイトルと内容が空白かどうか確認する
            if(self.titleTextField.text! != "" && self.contentsTextView.text != ""){
                
                //カテゴリ、タイトル、内容が入力されていれば、Realmに追加する
                try! realm.write {
                    self.task.title = self.titleTextField.text!
                    self.task.contents = self.contentsTextView.text
                    self.task.date = self.datePicker.date
                    self.realm.add(self.task, update: .modified)
                    
                    //カテゴリーを追加
                    self.task.category = self.categoryTextField.text!
                }
            }
            
        }
        setNotification(task: task)   // 追加
        super.viewWillDisappear(animated)
    }
    
    // タスクのローカル通知を登録する --- ここから ---
    func setNotification(task: Task) {
        let content = UNMutableNotificationContent()
        // タイトルと内容を設定(中身がない場合メッセージ無しで音だけの通知になるので「(xxなし)」を表示する)
        if task.title == "" {
            content.title = "(タイトルなし)"
        } else {
            content.title = task.title
        }
        if task.contents == "" {
            content.body = "(内容なし)"
        } else {
            content.body = task.contents
        }
        content.sound = UNNotificationSound.default
        
        // ローカル通知が発動するtrigger（日付マッチ）を作成
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest(identifier: String(task.id.stringValue), content: content, trigger: trigger)
        
        // ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録 OK")  // error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
        }
        
        // 未通知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/---------------")
                print(request)
                print("---------------/")
            }
        }
    } // --- ここまで追加 ---
    
    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
